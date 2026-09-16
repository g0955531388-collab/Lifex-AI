import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'Lifex-AI'**
  String get appTitle;

  /// No description provided for @homeMyHealthProfile.
  ///
  /// In ar, this message translates to:
  /// **'ملفي الصحي'**
  String get homeMyHealthProfile;

  /// No description provided for @homeMyMedications.
  ///
  /// In ar, this message translates to:
  /// **'أدويتي'**
  String get homeMyMedications;

  /// No description provided for @homeMyAppointments.
  ///
  /// In ar, this message translates to:
  /// **'مواعيدي'**
  String get homeMyAppointments;

  /// No description provided for @homeEmergency.
  ///
  /// In ar, this message translates to:
  /// **'طوارئ'**
  String get homeEmergency;

  /// No description provided for @emergencyConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد حالة طوارئ'**
  String get emergencyConfirmTitle;

  /// No description provided for @emergencyConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إبلاغ جهات الثقة المسجَّلة لديك فوراً. هل تريد المتابعة؟'**
  String get emergencyConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @confirmEmergency.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الطوارئ'**
  String get confirmEmergency;

  /// No description provided for @emergencyAlertSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال تنبيه الطوارئ لجهات الثقة.'**
  String get emergencyAlertSent;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @settingsDarkMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الليلي'**
  String get settingsDarkMode;

  /// No description provided for @settingsVoiceGuidance.
  ///
  /// In ar, this message translates to:
  /// **'الإرشاد الصوتي'**
  String get settingsVoiceGuidance;

  /// No description provided for @settingsVoiceGuidanceSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قراءة التنبيهات صوتياً تلقائياً'**
  String get settingsVoiceGuidanceSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get settingsLanguage;

  /// No description provided for @settingsPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الخصوصية'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'التحكم بمن يرى بياناتك الصحية'**
  String get settingsPrivacySubtitle;

  /// No description provided for @settingsFamilyManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة أفراد العائلة'**
  String get settingsFamilyManagement;

  /// No description provided for @settingsMedicalUpdateSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحديث وتوسيع المحتوى الطبي'**
  String get settingsMedicalUpdateSectionTitle;

  /// No description provided for @settingsMedicalUpdateSectionBody.
  ///
  /// In ar, this message translates to:
  /// **'قاعدة البيانات الطبية تعمل بالكامل دون إنترنت. يمكنك التحقق من وجود توسعات جديدة وتحميلها عند توفر اتصال.'**
  String get settingsMedicalUpdateSectionBody;

  /// No description provided for @settingsCheckForUpdates.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من وجود تحديثات'**
  String get settingsCheckForUpdates;

  /// No description provided for @settingsDownloadUpdate.
  ///
  /// In ar, this message translates to:
  /// **'تنزيل التحديث'**
  String get settingsDownloadUpdate;

  /// No description provided for @settingsAbout.
  ///
  /// In ar, this message translates to:
  /// **'حول التطبيق'**
  String get settingsAbout;

  /// No description provided for @noHealthProfileLoaded.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد ملف صحي محمَّل حالياً.'**
  String get noHealthProfileLoaded;

  /// No description provided for @accessibilityHomeButton.
  ///
  /// In ar, this message translates to:
  /// **'الشاشة الرئيسية'**
  String get accessibilityHomeButton;

  /// No description provided for @accessibilityEmergencyButton.
  ///
  /// In ar, this message translates to:
  /// **'زر الطوارئ. اضغط ضغطاً مزدوجاً لتفعيل حالة طوارئ فورية'**
  String get accessibilityEmergencyButton;

  /// No description provided for @accessibilitySettingsButton.
  ///
  /// In ar, this message translates to:
  /// **'زر الإعدادات'**
  String get accessibilitySettingsButton;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
