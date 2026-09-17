/// =============================================================
/// Lifex-AI — الطاقة والاستدامة
/// الملف: intermittent_sense_policy.dart
/// نبض تشغيل/سكون للمستشعرات. ليس قراءة حيوية وهمية ولا نسخاً من Kotlin.
/// =============================================================
library lifex_ai.features.energy.intermittent_sense_policy;

class IntermittentSensePolicy {
  const IntermittentSensePolicy({
    this.active = const Duration(seconds: 5),
    this.sleep = const Duration(seconds: 30),
  });

  final Duration active;
  final Duration sleep;

  Duration get cycle => active + sleep;

  /// هل الزمن الحالي داخل نافذة التشغيل من دورة النبض؟
  bool shouldSample({
    required DateTime now,
    required DateTime cycleAnchor,
  }) {
    final span = cycle.inMilliseconds;
    if (span <= 0) return false;
    final elapsed = now.difference(cycleAnchor).inMilliseconds;
    final phase = elapsed % span;
    return phase < active.inMilliseconds;
  }
}
