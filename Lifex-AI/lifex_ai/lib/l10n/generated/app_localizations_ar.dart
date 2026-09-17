import 'app_localizations.dart';

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Lifex-AI';

  @override
  String get homeMyHealthProfile => 'ملفي الصحي';

  @override
  String get homeMyMedications => 'أدويتي';

  @override
  String get homeMyAppointments => 'مواعيدي';

  @override
  String get homeEmergency => 'طوارئ';

  @override
  String get emergencyConfirmTitle => 'تأكيد حالة طوارئ';

  @override
  String get emergencyConfirmBody => 'ستُسجَّل حالة طوارئ على هذا الجهاز. الإرسال لجهات الثقة يحتاج قناة SMS أو دفع حقيقية. هل تريد المتابعة؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirmEmergency => 'تأكيد الطوارئ';

  @override
  String get emergencyAlertSent => 'سُجّلت حالة الطوارئ على هذا الجهاز. الإرسال الخارجي غير مربوط بعد.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsDarkMode => 'الوضع الليلي';

  @override
  String get settingsVoiceGuidance => 'الإرشاد الصوتي';

  @override
  String get settingsVoiceGuidanceSubtitle => 'قراءة التنبيهات صوتياً تلقائياً';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsPrivacy => 'إعدادات الخصوصية';

  @override
  String get settingsPrivacySubtitle => 'التحكم بمن يرى بياناتك الصحية';

  @override
  String get settingsFamilyManagement => 'إدارة أفراد العائلة';

  @override
  String get settingsMedicalUpdateSectionTitle => 'تحديث وتوسيع المحتوى الطبي';

  @override
  String get settingsMedicalUpdateSectionBody => 'قاعدة البيانات الطبية تعمل بالكامل دون إنترنت. يمكنك التحقق من وجود توسعات جديدة وتحميلها عند توفر اتصال.';

  @override
  String get settingsCheckForUpdates => 'التحقق من وجود تحديثات';

  @override
  String get settingsDownloadUpdate => 'تنزيل التحديث';

  @override
  String get settingsAbout => 'حول التطبيق';

  @override
  String get noHealthProfileLoaded => 'لا يوجد ملف صحي محمَّل حالياً.';

  @override
  String get accessibilityHomeButton => 'الشاشة الرئيسية';

  @override
  String get accessibilityEmergencyButton => 'زر الطوارئ. اضغط ضغطاً مزدوجاً لتسجيل حالة طوارئ على هذا الجهاز. الإرسال الخارجي غير مربوط بعد';

  @override
  String get accessibilitySettingsButton => 'زر الإعدادات';
}
