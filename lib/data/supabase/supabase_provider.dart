import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';

/// Single Supabase client for the whole app.
/// Initializes on app boot via [MinoBootstrap] in main.dart.

final supabaseProvider = Provider<SupabaseClient>((ref) {
  // Already initialized in main(). Just return the singleton.
  return Supabase.instance.client;
});

/// Convenience: current user id or null
final currentUserIdProvider = StreamProvider<String?>((ref) async* {
  final sb = ref.watch(supabaseProvider);
  yield sb.auth.currentUser?.id;
  yield* sb.auth.onAuthStateChanged.map((e) => e.session?.user.id);
});

/// Convenience: current session
final currentSessionProvider = StreamProvider<Session?>((ref) async* {
  final sb = ref.watch(supabaseProvider);
  yield sb.auth.currentSession;
  yield* sb.auth.onAuthStateChanged.map((e) => e.session);
});
