// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Mino Chat';

  @override
  String get appTagline => 'Chat without limits.';

  @override
  String welcome(String app) {
    return 'Welcome to $app';
  }

  @override
  String get loginGoogle => 'Continue with Google';

  @override
  String get startChatting => 'Start chatting';

  @override
  String get setupProfile => 'Set up your profile';

  @override
  String get displayName => 'Display name';

  @override
  String get bio => 'Bio (optional)';

  @override
  String get chats => 'Chats';

  @override
  String get live => 'Live';

  @override
  String get mesh => 'Mesh';

  @override
  String get channels => 'Channels';

  @override
  String get me => 'Me';

  @override
  String get settings => 'Settings';

  @override
  String get newGroup => 'New group';

  @override
  String get newChannel => 'New channel';

  @override
  String get newChat => 'New chat';

  @override
  String get messagePlaceholder => 'Message…';

  @override
  String get searchUsers => 'Search by name or email…';

  @override
  String get send => 'Send';

  @override
  String get reply => 'Reply';

  @override
  String get forward => 'Forward';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get copy => 'Copy';

  @override
  String get react => 'React';

  @override
  String get recording => 'Recording…';

  @override
  String get liveBadge => 'LIVE';

  @override
  String get goLive => 'Go Live';

  @override
  String get startRoom => 'Start a Live room';

  @override
  String listening(int n) {
    return '$n listening';
  }

  @override
  String get raiseHand => 'Raise hand';

  @override
  String get leave => 'Leave';

  @override
  String get offlineMesh => 'Offline Mesh';

  @override
  String get scanning => 'Scanning for nearby Mino peers…';

  @override
  String get noInternet => 'No internet? No problem.';

  @override
  String get stories => 'Stories';

  @override
  String get addStory => 'Add to story';

  @override
  String get postStory => 'Post story';

  @override
  String get signOut => 'Sign out';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get readReceipts => 'Read receipts';

  @override
  String get lastSeen => 'Last seen';

  @override
  String madeBy(String author, String owner) {
    return 'Made by $author · $owner';
  }
}
