import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';

import 'package:mino_chat/core/theme/colors.dart';
import 'package:mino_chat/core/utils/file_utils.dart';
import 'package:mino_chat/core/utils/logger.dart';
import 'package:mino_chat/core/utils/time.dart';
import 'package:mino_chat/data/models/message_model.dart';
import 'package:mino_chat/data/repositories/supabase_repository.dart';
import 'package:mino_chat/features/auth/presentation/controllers/auth_controller.dart';
import '../controllers/chat_controller.dart';
import '../widgets/message_bubble.dart';
import 'package:mino_chat/features/voice/presentation/widgets/voice_recorder_bar.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String chatId;
  final bool showInfo;
  const ChatRoomScreen({super.key, required this.chatId, this.showInfo = false});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _emoji = false;
  bool _showAttach = false;
  String? _replyToId;
  String? _replyToPreview;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    await ref.read(chatRoomControllerProvider(widget.chatId).notifier).sendText(
      text,
      replyToId: _replyToId,
      replyToPreview: _replyToPreview,
    );
    setState(() { _replyToId = null; _replyToPreview = null; });
    _scrollToBottom();
  }

  Future<void> _pickImage() async {
    setState(() => _showAttach = false);
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (x == null) return;
    await _sendAttachmentFile(File(x.path), MessageKind.image, 'image/jpeg');
  }

  Future<void> _pickCamera() async {
    setState(() => _showAttach = false);
    final x = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
    if (x == null) return;
    await _sendAttachmentFile(File(x.path), MessageKind.image, 'image/jpeg');
  }

  Future<void> _pickVideo() async {
    setState(() => _showAttach = false);
    final x = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (x == null) return;
    await _sendAttachmentFile(File(x.path), MessageKind.video, 'video/mp4');
  }

  Future<void> _pickFile() async {
    setState(() => _showAttach = false);
    final result = await FilePicker.pickFiles(allowMultiple: false);
    if (result == null || result.files.single.path == null) return;
    final f = File(result.files.single.path!);
    final mime = FileX.mime(f.path);
    final kind = (mime?.startsWith('image/') ?? false) ? MessageKind.image
              : (mime?.startsWith('video/') ?? false) ? MessageKind.video
              : (mime?.startsWith('audio/') ?? false) ? MessageKind.audio
              : MessageKind.file;
    await _sendAttachmentFile(f, kind, mime);
  }

  Future<void> _sendAttachmentFile(File f, MessageKind kind, String? mime) async {
    final me = ref.read(authControllerProvider).value;
    if (me == null) return;
    final bytes = await f.readAsBytes();
    final url = await ref.read(supabaseRepositoryProvider).uploadAttachment(
      chatId: widget.chatId,
      fileName: FileX.name(f.path),
      bytes: bytes,
      contentType: mime,
    );
    final msg = Message(
      id: '${me.id}_${DateTime.now().millisecondsSinceEpoch}',
      chatId: widget.chatId,
      senderId: me.id,
      kind: kind,
      text: '',
      attachmentUrl: url,
      attachmentName: FileX.name(f.path),
      attachmentSize: bytes.length,
      attachmentMime: mime,
      createdAt: DateTime.now(),
      status: MessageStatus.sending,
    );
    await ref.read(chatRoomControllerProvider(widget.chatId).notifier).sendAttachment(msg);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final msgs = ref.watch(chatRoomControllerProvider(widget.chatId));
    final me = ref.watch(authControllerProvider).value;
    ref.listen(chatRoomControllerProvider(widget.chatId), (_, __) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: () => context.push('/call/${widget.chatId}')),
          IconButton(icon: const Icon(Icons.phone), onPressed: () => context.push('/call/${widget.chatId}')),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: msgs.when(
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/logo.png', width: 80, height: 80, opacity: const AlwaysStoppedAnimation(0.6)),
                        const SizedBox(height: 12),
                        const Text('Say hi!', style: TextStyle(color: MinoColors.muted)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final m = list[i];
                    final prev = i > 0 ? list[i - 1] : null;
                    final showAvatar = prev?.senderId != m.senderId;
                    final showDate = prev == null ||
                        TimeX.groupKey(prev.createdAt) != TimeX.groupKey(m.createdAt);
                    return Column(
                      children: [
                        if (showDate)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: MinoColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(TimeX.day(m.createdAt),
                                style: const TextStyle(color: MinoColors.muted, fontSize: 11),
                              ),
                            ),
                          ),
                        MessageBubble(
                          message: m,
                          isMine: me?.id == m.senderId,
                          showAvatar: showAvatar && !m.isDeleted,
                          onLongPress: () => _showActions(m),
                          onReact: (emoji) => ref.read(chatRoomControllerProvider(widget.chatId).notifier).react(m.id, emoji),
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          if (_replyToId != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: MinoColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border(left: BorderSide(color: MinoColors.primary, width: 3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Replying to', style: TextStyle(color: MinoColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                        Text(_replyToPreview ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() { _replyToId = null; _replyToPreview = null; }),
                  ),
                ],
              ),
            ),
          if (_showAttach) _attachSheet(),
          _inputBar(),
          if (_emoji)
            SizedBox(
              height: 280,
              child: EmojiPicker(
                onEmojiSelected: (cat, emoji) {
                  _input.text += emoji.emoji;
                  _input.selection = TextSelection.fromPosition(TextPosition(offset: _input.text.length));
                },
                config: Config(
                                    emojiViewConfig: EmojiViewConfig(emojiSizeMax: 28),
                  categoryViewConfig: const CategoryViewConfig(tabIndicatorAnimDuration: Duration(milliseconds: 200)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _inputBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined, color: MinoColors.muted),
              onPressed: () => setState(() { _emoji = !_emoji; _showAttach = false; }),
            ),
            IconButton(
              icon: const Icon(Icons.attach_file, color: MinoColors.muted),
              onPressed: () => setState(() { _showAttach = !_showAttach; _emoji = false; }),
            ),
            Expanded(
              child: TextField(
                controller: _input,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Message…',
                  filled: true,
                  fillColor: MinoColors.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) {
                  // Typing indicator broadcasting
                  final me = ref.read(authControllerProvider).value;
                  if (me == null) return;
                  ref.read(supabaseRepositoryProvider).broadcastTyping(widget.chatId, me.id, v.isNotEmpty);
                },
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 4),
            // Voice-record FAB if input empty, else send
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _input,
              builder: (_, value, __) {
                if (value.text.trim().isEmpty) {
                  return VoiceRecorderBar(
                    chatId: widget.chatId,
                    onSent: _scrollToBottom,
                  );
                }
                return FloatingActionButton.small(
                  heroTag: 'send',
                  onPressed: _send,
                  child: const Icon(Icons.send, size: 18),
                ).animate().scale();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _attachSheet() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MinoColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MinoColors.outline, width: 0.5),
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 14,
        children: [
          _AttachItem(icon: Icons.image, label: 'Photo', color: const Color(0xFF7C5CFC), onTap: _pickImage),
          _AttachItem(icon: Icons.camera_alt, label: 'Camera', color: const Color(0xFFEC4899), onTap: _pickCamera),
          _AttachItem(icon: Icons.videocam, label: 'Video', color: const Color(0xFFF59E0B), onTap: _pickVideo),
          _AttachItem(icon: Icons.insert_drive_file, label: 'Document', color: const Color(0xFF38BDF8), onTap: _pickFile),
          _AttachItem(icon: Icons.location_on, label: 'Location', color: const Color(0xFF22C55E), onTap: () {}),
          _AttachItem(icon: Icons.contact_page, label: 'Contact', color: const Color(0xFF8B5CF6), onTap: () {}),
          _AttachItem(icon: Icons.poll, label: 'Poll', color: const Color(0xFFEF4444), onTap: () {}),
        ],
      ),
    );
  }

  void _showActions(Message m) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _replyToId = m.id;
                  _replyToPreview = m.text.isEmpty ? (m.attachmentName ?? 'Attachment') : m.text;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () { Clipboard.setData(ClipboardData(text: m.text)); Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.forward),
              title: const Text('Forward'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.emoji_emotions),
              title: const Text('React'),
              onTap: () {
                Navigator.pop(context);
                _showReactPicker(m);
              },
            ),
            if (m.senderId == ref.read(authControllerProvider).value?.id) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: MinoColors.error),
                title: const Text('Delete', style: TextStyle(color: MinoColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(chatRoomControllerProvider(widget.chatId).notifier).delete(m.id);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showReactPicker(Message m) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['👍', '❤️', '😂', '😮', '😢', '🙏']
                .map((e) => GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        ref.read(chatRoomControllerProvider(widget.chatId).notifier).react(m.id, e);
                      },
                      child: Text(e, style: const TextStyle(fontSize: 28)),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _AttachItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AttachItem({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: MinoColors.muted)),
          ],
        ),
      ),
    );
  }
}
