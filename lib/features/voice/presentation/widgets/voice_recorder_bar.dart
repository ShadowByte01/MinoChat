import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/message_model.dart';
import '../../../data/repositories/supabase_repository.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../chat/presentation/controllers/chat_controller.dart';

/// Press-and-hold mic to record, release to send.
/// Tap (no hold) to enter locked recording mode.
class VoiceRecorderBar extends ConsumerStatefulWidget {
  final String chatId;
  final VoidCallback onSent;
  const VoiceRecorderBar({super.key, required this.chatId, required this.onSent});

  @override
  ConsumerState<VoiceRecorderBar> createState() => _VoiceRecorderBarState();
}

class _VoiceRecorderBarState extends ConsumerState<VoiceRecorderBar> {
  final _rec = AudioRecorder();
  final _player = AudioPlayer();
  bool _recording = false;
  bool _locked = false;
  Duration _elapsed = Duration.zero;
  Timer? _t;
  String? _path;

  @override
  void dispose() {
    _t?.cancel();
    _rec.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    try {
      if (!await _rec.hasPermission()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied')),
        );
        return;
      }
      _path = '/tmp/mino_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _rec.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          sampleRate: 44100,
        ),
        path: _path!,
      );
      setState(() { _recording = true; _elapsed = Duration.zero; });
      _t = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsed += const Duration(seconds: 1));
        if (_elapsed.inSeconds >= Mino.maxVoiceNoteSec) _stopAndSend();
      });
    } on PlatformException catch (e, st) {
      log.e('voice start', error: e, stackTrace: st);
    }
  }

  Future<void> _stopAndSend() async {
    _t?.cancel();
    final path = _path;
    final dur = _elapsed;
    setState(() { _recording = false; _locked = false; _elapsed = Duration.zero; });
    if (path == null) return;
    final file = File(path);
    if (!await file.exists()) return;
    final bytes = await file.readAsBytes();
    final me = ref.read(authControllerProvider).valueOrNull;
    if (me == null) return;
    try {
      final url = await ref.read(supabaseRepositoryProvider).uploadVoiceNote(widget.chatId, Uint8List.fromList(bytes));
      final msg = Message(
        id: '${me.id}_${DateTime.now().millisecondsSinceEpoch}',
        chatId: widget.chatId,
        senderId: me.id,
        kind: MessageKind.voice,
        attachmentUrl: url,
        attachmentMime: 'audio/m4a',
        attachmentName: 'voice.m4a',
        durationSec: dur.inSeconds,
        createdAt: DateTime.now(),
        status: MessageStatus.sending,
      );
      await ref.read(chatRoomProvider(widget.chatId).notifier).sendAttachment(msg);
      widget.onSent();
    } catch (e, st) {
      log.e('voice upload', error: e, stackTrace: st);
    } finally {
      try { await file.delete(); } catch (_) {}
    }
  }

  Future<void> _cancel() async {
    _t?.cancel();
    try { await _rec.stop(); } catch (_) {}
    if (_path != null) {
      try { await File(_path!).delete(); } catch (_) {}
    }
    setState(() { _recording = false; _locked = false; _elapsed = Duration.zero; _path = null; });
  }

  @override
  Widget build(BuildContext context) {
    if (!_recording) {
      return GestureDetector(
        onLongPressStart: (_) => _start(),
        onLongPressEnd: (_) {
          if (_locked) return;
          _stopAndSend();
        },
        onTap: _start, // tap-to-lock mode
        child: FloatingActionButton.small(
          heroTag: 'voice',
          backgroundColor: MinoColors.primary,
          child: const Icon(Icons.mic, color: Colors.white),
          onPressed: null, // handled by gesture
        ),
      );
    }
    // Recording UI
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: MinoColors.bubbleOut,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulse dot
          Container(
            width: 10, height: 10,
            decoration: const BoxDecoration(color: MinoColors.error, shape: BoxShape.circle),
          ).animate(onPlay: (c) => c.repeat()).fade(duration: 600.ms),
          const SizedBox(width: 8),
          Text(
            '${_elapsed.inMinutes.toString().padLeft(2, '0')}:${(_elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(width: 8),
          // Waveform placeholder
          SizedBox(
            width: 60, height: 18,
            child: CustomPaint(painter: _LiveWavePainter()),
          ),
          const SizedBox(width: 8),
          if (_locked) ...[
            IconButton(
              icon: const Icon(Icons.close, color: MinoColors.error),
              onPressed: _cancel,
            ),
            IconButton(
              icon: const Icon(Icons.send, color: MinoColors.primary),
              onPressed: _stopAndSend,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.delete, color: MinoColors.error),
              onPressed: _cancel,
            ),
            IconButton(
              icon: const Icon(Icons.lock, color: MinoColors.muted),
              onPressed: () => setState(() => _locked = true),
            ),
          ],
        ],
      ),
    );
  }
}

class _LiveWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MinoColors.primary
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final bars = 12;
    final w = size.width / bars;
    for (var i = 0; i < bars; i++) {
      final h = size.height * (0.3 + ((i * 13) % 10) / 14);
      canvas.drawLine(
        Offset(i * w + w / 2, (size.height - h) / 2),
        Offset(i * w + w / 2, (size.height + h) / 2),
        paint,
      );
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
