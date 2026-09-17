/// =============================================================
/// Lifex-AI — وحدة الصوت
/// الملف: device_text_to_speech_provider.dart
/// نطق حقيقي عبر محرّك الجهاز. بلا صوت وهمي عند الفشل.
/// =============================================================
library lifex_ai.features.voice.device_text_to_speech_provider;

import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'text_to_speech_manager.dart';
import 'voice_engine.dart';
import 'voice_locale_policy.dart';

class DeviceTextToSpeechProvider implements TextToSpeechProvider {
  DeviceTextToSpeechProvider({
    FlutterTts? tts,
    VoiceLocalePolicy localePolicy = const VoiceLocalePolicy(),
  })  : _tts = tts ?? FlutterTts(),
        _localePolicy = localePolicy;

  final FlutterTts _tts;
  final VoiceLocalePolicy _localePolicy;
  List<String> _cachedLanguages = const [];

  @override
  Future<bool> get isLanguageSupported async {
    final languages = await _languages();
    return languages.isNotEmpty;
  }

  @override
  Future<bool> speak(String text, SpeechSettings settings) async {
    try {
      await _tts.awaitSpeakCompletion(true);
      final languages = await _languages();
      if (languages.isEmpty) return false;
      final locale = _localePolicy.speakCodeForText(
        text: text,
        recognizedLocaleId: VoiceEngine.instance.activeLocaleId,
        availableTts: languages,
      );
      VoiceEngine.instance.activeLocaleId = locale;
      VoiceEngine.instance.signalAr('أردّ بالصوت — $locale');
      await _tts.setLanguage(locale.replaceAll('_', '-'));
      await _tts.setSpeechRate(settings.speechRate.clamp(0.2, 1.0));
      await _tts.setPitch(settings.pitch.clamp(0.5, 2.0));
      final result = await _tts.speak(text);
      return result == 1;
    } on MissingPluginException {
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> stop() => _tts.stop();

  Future<List<String>> _languages() async {
    if (_cachedLanguages.isNotEmpty) return _cachedLanguages;
    try {
      final raw = await _tts.getLanguages;
      if (raw is List) {
        _cachedLanguages = raw.map((item) => item.toString()).toList();
      }
    } catch (_) {
      _cachedLanguages = const [];
    }
    return _cachedLanguages;
  }
}
