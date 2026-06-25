import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/colors.dart';
import '../../../data/supabase/supabase_provider.dart';
import '../controllers/auth_controller.dart';

/// First screen — minimal splash with logo + brand.
/// Decides whether to push to /login or /home based on session state.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    final sb = ref.read(supabaseProvider);
    if (sb.auth.currentUser != null) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: MinoGradients.splash),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 132, height: 132)
                  .animate()
                  .scale(duration: 600.ms, begin: const Offset(0.7, 0.7), end: const Offset(1, 1))
                  .fade(duration: 600.ms),
              const SizedBox(height: 24),
              Text(Mino.appName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: MinoColors.onBackground,
                  letterSpacing: -0.5,
                ),
              ).animate().fade(delay: 300.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 6),
              Text(Mino.appTagline,
                style: const TextStyle(color: MinoColors.muted, fontSize: 14),
              ).animate().fade(delay: 500.ms, duration: 500.ms),
              const SizedBox(height: 48),
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: MinoColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
