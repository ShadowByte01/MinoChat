// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'मिनो चैट';

  @override
  String get appTagline => 'बिना सीमाओं के चैट करें।';

  @override
  String welcome(String app) {
    return '$app में आपका स्वागत है';
  }

  @override
  String get loginGoogle => 'Google से जारी रखें';

  @override
  String get startChatting => 'चैट शुरू करें';

  @override
  String get setupProfile => 'अपनी प्रोफ़ाइल सेट करें';

  @override
  String get displayName => 'प्रदर्शन नाम';

  @override
  String get bio => 'बायो (वैकल्पिक)';

  @override
  String get chats => 'चैट';

  @override
  String get live => 'लाइव';

  @override
  String get mesh => 'मेश';

  @override
  String get channels => 'चैनल';

  @override
  String get me => 'मैं';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get newGroup => 'नया ग्रुप';

  @override
  String get newChannel => 'नया चैनल';

  @override
  String get newChat => 'नई चैट';

  @override
  String get messagePlaceholder => 'संदेश…';

  @override
  String get searchUsers => 'नाम या ईमेल से खोजें…';

  @override
  String get send => 'भेजें';

  @override
  String get reply => 'जवाब दें';

  @override
  String get forward => 'आगे भेजें';

  @override
  String get delete => 'हटाएं';

  @override
  String get edit => 'संपादित करें';

  @override
  String get copy => 'कॉपी';

  @override
  String get react => 'प्रतिक्रिया';

  @override
  String get recording => 'रिकॉर्डिंग…';

  @override
  String get liveBadge => 'लाइव';

  @override
  String get goLive => 'लाइव जाएं';

  @override
  String get startRoom => 'लाइव रूम शुरू करें';

  @override
  String listening(int n) {
    return '$n सुन रहे हैं';
  }

  @override
  String get raiseHand => 'हाथ उठाएं';

  @override
  String get leave => 'छोड़ें';

  @override
  String get offlineMesh => 'ऑफलाइन मेश';

  @override
  String get scanning => 'पास के मिनो पीयर्स की तलाश…';

  @override
  String get noInternet => 'इंटरनेट नहीं? कोई बात नहीं।';

  @override
  String get stories => 'स्टोरीज़';

  @override
  String get addStory => 'स्टोरी में जोड़ें';

  @override
  String get postStory => 'स्टोरी पोस्ट करें';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get readReceipts => 'पढ़ने की रसीदें';

  @override
  String get lastSeen => 'अंतिम बार देखा';

  @override
  String madeBy(String author, String owner) {
    return '$author द्वारा बनाई गई · $owner';
  }
}
