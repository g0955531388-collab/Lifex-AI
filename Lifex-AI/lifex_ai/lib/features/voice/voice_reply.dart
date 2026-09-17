/// =============================================================
/// Lifex-AI — وحدة الصوت
/// الملف: voice_reply.dart
/// الرد بلغة المتحدث بعد اكتشافها، كما في سيناريو المحرك اللغوي.
/// =============================================================
library lifex_ai.features.voice.voice_reply;

class VoiceReply {
  const VoiceReply({required this.ar, required this.en});

  final String ar;
  final String en;

  String of(String languageCode) =>
      languageCode.toLowerCase().startsWith('ar') ? ar : en;
}
