// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'مينو شات';

  @override
  String get appTagline => 'تحدث بلا حدود.';

  @override
  String welcome(String app) {
    return 'أهلاً بك في $app';
  }

  @override
  String get loginGoogle => 'المتابعة بحساب Google';

  @override
  String get startChatting => 'ابدأ المحادثة';

  @override
  String get setupProfile => 'أعدّ ملفك الشخصي';

  @override
  String get displayName => 'الاسم المعروض';

  @override
  String get bio => 'النبذة (اختياري)';

  @override
  String get chats => 'المحادثات';

  @override
  String get live => 'مباشر';

  @override
  String get mesh => 'شبكة';

  @override
  String get channels => 'القنوات';

  @override
  String get me => 'أنا';

  @override
  String get settings => 'الإعدادات';

  @override
  String get newGroup => 'مجموعة جديدة';

  @override
  String get newChannel => 'قناة جديدة';

  @override
  String get newChat => 'محادثة جديدة';

  @override
  String get messagePlaceholder => 'رسالة…';

  @override
  String get searchUsers => 'ابحث بالاسم أو البريد…';

  @override
  String get send => 'إرسال';

  @override
  String get reply => 'رد';

  @override
  String get forward => 'إعادة توجيه';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get copy => 'نسخ';

  @override
  String get react => 'تفاعل';

  @override
  String get recording => 'جارٍ التسجيل…';

  @override
  String get liveBadge => 'مباشر';

  @override
  String get goLive => 'ابث مباشرة';

  @override
  String get startRoom => 'ابدأ غرفة مباشرة';

  @override
  String listening(int n) {
    return '$n يستمعون';
  }

  @override
  String get raiseHand => 'ارفع يدك';

  @override
  String get leave => 'مغادرة';

  @override
  String get offlineMesh => 'شبكة دون اتصال';

  @override
  String get scanning => 'البحث عن مستخدمي مينو القريبين…';

  @override
  String get noInternet => 'لا إنترنت؟ لا مشكلة.';

  @override
  String get stories => 'القصص';

  @override
  String get addStory => 'أضف إلى القصة';

  @override
  String get postStory => 'انشر القصة';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get readReceipts => 'إيصالات القراءة';

  @override
  String get lastSeen => 'آخر ظهور';

  @override
  String madeBy(String author, String owner) {
    return 'صنعه $author · $owner';
  }
}
