import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Lifex-AI';

  @override
  String get homeMyHealthProfile => 'My Health Profile';

  @override
  String get homeMyMedications => 'My Medications';

  @override
  String get homeMyAppointments => 'My Appointments';

  @override
  String get homeEmergency => 'Emergency';

  @override
  String get emergencyConfirmTitle => 'Confirm Emergency';

  @override
  String get emergencyConfirmBody => 'Your trusted contacts will be notified immediately. Continue?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmEmergency => 'Confirm Emergency';

  @override
  String get emergencyAlertSent => 'Emergency alert sent to your trusted contacts.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsVoiceGuidance => 'Voice Guidance';

  @override
  String get settingsVoiceGuidanceSubtitle => 'Automatically read alerts aloud';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsPrivacy => 'Privacy Settings';

  @override
  String get settingsPrivacySubtitle => 'Control who can see your health data';

  @override
  String get settingsFamilyManagement => 'Manage Family Members';

  @override
  String get settingsMedicalUpdateSectionTitle => 'Update Medical Content';

  @override
  String get settingsMedicalUpdateSectionBody => 'The medical database works fully offline. You can check for new expansions and download them when connected.';

  @override
  String get settingsCheckForUpdates => 'Check for Updates';

  @override
  String get settingsDownloadUpdate => 'Download Update';

  @override
  String get settingsAbout => 'About';

  @override
  String get noHealthProfileLoaded => 'No health profile loaded yet.';

  @override
  String get accessibilityHomeButton => 'Home screen';

  @override
  String get accessibilityEmergencyButton => 'Emergency button. Double tap to trigger an immediate emergency alert';

  @override
  String get accessibilitySettingsButton => 'Settings button';
}
