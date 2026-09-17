/// =============================================================
/// Lifex-AI — المراقبة الصحية
/// الملف: clinical_watch_bridge.dart
/// تشغيل/إيقاف خدمة إشعار ظاهرة. ليست خدمة خفية.
/// =============================================================
library lifex_ai.features.voice.clinical_watch_bridge;

import 'package:flutter/services.dart';

class ClinicalWatchBridge {
  ClinicalWatchBridge._();
  static final ClinicalWatchBridge instance = ClinicalWatchBridge._();

  static const _channel = MethodChannel('lifex_ai/clinical_watch');

  Future<String> start({required bool cameraLiveNoStore}) async {
    try {
      final result = await _channel.invokeMethod<String>('start', {
        'camera': cameraLiveNoStore,
      });
      return result ?? 'بدأ الإشعار الظاهر للمراقبة الصحية.';
    } on MissingPluginException {
      return 'لا توجد خدمة نظام على هذه المنصة. المراقبة تبقى على الشاشة المفتوحة.';
    } catch (error) {
      return 'تعذّر بدء إشعار المراقبة: $error';
    }
  }

  Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stop');
    } on MissingPluginException {
      return;
    }
  }
}
