import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mino_chat/core/theme/colors.dart';
import 'package:mino_chat/data/repositories/supabase_repository.dart';
import 'package:mino_chat/data/supabase/supabase_provider.dart';

class StoryCameraScreen extends ConsumerStatefulWidget {
  const StoryCameraScreen({super.key});
  @override
  ConsumerState<StoryCameraScreen> createState() => _StoryCameraScreenState();
}

class _StoryCameraScreenState extends ConsumerState<StoryCameraScreen> {
  final _text = TextEditingController();
  String? _bg;
  bool _posting = false;

  Future<void> _pick() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (x == null) return;
    setState(() => _posting = true);
    try {
      final bytes = await x.readAsBytes();
      final uid = ref.read(supabaseProvider).auth.currentUser!.id;
      await ref.read(supabaseRepositoryProvider).uploadStory(uid, bytes, 'image/jpeg');
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  Future<void> _postText() async {
    if (_text.text.trim().isEmpty) return;
    setState(() => _posting = true);
    try {
      final sb = ref.read(supabaseProvider);
      final uid = sb.auth.currentUser!.id;
      await sb.from('stories').insert({
        'user_id': uid,
        'kind': 'text',
        'text': _text.text.trim(),
        'background_color': _bg ?? '#7C5CFC',
        'duration_sec': 5,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'expires_at': DateTime.now().add(const Duration(hours: 24)).toUtc().toIso8601String(),
      });
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg != null ? _parseColor(_bg!) : MinoColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library, color: Colors.white),
            onPressed: _pick,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: TextField(
                    controller: _text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, height: 1.4),
                    decoration: const InputDecoration(
                      hintText: 'Type something…',
                      hintStyle: TextStyle(color: Colors.white54, fontSize: 22, fontWeight: FontWeight.w600),
                      border: InputBorder.none,
                    ),
                    maxLines: 4,
                  ),
                ),
              ),
            ),
            // Background color picker
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: ['#7C5CFC', '#34D399', '#F87171', '#F59E0B', '#38BDF8', '#EC4899', '#1A1A2E']
                    .map((c) => GestureDetector(
                          onTap: () => setState(() => _bg = c),
                          child: Container(
                            width: 40, height: 40, margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: _parseColor(c),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 2),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: _posting ? null : _postText,
                icon: _posting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send),
                label: const Text('Post story'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) => Color(int.parse(hex.substring(1), radix: 16) | 0xFF000000);
}
