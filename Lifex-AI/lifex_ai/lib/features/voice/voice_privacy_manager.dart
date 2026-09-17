/// =============================================================
/// Lifex-AI — وحدة الصوت
/// الملف: voice_privacy_manager.dart
/// متى يعمل الميكروفون، وهل يُحفظ النص. ليست تجسساً في الخلفية.
/// =============================================================
library lifex_ai.features.voice.voice_privacy_manager;

class VoicePrivacyManager {
  VoicePrivacyManager._();
  static final VoicePrivacyManager instance = VoicePrivacyManager._();

  /// موافقة داخل التطبيق على استخدام الميكروفون لهذه الجلسة.
  bool microphoneAllowed = false;

  /// حفظ نصوص الأوامر على الشاشة فقط ما لم يُفعَّل.
  bool storeTranscripts = false;

  /// أذن رقمية أثناء فتح شاشة الصوت فقط — ليست تسجيلاً بعد إغلاقها.
  bool screenEarEnabled = false;

  /// لا يُرسل مقطع صوتي لأي خادم من هذه الطبقة.
  bool get sendsAudioOffDevice => false;
}
