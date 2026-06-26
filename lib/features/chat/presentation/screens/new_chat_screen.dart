import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mino_chat/core/theme/colors.dart';
import 'package:mino_chat/data/models/user_model.dart';
import 'package:mino_chat/data/repositories/supabase_repository.dart';
import 'package:mino_chat/features/auth/presentation/controllers/auth_controller.dart';
import '../controllers/chat_controller.dart';

/// Start a new chat — search by name or email, then tap to create a direct chat.
class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({super.key});
  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
  final _q = TextEditingController();
  List<MinoUser> _results = const [];
  bool _searching = false;

  Future<void> _run() async {
    if (_q.text.trim().isEmpty) {
      setState(() { _results = const []; return; });
    }
    setState(() => _searching = true);
    final r = await ref.read(supabaseRepositoryProvider).searchUsers(_q.text.trim());
    if (!mounted) return;
    setState(() { _results = r; _searching = false; });
  }

  Future<void> _open(MinoUser u) async {
    final me = ref.read(authControllerProvider).value;
    if (me == null) return;
    final chat = await ref.read(supabaseRepositoryProvider).createDirectChat(me.id, u.id);
    ref.read(chatListControllerProvider.notifier).refresh();
    if (!mounted) return;
    context.pushReplacement('/chat/${chat.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _q,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by name or email…',
            border: InputBorder.none,
          ),
          onChanged: (_) => _run(),
          onSubmitted: (_) => _run(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () => context.push('/new-group'),
          ),
        ],
      ),
      body: _searching
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.group)),
                  title: const Text('New group'),
                  subtitle: const Text('Up to 500 members'),
                  onTap: () => context.push('/new-group'),
                ),
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person_add)),
                  title: const Text('New contact'),
                  onTap: () {},
                ),
                const Divider(),
                if (_results.isEmpty && _q.text.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('No users found.', style: TextStyle(color: MinoColors.muted))),
                  )
                else
                  for (final u in _results)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: u.avatarUrl != null ? NetworkImage(u.avatarUrl!) : null,
                        child: u.avatarUrl == null ? Text(u.displayName.isNotEmpty ? u.displayName[0].toUpperCase() : '?') : null,
                      ),
                      title: Text(u.displayName),
                      subtitle: Text(u.email ?? ''),
                      onTap: () => _open(u),
                    ),
              ],
            ),
    );
  }
}
