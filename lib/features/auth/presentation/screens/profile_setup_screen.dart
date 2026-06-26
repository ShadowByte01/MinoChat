import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mino_chat/core/theme/colors.dart';
import 'package:mino_chat/data/repositories/supabase_repository.dart';
import 'package:mino_chat/data/supabase/supabase_provider.dart';
import '../controllers/auth_controller.dart';

/// Profile setup — only shown the first time after Google sign-in.
/// Captures display name + avatar. Phone / bio optional.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});
  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _name = TextEditingController();
  final _bio = TextEditingController();
  String? _avatarUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = ref.read(authControllerProvider).value;
    if (u != null) {
      _name.text = u.displayName;
      _bio.text = u.bio ?? '';
      _avatarUrl = u.avatarUrl;
    }
  }

  Future<void> _pickAvatar() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 85);
    if (x == null) return;
    final bytes = await x.readAsBytes();
    final uid = ref.read(supabaseProvider).auth.currentUser!.id;
    final url = await ref.read(supabaseRepositoryProvider).uploadAvatar(uid, bytes, 'image/jpeg');
    setState(() => _avatarUrl = url);
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final uid = ref.read(supabaseProvider).auth.currentUser!.id;
    await ref.read(supabaseRepositoryProvider).updateProfile(
      id: uid,
      displayName: _name.text.trim(),
      bio: _bio.text.trim(),
      avatarUrl: _avatarUrl,
    );
    await ref.read(authControllerProvider.notifier).refresh();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set up your profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: CircleAvatar(
                  radius: 64,
                  backgroundColor: MinoColors.primaryContainer,
                  backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                  child: _avatarUrl == null
                      ? const Icon(Icons.camera_alt, size: 32, color: MinoColors.primary)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Display name', hintText: 'How should friends see you?'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _bio,
              decoration: const InputDecoration(labelText: 'Bio (optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Start chatting'),
            ),
          ],
        ),
      ),
    );
  }
}
