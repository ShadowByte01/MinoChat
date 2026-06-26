import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mino_chat/core/theme/colors.dart';
import 'package:mino_chat/data/models/user_model.dart';
import 'package:mino_chat/data/repositories/supabase_repository.dart';
import 'package:mino_chat/features/auth/presentation/controllers/auth_controller.dart';
import '../controllers/chat_controller.dart';

class NewGroupScreen extends ConsumerStatefulWidget {
  const NewGroupScreen({super.key});
  @override
  ConsumerState<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends ConsumerState<NewGroupScreen> {
  final _name = TextEditingController();
  final _q = TextEditingController();
  final Set<String> _selected = {};
  List<MinoUser> _results = const [];

  Future<void> _search() async {
    if (_q.text.trim().isEmpty) { setState(() => _results = const []); return; }
    final r = await ref.read(supabaseRepositoryProvider).searchUsers(_q.text.trim());
    if (!mounted) return;
    setState(() => _results = r);
  }

  Future<void> _create() async {
    if (_name.text.trim().isEmpty || _selected.isEmpty) return;
    final me = ref.read(authControllerProvider).value;
    if (me == null) return;
    final chat = await ref.read(supabaseRepositoryProvider).createGroup(
      name: _name.text.trim(),
      ownerId: me.id,
      memberIds: _selected.toList(),
    );
    ref.read(chatListControllerProvider.notifier).refresh();
    if (!mounted) return;
    context.pushReplacement('/chat/${chat.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New group'),
        actions: [
          TextButton(
            onPressed: _create,
            child: const Text('Create'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Group name', prefixIcon: Icon(Icons.group)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _q,
              decoration: const InputDecoration(hintText: 'Add members…', prefixIcon: Icon(Icons.search)),
              onChanged: (_) => _search(),
            ),
          ),
          if (_selected.isNotEmpty)
            SizedBox(
              height: 70,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                children: _selected.map((id) {
                  final u = _results.firstWhere((e) => e.id == id, orElse: () => MinoUser(id: id, displayName: id));
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      avatar: CircleAvatar(child: Text(u.displayName.isNotEmpty ? u.displayName[0].toUpperCase() : '?')),
                      label: Text(u.displayName),
                      onDeleted: () => setState(() => _selected.remove(id)),
                    ),
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: ListView(
              children: _results
                  .where((u) => !_selected.contains(u.id))
                  .map((u) => ListTile(
                        leading: CircleAvatar(
                          backgroundImage: u.avatarUrl != null ? NetworkImage(u.avatarUrl!) : null,
                          child: u.avatarUrl == null ? Text(u.displayName.isNotEmpty ? u.displayName[0].toUpperCase() : '?') : null,
                        ),
                        title: Text(u.displayName),
                        subtitle: Text(u.email ?? ''),
                        onTap: () => setState(() => _selected.add(u.id)),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
