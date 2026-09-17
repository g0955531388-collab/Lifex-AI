/// =============================================================
/// Lifex-AI — وحدة الصوت
/// الملف: hardware_cue_host.dart
/// يفتح الاستماع من الزر المعاير عبر الملاح الموحّد. بلا Device Admin.
/// =============================================================
library lifex_ai.features.voice.hardware_cue_host;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_navigator.dart';
import '../../screens/voice_control_screen.dart';
import 'hardware_cue_bridge.dart';
import 'start_listen_signal.dart';

class HardwareCueHost {
  HardwareCueHost._();

  static void bind() {
    HardwareCueBridge.instance.onCueFired = fire;
  }

  static void fire() {
    unawaited(_fire());
  }

  static Future<void> _fire() async {
    final calibrator = HardwareCueBridge.instance.calibrator;
    if (calibrator.powerButtonIsSystemOwned) {
      return;
    }
    await const StartListenSignal().play(
      kind: calibrator.startSignal,
      arabic: true,
    );
    if (VoiceControlScreen.requestListenIfOpen()) {
      return;
    }
    final nav = LifexNavigator.key.currentState;
    if (nav == null) return;
    await nav.push(
      MaterialPageRoute(
        builder: (_) => const VoiceControlScreen(listenOnOpen: true),
      ),
    );
  }
}
