import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/colors.dart';
import '../../../core/utils/file_utils.dart';
import '../../../data/models/message_model.dart';

/// Single message bubble. Handles all [MessageKind] variants.
class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMine;
  final bool showAvatar;
  final String? senderName;
  final String? senderAvatar;
  final VoidCallback? onLongPress;
  final VoidCallback? onReplyTap;
  final Function(String emoji)? onReact;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.showAvatar = false,
    this.senderName,
    this.senderAvatar,
    this.onLongPress,
    this.onReplyTap,
    this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    if (message.kind == MessageKind.system) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: MinoColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message.text,
            style: const TextStyle(color: MinoColors.muted, fontSize: 12),
          ),
        ),
      );
    }

    if (message.isDeleted) {
      return _wrap(Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: MinoColors.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(Mino.deletedMarker,
            style: TextStyle(color: MinoColors.muted, fontStyle: FontStyle.italic, fontSize: 13),
          ),
        ),
      ));
    }

    return _wrap(
      GestureDetector(
        onLongPress: onLongPress,
        child: Align(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMine && showAvatar)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: MinoColors.primaryContainer,
                    backgroundImage: senderAvatar != null ? CachedNetworkImageProvider(senderAvatar!) : null,
                    child: senderAvatar == null
                        ? Text((senderName ?? '?')[0].toUpperCase(),
                            style: const TextStyle(color: MinoColors.primary, fontSize: 12, fontWeight: FontWeight.w700))
                        : null,
                  ),
                ),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.78,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  padding: _paddingFor(),
                  decoration: BoxDecoration(
                    color: isMine ? MinoColors.bubbleOut : MinoColors.bubbleIn,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMine ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isMine ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                  ),
                  child: _content(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wrap(Widget child) {
    if (message.reactions.isEmpty) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          bottom: -6,
          right: isMine ? 12 : null,
          left: isMine ? null : (showAvatar ? 36 : 12),
          child: _ReactionsRow(
            reactions: message.reactions,
            onTap: onReact,
          ),
        ),
      ],
    );
  }

  EdgeInsets _paddingFor() {
    switch (message.kind) {
      case MessageKind.image:
      case MessageKind.video:
      case MessageKind.sticker:
      case MessageKind.gif:
        return EdgeInsets.zero;
      default:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    }
  }

  Widget _content() {
    switch (message.kind) {
      case MessageKind.text:
      case MessageKind.reply:
      case MessageKind.forwarded:
        return _textBody();
      case MessageKind.image:
        return _imageBody();
      case MessageKind.video:
        return _videoBody();
      case MessageKind.voice:
        return _voiceBody();
      case MessageKind.audio:
        return _audioBody();
      case MessageKind.file:
        return _fileBody();
      case MessageKind.location:
        return Text('📍 Location\n${message.text}',
            style: const TextStyle(fontSize: 14, color: MinoColors.onBackground));
      case MessageKind.contact:
        return Text('👤 ${message.text}',
            style: const TextStyle(fontSize: 14, color: MinoColors.onBackground));
      case MessageKind.poll:
        return Text('📊 ${message.text}',
            style: const TextStyle(fontSize: 14, color: MinoColors.onBackground));
      case MessageKind.call:
        return _callBody();
      case MessageKind.system:
      case MessageKind.deleted:
        return const SizedBox.shrink();
    }
  }

  Widget _textBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isMine && showAvatar && senderName != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(senderName!,
              style: const TextStyle(color: MinoColors.primary, fontWeight: FontWeight.w700, fontSize: 12.5),
            ),
          ),
        if (message.replyToId != null)
          GestureDetector(
            onTap: onReplyTap,
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: MinoColors.primary.withOpacity(0.1),
                border: Border(left: BorderSide(color: MinoColors.primary, width: 2.5)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(message.replyToPreview ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: MinoColors.primary),
              ),
            ),
          ),
        if (message.forwardedFromId != null)
          const Padding(
            padding: EdgeInsets.only(bottom: 2),
            child: Text('↗ Forwarded',
              style: TextStyle(fontSize: 11, color: MinoColors.muted, fontStyle: FontStyle.italic),
            ),
          ),
        Text(message.text,
          style: TextStyle(
            fontSize: 14.5,
            color: isMine ? MinoColors.onBackground : MinoColors.onBackground,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.editedAt != null)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Text('edited', style: TextStyle(fontSize: 10, color: MinoColors.muted, fontStyle: FontStyle.italic)),
              ),
            Text(TimeX.clock(message.createdAt),
              style: const TextStyle(fontSize: 10.5, color: MinoColors.muted),
            ),
            if (isMine) ...[
              const SizedBox(width: 4),
              _statusIcon(),
            ],
          ],
        ),
      ],
    );
  }

  Widget _imageBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 220,
              maxHeight: 320,
              minWidth: 100,
            ),
            child: CachedNetworkImage(
              imageUrl: message.attachmentUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: MinoColors.surfaceVariant,
                height: 200,
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (_, __, ___) => Container(
                color: MinoColors.surfaceVariant,
                height: 180,
                child: const Icon(Icons.broken_image, color: MinoColors.muted),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 4, bottom: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(TimeX.clock(message.createdAt),
                style: const TextStyle(fontSize: 10.5, color: MinoColors.muted)),
              if (isMine) ...[const SizedBox(width: 4), _statusIcon()],
            ],
          ),
        ),
      ],
    );
  }

  Widget _videoBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: message.thumbnailUrl != null
                  ? CachedNetworkImage(imageUrl: message.thumbnailUrl!, width: 220, height: 140, fit: BoxFit.cover)
                  : Container(
                      width: 220, height: 140,
                      color: MinoColors.surfaceVariant,
                      child: const Icon(Icons.movie, size: 36, color: MinoColors.muted),
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 4, bottom: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(TimeX.clock(message.createdAt), style: const TextStyle(fontSize: 10.5, color: MinoColors.muted)),
              if (isMine) ...[const SizedBox(width: 4), _statusIcon()],
            ],
          ),
        ),
      ],
    );
  }

  Widget _voiceBody() {
    final dur = message.durationSec ?? 0;
    final mm = (dur ~/ 60).toString().padLeft(2, '0');
    final ss = (dur % 60).toString().padLeft(2, '0');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(isMine ? Icons.mic : Icons.play_arrow, color: MinoColors.primary, size: 20),
        const SizedBox(width: 8),
        // Waveform placeholder (real waveform widget wired in voice_notes widget)
        SizedBox(
          width: 100,
          height: 24,
          child: CustomPaint(painter: _WaveformPainter()),
        ),
        const SizedBox(width: 8),
        Text('$mm:$ss', style: const TextStyle(fontSize: 12, color: MinoColors.onBackground, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Text(TimeX.clock(message.createdAt), style: const TextStyle(fontSize: 10.5, color: MinoColors.muted)),
        if (isMine) ...[const SizedBox(width: 4), _statusIcon()],
      ],
    );
  }

  Widget _audioBody() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.music_note, color: MinoColors.primary),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: Text(message.attachmentName ?? 'Audio',
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(TimeX.clock(message.createdAt), style: const TextStyle(fontSize: 10.5, color: MinoColors.muted)),
      ],
    );
  }

  Widget _fileBody() {
    final kind = FileX.kind(message.attachmentName ?? '');
    final icon = switch (kind) {
      FileKind.image => Icons.image,
      FileKind.video => Icons.movie,
      FileKind.audio => Icons.audio_file,
      FileKind.pdf => Icons.picture_as_pdf,
      FileKind.archive => Icons.folder_zip,
      FileKind.doc => Icons.description,
      FileKind.other => Icons.insert_drive_file,
    };
    final size = message.attachmentSize != null ? FileX.humanSize(message.attachmentSize!) : '';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: MinoColors.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: MinoColors.primary, size: 22),
        ),
        const SizedBox(width: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.attachmentName ?? 'File',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
              ),
              if (size.isNotEmpty)
                Text(size, style: const TextStyle(fontSize: 11, color: MinoColors.muted)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(TimeX.clock(message.createdAt), style: const TextStyle(fontSize: 10.5, color: MinoColors.muted)),
        if (isMine) ...[const SizedBox(width: 4), _statusIcon()],
      ],
    );
  }

  Widget _callBody() {
    final isOutgoing = message.metadata?['direction'] == 'out';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(isOutgoing ? Icons.call_made : Icons.call_received,
          color: MinoColors.primary, size: 16),
        const SizedBox(width: 8),
        Text(message.text, style: const TextStyle(fontSize: 13.5)),
        const SizedBox(width: 8),
        Text(TimeX.clock(message.createdAt), style: const TextStyle(fontSize: 10.5, color: MinoColors.muted)),
      ],
    );
  }

  Widget _statusIcon() {
    return switch (message.status) {
      MessageStatus.sending   => const Icon(Icons.access_time, size: 12, color: MinoColors.muted),
      MessageStatus.sent      => const Icon(Icons.check, size: 14, color: MinoColors.muted),
      MessageStatus.delivered => const Icon(Icons.done_all, size: 14, color: MinoColors.muted),
      MessageStatus.read      => const Icon(Icons.done_all, size: 14, color: MinoColors.secondary),
      MessageStatus.failed    => const Icon(Icons.error_outline, size: 14, color: MinoColors.error),
    };
  }
}

class _ReactionsRow extends StatelessWidget {
  final Map<String, String> reactions;
  final Function(String)? onTap;
  const _ReactionsRow({required this.reactions, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: MinoColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MinoColors.outline, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reactions.entries.map((e) {
          final count = e.value.split(',').length;
          return GestureDetector(
            onTap: () => onTap?.call(e.key),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text('${e.key} $count',
                style: const TextStyle(fontSize: 11),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MinoColors.primary
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final bars = 18;
    final w = size.width / bars;
    final rng = List.generate(bars, (i) => 0.3 + ((i * 7) % 10) / 14);
    for (var i = 0; i < bars; i++) {
      final h = size.height * rng[i];
      canvas.drawLine(
        Offset(i * w + w / 2, (size.height - h) / 2),
        Offset(i * w + w / 2, (size.height + h) / 2),
        paint,
      );
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
