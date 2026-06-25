// This is a generated file; do not edit by hand.
// In a real build, Flutter generates this automatically from l10n/*.arb files
// via `flutter gen-l10n`. For convenience we provide a minimal stub here so
// the project compiles even before code-gen runs.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);
  final Locale locale;
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? AppLocalizations(const Locale('en'));
  }
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  static const supportedLocales = [Locale('en'), Locale('hi'), Locale('es'), Locale('ar')];

  // Strings — keep in sync with l10n/app_en.arb
  String get appName => 'Mino Chat';
  String get appTagline => 'Chat without limits.';
  String welcome(String app) => 'Welcome to $app';
  String get loginGoogle => 'Continue with Google';
  String get startChatting => 'Start chatting';
  String get setupProfile => 'Set up your profile';
  String get displayName => 'Display name';
  String get bio => 'Bio (optional)';
  String get chats => 'Chats';
  String get live => 'Live';
  String get mesh => 'Mesh';
  String get channels => 'Channels';
  String get me => 'Me';
  String get settings => 'Settings';
  String get newGroup => 'New group';
  String get newChannel => 'New channel';
  String get newChat => 'New chat';
  String get messagePlaceholder => 'Message…';
  String get searchUsers => 'Search by name or email…';
  String get send => 'Send';
  String get reply => 'Reply';
  String get forward => 'Forward';
  String get delete => 'Delete';
  String get edit => 'Edit';
  String get copy => 'Copy';
  String get react => 'React';
  String get recording => 'Recording…';
  String get liveBadge => 'LIVE';
  String get goLive => 'Go Live';
  String get startRoom => 'Start a Live room';
  String listening(int n) => '$n listening';
  String get raiseHand => 'Raise hand';
  String get leave => 'Leave';
  String get offlineMesh => 'Offline Mesh';
  String get scanning => 'Scanning for nearby Mino peers…';
  String get noInternet => 'No internet? No problem.';
  String get stories => 'Stories';
  String get addStory => 'Add to story';
  String get postStory => 'Post story';
  String get signOut => 'Sign out';
  String get darkMode => 'Dark mode';
  String get readReceipts => 'Read receipts';
  String get lastSeen => 'Last seen';
  String madeBy(String author, String owner) => 'Made by $author · $owner';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) =>
      ['en', 'hi', 'es', 'ar'].contains(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
