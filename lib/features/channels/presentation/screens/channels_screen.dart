import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../data/models/channel_model.dart';
import '../../../data/supabase/supabase_provider.dart';

class ChannelsScreen extends ConsumerStatefulWidget {
  const ChannelsScreen({super.key});
  @override
  ConsumerState<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends ConsumerState<ChannelsScreen> {
  late final Future<List<Channel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Channel>> _load() async {
    final sb = ref.read(supabaseProvider);
    final res = await sb.from('channels').select().order('subscriber_count', ascending: false).limit(50);
    return (res as List).map((m) => Channel.fromMap(m as Map<String, dynamic>)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Channels')),
      body: FutureBuilder<List<Channel>>(
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
                  const Text('No channels yet', style: TextStyle(color: MinoColors.muted)),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _create(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create a channel'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => setState(() => _future = _load()),
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) {
                final c = list[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: c.avatarUrl != null ? NetworkImage(c.avatarUrl!) : null,
                    child: c.avatarUrl == null
                        ? Text(c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                            style: const TextStyle(fontWeight: FontWeight.w700))
                        : null,
                  ),
                  title: Row(
                    children: [
                      Text(c.name),
                      if (c.isVerified)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.verified, size: 14, color: MinoColors.info),
                        ),
                    ],
                  ),
                  subtitle: Text('${c.subscriberCount} subscribers'),
                  onTap: () => context.push('/channel/${c.id}'),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _create(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) {
        final c = TextEditingController();
        return AlertDialog(
          title: const Text('Create a channel'),
          content: TextField(
            controller: c,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Channel name'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(_), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(_, c.text.trim()), child: const Text('Create')),
          ],
        );
      },
    );
    if (name == null || name.isEmpty) return;
    final sb = ref.read(supabaseProvider);
    final me = sb.auth.currentUser!.id;
    final res = await sb.from('channels').insert({
      'name': name,
      'owner_id': me,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    }).select().single();
    if (mounted) context.push('/channel/${res['id']}');
  }
}
