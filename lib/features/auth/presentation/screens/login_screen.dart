import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/colors.dart';
import '../controllers/auth_controller.dart';

/// Login screen — Google Sign-In only.
/// Big primary CTA, tiny credit at the bottom.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Center(
                child: Image.asset('assets/images/logo.png', width: 116, height: 116),
              ).animate().scale(duration: 500.ms, begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
              const SizedBox(height: 20),
              Text('Welcome to ${Mino.appName}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: MinoColors.onBackground,
                ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 8),
              const Text(
                'Sign in with Google to start chatting, calling, going live, and sharing — online or completely offline.',
                textAlign: TextAlign.center,
                style: TextStyle(color: MinoColors.muted, fontSize: 14, height: 1.5),
              ).animate().fade(delay: 300.ms),
              const Spacer(flex: 3),
              _GoogleButton(
                loading: auth.isLoading,
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).signInWithGoogle();
                  final u = ref.read(authControllerProvider).valueOrNull;
                  if (u != null) {
                    if (u.displayName.isEmpty || u.displayName == u.email?.split('@').first) {
                      context.go('/profile-setup');
                    } else {
                      context.go('/home');
                    }
                  }
                },
              ),
              const SizedBox(height: 18),
              Text(
                'By continuing you agree to our Terms & Privacy.\nMino Chat is open source — MIT licensed.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: MinoColors.muted, fontSize: 11, height: 1.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Made by ${Mino.author} · ${Mino.owner}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: MinoColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;
  const _GoogleButton({required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: MinoColors.onBackground,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: MinoColors.outline, width: 0.8),
        ),
      ),
      icon: loading
          ? const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: MinoColors.primary),
            )
          : const _GoogleLogo(size: 22),
      label: const Text('Continue with Google',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  final double size;
  const _GoogleLogo({required this.size});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final p = Paint()..style = PaintingStyle.fill;
    // 4-color G — approximate
    final c = (double r, double g, double b, double a) => Color.fromARGB((a * 255).toInt(), r.toInt(), g.toInt(), b.toInt());
    final arcs = [
      (c(66, 133, 244, 1), -45.0, 45.0),    // blue (top-right)
      (c(52, 168, 83, 1), 45.0, 135.0),     // green (bottom-right)
      (c(251, 188, 4, 1), 135.0, 225.0),    // yellow (bottom-left)
      (c(234, 67, 53, 1), 225.0, 315.0),    // red (top-left)
    ];
    final center = Offset(s / 2, s / 2);
    final outer = s / 2;
    final stroke = s * 0.18;
    final rect = Rect.fromCircle(center: center, radius: outer - stroke / 2);
    for (final (color, start, end) in arcs) {
      p.color = color;
      canvas.drawArc(rect, start * 3.14159 / 180, (end - start) * 3.14159 / 180, false, p..strokeWidth = stroke..style = PaintingStyle.stroke);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
