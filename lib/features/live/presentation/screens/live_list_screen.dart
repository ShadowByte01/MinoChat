import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../data/models/live_room_model.dart';
import '../../../data/repositories/supabase_repository.dart';

/// Live rooms list — discover active rooms, start a new one.
class LiveListScreen extends ConsumerStatefulWidget {
  const LiveListScreen({super.key});
  @override
  ConsumerState<LiveListScreen> createState() => _LiveListScreenState();
}

class _LiveListScreenState extends ConsumerState<LiveListScreen> {
  late final Future<List<LiveRoom>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<LiveRoom>> _load() async {
    try {
      final sb = ref.read(supabaseProvider);
      final res = await sb.from('live_rooms').select().eq('is_live', true).order('started_at', ascending: false).limit(50);
      return (res as List).map((m) => LiveRoom.fromMap(m as Map<String, dynamic>)).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live')),
      body: RefreshIndicator(
        onRefresh: () async => setState(() => _future = _load()),
        child: FutureBuilder<List<LiveRoom>>(
          future: _future,
          builder: (_, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final list = snap.data!;
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/logo.png', width: 80, height: 80, opacity: const AlwaysStoppedAnimation(0.7)),
                    const SizedBox(height: 12),
                    const Text('No live rooms right now', style: TextStyle(color: MinoColors.muted)),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _startRoom(context),
                      icon: const Icon(Icons.sensors),
                      label: const Text('Start a Live room'),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) => _LiveTile(room: list[i], onTap: () => context.push('/live/${list[i].id}')),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startRoom(context),
        icon: const Icon(Icons.sensors),
        label: const Text('Go Live'),
      ),
    );
  }

  Future<void> _startRoom(BuildContext context) async {
    final title = await showDialog<String>(
      context: context,
      builder: (_) {
        final c = TextEditingController();
        return AlertDialog(
          title: const Text('Start a Live room'),
          content: TextField(
            controller: c,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Room title'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(_), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(_, c.text.trim()), child: const Text('Start')),
          ],
        );
      },
    );
    if (title == null || title.isEmpty) return;
    try {
      final sb = ref.read(supabaseProvider);
      final me = sb.auth.currentUser!.id;
      final res = await sb
          .from('live_rooms')
          .insert({
            'title': title,
            'host_id': me,
            'kind': 'audio',
            'is_live': true,
            'started_at': DateTime.now().toUtc().toIso8601String(),
          })
          .select()
          .single();
      if (!mounted) return;
      context.push('/live/${res['id']}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }
}

class _LiveTile extends StatelessWidget {
  final LiveRoom room;
  final VoidCallback onTap;
  const _LiveTile({required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  gradient: MinoGradients.liveBadge,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.sensors, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(room.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 14, color: MinoColors.muted),
                        const SizedBox(width: 4),
                        Text('${room.totalParticipants} listening',
                          style: const TextStyle(color: MinoColors.muted, fontSize: 12)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: MinoColors.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: MinoColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
