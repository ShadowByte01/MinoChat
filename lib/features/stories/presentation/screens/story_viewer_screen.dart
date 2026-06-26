import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mino_chat/core/theme/colors.dart';

class StoryViewerScreen extends ConsumerStatefulWidget {
  final String userId;
  const StoryViewerScreen({super.key, required this.userId});
  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (d) {
          final w = MediaQuery.of(context).size.width;
          if (d.globalPosition.dx < w / 2) {
            setState(() => _index = (_index - 1).clamp(0, 4));
          } else {
            setState(() => _index = (_index + 1).clamp(0, 4));
          }
        },
        onLongPress: () {},
        child: Stack(
          children: [
            Center(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: MinoGradients.storyRing,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/logo.png', width: 120, height: 120),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Story placeholder — wire to Supabase storage to display the story media.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Progress bars
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 8, right: 8,
              child: Row(
                children: List.generate(5, (i) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: i <= _index ? Colors.white : Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 24,
              left: 12, right: 12,
              child: Row(
                children: [
                  const CircleAvatar(radius: 16, backgroundColor: MinoColors.primaryContainer,
                    child: Icon(Icons.person, size: 18, color: MinoColors.primary)),
                  const SizedBox(width: 8),
                  Text(widget.userId,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
