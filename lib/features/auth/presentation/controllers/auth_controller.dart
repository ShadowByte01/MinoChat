import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/logger.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/supabase_repository.dart';

/// Google-only auth controller.
/// No OTP, no email/password, no phone — just Google Sign-In.
class AuthController extends Notifier<AsyncValue<MinoUser?>> {
  late final SupabaseRepository _repo;

  @override
  AsyncValue<MinoUser?> build() {
    _repo = ref.watch(supabaseRepositoryProvider);
    final current = ref.read(supabaseProvider).auth.currentUser;
    if (current != null) {
      _repo.fetchUser(current.id).then((u) {
        if (u != null) state = AsyncValue.data(u);
      });
    }
    return const AsyncValue.loading();
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final google = GoogleSignIn(
        serverClientId: Mino.googleWebClientId,
        scopes: const ['email', 'profile', 'openid'],
      );
      final account = await google.signIn();
      if (account == null) {
        state = const AsyncValue.data(null);
        return;
      }
      final auth = await account.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken;
      if (idToken == null || accessToken == null) {
        throw const AuthFailure('Google returned no idToken. Check OAuth client ID.');
      }
      final user = await _repo.signInWithGoogleIdToken(
        idToken: idToken,
        accessToken: accessToken,
      );
      state = AsyncValue.data(user);
    } on AuthFailure {
      rethrow;
    } catch (e, st) {
      log.e('signInWithGoogle', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    final u = await _repo.fetchUser(ref.read(supabaseProvider).auth.currentUser!.id);
    if (u != null) state = AsyncValue.data(u);
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _repo.signOut();
    state = const AsyncValue.data(null);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<MinoUser?>>(AuthController.new);

final isAuthenticatedProvider = Provider<bool>((ref) {
  final v = ref.watch(authControllerProvider);
  return v.maybeWhen(data: (u) => u != null, orElse: () => false);
});
