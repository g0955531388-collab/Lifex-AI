// =============================================================
// Lifex-AI — اختبارات الوحدة
// الملف: voice_pipeline_test.dart
// =============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:lifex_ai/features/voice/speech_to_text_processor.dart';
import 'package:lifex_ai/features/voice/text_to_speech_manager.dart';
import 'package:lifex_ai/features/voice/voice_engine.dart';
import 'package:lifex_ai/features/voice/voice_locale_policy.dart';
import 'package:lifex_ai/features/voice/wake_word_detector.dart';

class _FakeSpeech implements SpeechToTextProvider {
  _FakeSpeech(this.result);
  final SpeechRecognitionResult result;
  String? lastLocale;

  @override
  Future<SpeechRecognitionResult> listenOnce({String localeCode = 'ar'}) async {
    lastLocale = localeCode;
    return result;
  }

  @override
  Future<bool> requestMicrophonePermission() async => true;

  @override
  Future<void> stop() async {}
}

class _FakeTts implements TextToSpeechProvider {
  String? lastLocale;
  String? lastText;

  @override
  Future<bool> get isLanguageSupported async => true;

  @override
  Future<bool> speak(String text, SpeechSettings settings) async {
    lastText = text;
    lastLocale = settings.localeCode;
    return true;
  }

  @override
  Future<void> stop() async {}
}

void main() {
  test('يطابق أقرب لغة متاحة على الجهاز', () {
    const policy = VoiceLocalePolicy();
    expect(
      policy.matchAvailable(
        preferred: 'ar_SY',
        available: ['ar_SA', 'en_US'],
      ),
      'ar_SA',
    );
    expect(
      policy.matchAvailable(
        preferred: 'fr_FR',
        available: ['en_GB', 'fr_CA'],
      ),
      'fr_CA',
    );
  });

  test('نطق النص العربي يفضّل ar إن وُجد', () {
    const policy = VoiceLocalePolicy();
    expect(
      policy.speakCodeForText(
        text: 'افتح ملفي الصحي',
        availableTts: ['en-US', 'ar-SA'],
      ),
      'ar-SA',
    );
  });

  test('الاستماع المربوط يعيد النص ولا يصمت', () async {
    final engine = VoiceEngine.instance;
    final speech = _FakeSpeech(
      const SpeechRecognitionResult(
        status: SpeechRecognitionStatus.success,
        recognizedText: 'افتح الصيدلية',
      ),
    );
    SpeechToTextProcessor(provider: speech).registerWithVoiceEngine(engine);
    TextToSpeechManager(provider: _FakeTts()).registerWithVoiceEngine(engine);

    final heard = await engine.startListening();
    expect(heard.success, isTrue);
    expect(heard.textResult, 'افتح الصيدلية');

    final spoken = await engine.speak('سمعتك');
    expect(spoken.success, isTrue);
  });

  test('كلمة التنبيه تُلتقط وتُزال', () {
    final detector = WakeWordDetector();
    expect(detector.containsWakeWord('ليفكس، أين أقرب طبيب؟'), isTrue);
    expect(detector.strip('ليفكس، أين أقرب طبيب؟'), 'أين أقرب طبيب؟');
    expect(detector.strip('Lifex, open pharmacy'), 'open pharmacy');
  });
}
