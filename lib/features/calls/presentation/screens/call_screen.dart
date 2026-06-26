import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mino_chat/core/theme/colors.dart';

/// 1:1 / group call screen.
/// Video via WebRTC (flutter_webrtc), audio-only fallback.
class CallScreen extends ConsumerStatefulWidget {
  final String callId;
  const CallScreen({super.key, required this.callId});
  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  bool _mic = true;
  bool _cam = false;
  bool _speaker = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinoColors.backgroundDark,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote video / audio placeholder
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 140, height: 140,
                    decoration: const BoxDecoration(
                      gradient: MinoGradients.primaryButton,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 80),
                  ),
                  const SizedBox(height: 16),
                  const Text('Mino user',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(widget.callId,
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 4),
                  const Text('calling…',
                    style: TextStyle(color: MinoColors.secondary, fontSize: 13)),
                ],
              ),
            ),
            // Self view (PiP)
            Positioned(
              top: 16, right: 16,
              child: Container(
                width: 100, height: 140,
                decoration: BoxDecoration(
                  color: MinoColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: MinoColors.outlineDark, width: 1),
                ),
                child: const Icon(Icons.videocam_off, color: Colors.white54),
              ),
            ),
            // Controls
            Positioned(
              bottom: 24, left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: 'mic',
                    backgroundColor: _mic ? MinoColors.surfaceDark : MinoColors.error,
                    onPressed: () => setState(() => _mic = !_mic),
                    child: Icon(_mic ? Icons.mic : Icons.mic_off, color: Colors.white),
                  ),
                  FloatingActionButton(
                    heroTag: 'cam',
                    backgroundColor: _cam ? MinoColors.primary : MinoColors.surfaceDark,
                    onPressed: () => setState(() => _cam = !_cam),
                    child: Icon(_cam ? Icons.videocam : Icons.videocam_off, color: Colors.white),
                  ),
                  FloatingActionButton(
                    heroTag: 'speaker',
                    backgroundColor: _speaker ? MinoColors.primary : MinoColors.surfaceDark,
                    onPressed: () => setState(() => _speaker = !_speaker),
                    child: Icon(_speaker ? Icons.volume_up : Icons.volume_off, color: Colors.white),
                  ),
                  FloatingActionButton(
                    heroTag: 'end',
                    backgroundColor: MinoColors.error,
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.call_end, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
