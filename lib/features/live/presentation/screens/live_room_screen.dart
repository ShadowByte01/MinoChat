import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../data/models/live_room_model.dart';
import '../../../data/supabase/supabase_provider.dart';

/// Live audio/video room.
/// Host speaks on mic, audience listens + raises hand to speak.
/// WebRTC transport handled by LiveKit (separate controller in production).
class LiveRoomScreen extends ConsumerStatefulWidget {
  final String roomId;
  const LiveRoomScreen({super.key, required this.roomId});
  @override
  ConsumerState<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends ConsumerState<LiveRoomScreen> {
  LiveRoom? _room;
  bool _loading = true;
  bool _micOn = false;
  bool _handRaised = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final sb = ref.read(supabaseProvider);
      final m = await sb.from('live_rooms').select().eq('id', widget.roomId).single();
      setState(() { _room = LiveRoom.fromMap(m); _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _leave() async {
    final me = ref.read(supabaseProvider).auth.currentUser?.id;
    if (_room != null && me != null) {
      try {
        await ref.read(supabaseProvider).from('live_rooms').update({
          'audience_ids': _room!.audienceIds.where((id) => id != me).toList(),
          'speaker_ids': _room!.speakerIds.where((id) => id != me).toList(),
        }).eq('id', widget.roomId);
      } catch (_) {}
    }
    if (mounted) context.pop();
  }

  Future<void> _toggleHand() async {
    final me = ref.read(supabaseProvider).auth.currentUser?.id;
    if (_room == null || me == null) return;
    final raised = !_handRaised;
    final list = List<String>.from(_room!.raisedHandIds);
    if (raised) list.add(me); else list.remove(me);
    await ref.read(supabaseProvider).from('live_rooms').update({'raised_hand_ids': list}).eq('id', widget.roomId);
    setState(() => _handRaised = raised);
  }

  Future<void> _toggleMic() async {
    setState(() => _micOn = !_micOn);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final room = _room;
    if (room == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Room not found')),
      );
    }
    final me = ref.watch(supabaseProvider).auth.currentUser?.id;
    final isHost = room.hostId == me;
    final isSpeaker = isHost || room.speakerIds.contains(me);

    return Scaffold(
      appBar: AppBar(
        title: Text(room.title),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Top stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(gradient: MinoGradients.liveBadge),
            child: Row(
              children: [
                const Icon(Icons.sensors, color: Colors.white),
                const SizedBox(width: 8),
                const Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                const Spacer(),
                const Icon(Icons.people, color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Text('${room.totalParticipants}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          // Speakers (circular)
          Expanded(
            flex: 2,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 110,
                childAspectRatio: 0.85,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 1 + room.speakerIds.length,
              itemBuilder: (_, i) {
                final isLive = (i == 0 && isHost && _micOn) || (i > 0 && _micOn);
                return Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: MinoColors.primaryContainer,
                          child: const Icon(Icons.person, size: 36, color: MinoColors.primary),
                        ),
                        if (isLive)
                          Positioned(
                            right: 0, bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: MinoColors.error, shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.mic, color: Colors.white, size: 12),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      i == 0 ? 'Host' : 'Speaker',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
            ),
          ),
          // Raised hands list (audience)
          if (room.raisedHandIds.isNotEmpty)
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: room.raisedHandIds.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          const CircleAvatar(radius: 18, child: Icon(Icons.person, size: 18)),
                          Positioned(
                            right: -2, bottom: -2,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(color: MinoColors.warning, shape: BoxShape.circle),
                              child: const Icon(Icons.pan_tool, size: 10, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text('Hand', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ),
          // Bottom controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (isSpeaker)
                    FloatingActionButton(
                      heroTag: 'mic',
                      backgroundColor: _micOn ? MinoColors.primary : MinoColors.surfaceVariant,
                      onPressed: _toggleMic,
                      child: Icon(_micOn ? Icons.mic : Icons.mic_off,
                        color: _micOn ? Colors.white : MinoColors.muted),
                    ),
                  if (!isSpeaker)
                    FloatingActionButton(
                      heroTag: 'hand',
                      backgroundColor: _handRaised ? MinoColors.warning : MinoColors.surfaceVariant,
                      onPressed: _toggleHand,
                      child: Icon(Icons.pan_tool,
                        color: _handRaised ? Colors.white : MinoColors.muted),
                    ),
                  FloatingActionButton(
                    heroTag: 'leave',
                    backgroundColor: MinoColors.error,
                    onPressed: _leave,
                    child: const Icon(Icons.call_end, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
