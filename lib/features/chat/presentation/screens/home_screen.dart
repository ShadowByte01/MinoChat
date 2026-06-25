import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/chat_room_model.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/supabase_repository.dart';
import '../../../data/supabase/supabase_provider.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/chat_controller.dart';
import '../widgets/message_bubble.dart';

/// Home screen — chat list + FABs.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh chat list whenever we land here
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supabaseRepositoryProvider);
      ref.read(chatListProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chats = ref.watch(chatListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mino Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/new-chat'),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMenu(context),
          ),
        ],
      ),
      body: chats.when(
        data: (list) {
          if (list.isEmpty) {
            return _EmptyState(onStart: () => context.push('/new-chat'));
          }
          final pinned = list.where((c) => c.isPinned).toList();
          final rest = list.where((c) => !c.isPinned).toList();
          return RefreshIndicator(
            onRefresh: () => ref.read(chatListProvider.notifier).refresh(),
            child: ListView(
              children: [
                if (pinned.isNotEmpty) ...[
                  for (final c in pinned) _tile(c),
                  const Divider(height: 1),
                ],
                for (final c in rest) _tile(c),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load chats: $e')),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'story',
            onPressed: () => context.push('/story/camera'),
            child: const Icon(Icons.camera_alt),
          ).animate().fade(delay: 200.ms).slideY(begin: 0.4, end: 0),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'new_chat',
            onPressed: () => context.push('/new-chat'),
            child: const Icon(Icons.edit),
          ).animate().fade(delay: 100.ms).slideY(begin: 0.4, end: 0),
        ],
      ),
    );
  }

  Widget _tile(ChatRoom c) {
    final me = ref.watch(authControllerProvider).valueOrNull?.id;
    final otherId = c.memberIds.firstWhere((id) => id != me, orElse: () => '');
    return Consumer(builder: (context, ref, _) {
      MinoUser? peer;
      if (c.isDirect && otherId.isNotEmpty) {
        peer = ref.watch(_userCacheProvider(otherId)).valueOrNull;
      }
      return ChatTile(
        chat: c,
        other: peer,
        onTap: () => context.push('/chat/${c.id}'),
        onLongPress: () => _showChatActions(c),
      );
    });
  }

  void _showChatActions(ChatRoom c) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(c.isPinned ? Icons.push_pin_outlined : Icons.push_pin),
              title: Text(c.isPinned ? 'Unpin' : 'Pin'),
              onTap: () { ref.read(chatListProvider.notifier).pin(c, !c.isPinned); Navigator.pop(context); },
            ),
            ListTile(
              leading: Icon(c.isMuted ? Icons.volume_up : Icons.volume_off),
              title: Text(c.isMuted ? 'Unmute' : 'Mute'),
              onTap: () { ref.read(chatListProvider.notifier).mute(c, !c.isMuted); Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: Text(c.isArchived ? 'Unarchive' : 'Archive'),
              onTap: () { ref.read(chatListProvider.notifier).archive(c, !c.isArchived); Navigator.pop(context); },
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('New group'),
              onTap: () { Navigator.pop(context); context.push('/new-group'); },
            ),
            ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text('New channel'),
              onTap: () { Navigator.pop(context); context.push('/channels'); },
            ),
            ListTile(
              leading: const Icon(Icons.sensors),
              title: const Text('Start a Live room'),
              onTap: () { Navigator.pop(context); context.push('/live'); },
            ),
            ListTile(
              leading: const Icon(Icons.bluetooth),
              title: const Text('Offline mesh'),
              onTap: () { Navigator.pop(context); context.push('/ble'); },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () { Navigator.pop(context); context.push('/settings'); },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onStart;
  const _EmptyState({required this.onStart});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', width: 96, height: 96, opacity: const AlwaysStoppedAnimation(0.8)),
            const SizedBox(height: 20),
            const Text('No chats yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Start your first conversation. Tap below to find people you know or create a group.',
              textAlign: TextAlign.center,
              style: TextStyle(color: MinoColors.muted, fontSize: 14),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.edit),
              label: const Text('Start a chat'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tiny per-user cache so direct-chat tiles can show the peer.
final _userCacheProvider = FutureProvider.family<MinoUser?, String>((ref, id) async {
  try {
    return await ref.watch(supabaseRepositoryProvider).fetchUser(id);
  } catch (e, st) {
    log.w('user cache miss', error: e, stackTrace: st);
    return null;
  }
});
