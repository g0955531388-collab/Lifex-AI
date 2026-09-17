/// =============================================================
/// Lifex-AI — العائلة
/// الملف: genetics_signal_engine.dart
/// إشارات تقديرية بين ملفات وافقت. ليست تشخيصاً ولا دمج ملفات.
/// =============================================================
library lifex_ai.features.family.genetics_signal_engine;

import '../profile/health_profile.dart';
import '../profile/determination_credential_policy.dart';

class GeneticsSignal {
  const GeneticsSignal({
    required this.messageAr,
    required this.profileIds,
  });

  final String messageAr;
  final List<String> profileIds;
}

class GeneticsSignalEngine {
  List<GeneticsSignal> estimate(List<HealthProfile> optedIn) {
    if (optedIn.length < 2) return const [];

    final signals = <GeneticsSignal>[];
    final byBlood = <String, List<HealthProfile>>{};
    for (final profile in optedIn) {
      if (profile.bloodType == BloodType.unknown) continue;
      byBlood.putIfAbsent(profile.bloodType.name, () => []).add(profile);
    }
    for (final entry in byBlood.entries) {
      if (entry.value.length < 2) continue;
      signals.add(
        GeneticsSignal(
          messageAr:
              'نمط فصيلة تقديري مشترك (${entry.key}) بين ملفات على هذا الجهاز. ليس تشخيصاً ولا دمج ملفات.',
          profileIds: entry.value.map((p) => p.profileId).toList(),
        ),
      );
    }

    final chronic = optedIn
        .where((p) =>
            p.chronicConditions.any((c) => c.isActive) ||
            const DeterminationCredentialPolicy().isRecognized(p))
        .toList();
    if (chronic.length >= 2) {
      signals.add(
        GeneticsSignal(
          messageAr:
              'أكثر من ملف سجّل حالة مزمنة أو إعفاء همم. للتنبيه داخل العائلة فقط. لا قائمة عامة.',
          profileIds: chronic.map((p) => p.profileId).toList(),
        ),
      );
    }

    if (signals.isEmpty) {
      signals.add(
        GeneticsSignal(
          messageAr:
              'لا نمط كافٍ بعد. التقدير يحتاج ملفات مرتبطة دون دمج السير.',
          profileIds: optedIn.map((p) => p.profileId).toList(),
        ),
      );
    }
    return signals;
  }
}
