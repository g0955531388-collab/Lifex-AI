/// =============================================================
/// Lifex-AI — وحدة الصوت
/// الملف: emergency_voice_handler.dart
/// طوارئ صوتية بموافقة. بلا تصنيف عشوائي وبلا أرشيف فيديو وبلا إرسال وهمي.
/// =============================================================
library lifex_ai.features.voice.emergency_voice_handler;

class EmergencyVoiceHandler {
  const EmergencyVoiceHandler();

  bool get mayArchiveVideoOrStills => false;
  bool get mayUseSimulatedAudioClassifier => false;
  bool get mayInventGps => false;

  String prompt({required bool arabic}) => arabic
      ? 'هل تسمعني؟ قل «نعم» لتسجيل حالة على هذا الجهاز، أو «أنا بخير» للإلغاء. '
          '«اتصل» أو «أرسل» تُسجَّل محلياً. الإرسال الخارجي غير مربوط بعد.'
      : 'Can you hear me? Say yes to record a local case, or I am fine to cancel. '
          'Call or send stay local. Outbound is not bound yet.';

  String noReply({required bool arabic}) => arabic
      ? 'لا رد صوتي. التنبيه يبقى على الجهاز حتى تؤكد. لن أرسل دون موافقتك.'
      : 'No spoken reply. The alert stays on this device until you confirm.';

  String cancelAr() =>
      'رُفع الإنذار محلياً. لم يُلتقط فيديو ولم تُرسل رسالة.';

  String escalateAr() =>
      'سُجّل طلب الاتصال أو الرسالة على هذا الجهاز. القناة الخارجية غير مربوطة. '
      'لن أتصل بـ 112 ولن أرسل SMS حتى توجد قناة حقيقية.';

  bool isAffirmative(String text) {
    final folded = text.trim().toLowerCase();
    return [
      'نعم',
      'أجل',
      'أكيد',
      'yes',
      'yeah',
      'oui',
      'si',
      'sí',
    ].any(folded.contains);
  }

  bool isCancel(String text) {
    final folded = text.trim().toLowerCase();
    return [
      'أنا بخير',
      'انا بخير',
      'تمام',
      'ألغ',
      'الغ',
      'i am fine',
      "i'm fine",
    ].any(folded.contains);
  }

  bool isEscalate(String text) {
    final folded = text.trim().toLowerCase();
    return [
      'اتصل',
      'اتصال',
      'أرسل',
      'ارسل',
      'رسالة',
      'call',
      'send',
    ].any(folded.contains);
  }
}
