/// =============================================================
/// Lifex-AI — القران (محرك مستقل)
/// الملف: qiran_engine.dart
/// طلب زواج → موافقة → نتيجة علنية فقط: مناسب/غير مناسب + نسبة.
/// لا كشف لمرض أحد للآخر إلا بطلب لاحق وموافقة صاحب الحالة.
/// =============================================================
library lifex_ai.features.qiran.qiran_engine;

import '../profile/health_profile.dart';
import '../family/marriage_request_ledger.dart';

class QiranVerdict {
  const QiranVerdict({
    required this.ready,
    required this.suitable,
    required this.percent,
    required this.highConflict,
    required this.publicAr,
  });

  final bool ready;
  final bool suitable;
  final int percent;
  final bool highConflict;
  final String publicAr;
}

class QiranEngine {
  const QiranEngine();

  static const suitableAt = 60;
  static const highConflictBelow = 55;

  static const _negatives = {
    BloodType.aNegative,
    BloodType.bNegative,
    BloodType.abNegative,
    BloodType.oNegative,
  };

  QiranVerdict verdict({
    required HealthProfile a,
    required HealthProfile b,
    required MarriageRequest request,
  }) {
    if (request.status != MarriageRequestStatus.accepted ||
        !request.involves(a.profileId) ||
        !request.involves(b.profileId)) {
      return const QiranVerdict(
        ready: false,
        suitable: false,
        percent: 0,
        highConflict: false,
        publicAr:
            'النتيجة لطالب الزواج بعد قبول الطلب فقط. لا نسبة قبل الموافقة.',
      );
    }
    final percent = _percent(a, b);
    final suitable = percent >= suitableAt;
    final highConflict = percent < highConflictBelow;
    return QiranVerdict(
      ready: true,
      suitable: suitable,
      percent: percent,
      highConflict: highConflict,
      publicAr: suitable
          ? 'مناسب — نسبة التناسب $percent٪. بلا ذكر لأي مرض.'
          : 'غير مناسب — نسبة التناسب $percent٪. بلا ذكر لأي مرض.',
    );
  }

  /// الأسباب المانعة تُعرض فقط إن وافق الطرف الآخر على كشف السبب.
  List<String> sealedReasons({
    required HealthProfile a,
    required HealthProfile b,
    required MarriageRequest request,
  }) {
    if (request.reasonAskStatus != MarriageRequestStatus.accepted) {
      return const [];
    }
    if (!request.involves(a.profileId) || !request.involves(b.profileId)) {
      return const [];
    }
    return _factors(a, b);
  }

  bool canAskReason(QiranVerdict verdict) =>
      verdict.ready && (verdict.highConflict || !verdict.suitable);

  int _percent(HealthProfile a, HealthProfile b) {
    var conflict = 0;
    if (a.linkedFamilyProfileIds.contains(b.profileId) ||
        b.linkedFamilyProfileIds.contains(a.profileId)) {
      conflict += 35;
    }
    conflict += _sharedNames(
          a.chronicConditions.where((c) => c.isActive).map((c) => c.conditionName),
          b.chronicConditions.where((c) => c.isActive).map((c) => c.conditionName),
        ).length *
        20;
    final active = a.chronicConditions.where((c) => c.isActive).length +
        b.chronicConditions.where((c) => c.isActive).length;
    conflict += (active * 8).clamp(0, 24);
    if (_rhPair(a.bloodType, b.bloodType)) conflict += 10;
    return (100 - conflict).clamp(0, 100);
  }

  List<String> _factors(HealthProfile a, HealthProfile b) {
    final items = <String>[];
    if (a.linkedFamilyProfileIds.contains(b.profileId) ||
        b.linkedFamilyProfileIds.contains(a.profileId)) {
      items.add('قرابة مسجَّلة بين الملفين. الاستشارة عند مختص إن رغبتما.');
    }
    final shared = _sharedNames(
      a.chronicConditions.where((c) => c.isActive).map((c) => c.conditionName),
      b.chronicConditions.where((c) => c.isActive).map((c) => c.conditionName),
    );
    if (shared.isNotEmpty) {
      items.add('بند صحي مشترك في الملفين استدعى الانتباه. راجعوا طبيباً.');
    }
    if (a.chronicConditions.any((c) => c.isActive) ||
        b.chronicConditions.any((c) => c.isActive)) {
      items.add('وجود حالة مزمنة نشطة عند أحد الطرفين. التفاصيل لصاحب الملف.');
    }
    if (_rhPair(a.bloodType, b.bloodType)) {
      items.add('اختلاف عامل الدم قد يهم الحمل لاحقاً. ليست مانعاً قانونياً هنا.');
    }
    if (items.isEmpty) {
      items.add('لا بند مانع صريح في السجل المحلي. النسبة ليست فتوى زواج.');
    }
    return items;
  }

  bool _rhPair(BloodType x, BloodType y) {
    if (x == BloodType.unknown || y == BloodType.unknown) return false;
    return _negatives.contains(x) != _negatives.contains(y);
  }

  List<String> _sharedNames(Iterable<String> left, Iterable<String> right) {
    final folded = right.map((item) => item.trim().toLowerCase()).toSet();
    return left
        .where((item) => folded.contains(item.trim().toLowerCase()))
        .toSet()
        .toList();
  }
}
