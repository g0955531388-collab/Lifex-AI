/// =============================================================
/// Lifex-AI — وحدة الصوت
/// الملف: start_listen_signal.dart
/// إشارة البدء: نغمة و/أو جملة نطق بلغة الجهاز أو المتحدث.
/// =============================================================
library lifex_ai.features.voice.start_listen_signal;

import 'package:flutter/services.dart';

import 'hardware_cue_calibrator.dart';
import 'voice_engine.dart';

class StartListenSignal {
  const StartListenSignal();

  static const _channel = MethodChannel('lifex_ai/hardware_cue');

  String spokenCue({required bool arabic}) =>
      arabic ? 'تفضّل، أسمعك.' : "Go ahead. I'm listening.";

  Future<void> play({
    required StartSignalKind kind,
    required bool arabic,
  }) async {
    if (kind == StartSignalKind.tone || kind == StartSignalKind.both) {
      await HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.click);
      try {
        await _channel.invokeMethod<void>('playTone');
      } on MissingPluginException {
        // النغمة الأصلية على أندرويد. على المنصات الأخرى يبقى النقر والنطق.
      }
    }
    if (kind == StartSignalKind.voice || kind == StartSignalKind.both) {
      await VoiceEngine.instance.speak(spokenCue(arabic: arabic));
    }
  }
}
