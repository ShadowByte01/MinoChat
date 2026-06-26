import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'app_localizations.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/colors.dart';
import 'core/theme/theme.dart';
import 'core/utils/logger.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await Hive.initFlutter();

    await Supabase.initialize(
      url: Mino.supabaseUrl,
      anonKey: Mino.supabaseAnonKey,
      debug: false,
    );

    try {
      await Firebase.initializeApp();
      await FirebaseMessaging.instance.requestPermission();
      // Save FCM token to users table
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        log.i('FCM token: $token');
      }
    } catch (e) {
      log.w('Firebase init skipped: $e');
    }

    FlutterNativeSplash.remove();
    runApp(const ProviderScope(child: MinoChatApp()));
  } catch (e, st) {
    log.e('bootstrap failed', error: e, stackTrace: st);
    runApp(MaterialApp(
      home: Material(
        child: Center(child: Text('Failed to start Mino Chat: $e')),
      ),
    ));
  }
}

class MinoChatApp extends ConsumerWidget {
  const MinoChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return AdaptiveTheme(
      light: MinoTheme.light(),
      dark: MinoTheme.dark(),
      initial: AdaptiveThemeMode.light,
      builder: (theme, dark) => MaterialApp.router(
        title: Mino.appName,
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: dark,
        routerConfig: router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('hi'),
          Locale('es'),
          Locale('ar'),
        ],
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
      ),
    );
  }
}
