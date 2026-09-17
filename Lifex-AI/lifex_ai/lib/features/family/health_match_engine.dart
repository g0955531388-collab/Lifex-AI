/// =============================================================
/// Lifex-AI — الأسرة والمجتمع
/// الملف: health_match_engine.dart
/// محرك صغير: توافق صحي بعد موافقة الطرفين. يخدم المجتمع بالتوعية
/// لا بالحكم على الزواج ولا بفحص جيني مختلق.
/// =============================================================
library lifex_ai.features.family.health_match_engine;

import '../profile/health_profile.dart';
import 'marriage_request_ledger.dart';

class HealthMatchNote {
  const HealthMatchNote({required this.titleAr, required this.bodyAr});

  final String titleAr;
  final String bodyAr;
}

class HealthMatchReport {
  const HealthMatchReport({
    required this.allowed,
    required this.notes,
    required this.attentionCount,
    required this.summaryAr,
  });

  final bool allowed;
  final List<HealthMatchNote> notes;
  final int attentionCount;
  final String summaryAr;
}

class HealthMatchEngine {
  const HealthMatchEngine();

  static const _negatives = {
    BloodType.aNegative,
    BloodType.bNegative,
    BloodType.abNegative,
    BloodType.oNegative,
  };

  HealthMatchReport compare({
    required HealthProfile a,
    required HealthProfile b,
    required MarriageRequest request,
  }) {
    if (request.status != MarriageRequestStatus.accepted) {
      return const HealthMatchReport(
        allowed: false,
        notes: [],
        attentionCount: 0,
        summaryAr:
            'لا حساب توافق قبل وصول الطلب وموافقة من أُرسل إليها. الخصوصية أولاً.',
      );
    }
    if (!request.involves(a.profileId) || !request.involves(b.profileId)) {
      return const HealthMatchReport(
        allowed: false,
        notes: [],
        attentionCount: 0,
        summaryAr: 'هذان الملفان ليسا طرفي هذا الطلب.',
      );
    }

    final notes = <HealthMatchNote>[];

    notes.add(
      HealthMatchNote(
        titleAr: 'الفصيلة',
        bodyAr:
            '${a.fullName}: ${a.bloodType.name}. ${b.fullName}: ${b.bloodType.name}. '
            'ليست مانعاً للزواج. إن كانت إحداهما سالبة والأخرى موجبة ففحوص الحمل عند الطبيبة أهم.',
      ),
    );
    if (_rhPair(a.bloodType, b.bloodType)) {
      notes.add(
        const HealthMatchNote(
          titleAr: 'عامل ريسس',
          bodyAr:
              'اختلاف سالب/موجب. توعية للحمل لاحقاً مع الطبيبة. ليست نتيجة مختبر هنا.',
        ),
      );
    }

    final sharedChronic = _shared(
      a.chronicConditions.where((c) => c.isActive).map((c) => c.conditionName),
      b.chronicConditions.where((c) => c.isActive).map((c) => c.conditionName),
    );
    if (sharedChronic.isNotEmpty) {
      notes.add(
        HealthMatchNote(
          titleAr: 'حالات مزمنة متشابهة في الملفين',
          bodyAr:
              '${sharedChronic.join('، ')}. للمتابعة مع طبيب أسرة. ليست حكماً على الارتباط.',
        ),
      );
    }

    final sharedAllergy = _shared(
      a.allergies.map((item) => item.substance),
      b.allergies.map((item) => item.substance),
    );
    if (sharedAllergy.isNotEmpty) {
      notes.add(
        HealthMatchNote(
          titleAr: 'حساسية مسجَّلة عند الطرفين',
          bodyAr: '${sharedAllergy.join('، ')}. للمعرفة المنزلية لا للمنع.',
        ),
      );
    }

    if (a.linkedFamilyProfileIds.contains(b.profileId) ||
        b.linkedFamilyProfileIds.contains(a.profileId)) {
      notes.add(
        const HealthMatchNote(
          titleAr: 'قرابة في هذا الحساب',
          bodyAr:
              'الملفان مرتبطان عائلياً هنا. الاستشارة الوراثية عند مختص إن رغبتما. التطبيق لا يقرر.',
        ),
      );
    }

    final ageGap = (a.ageInYears - b.ageInYears).abs();
    notes.add(
      HealthMatchNote(
        titleAr: 'العمر في الملفين',
        bodyAr: '${a.ageInYears} و ${b.ageInYears} سنة (فرق $ageGap). معلومة فقط.',
      ),
    );

    final attention = notes.length - 1;
    return HealthMatchReport(
      allowed: true,
      notes: notes,
      attentionCount: attention < 0 ? 0 : attention,
      summaryAr:
          'توافق صحي توعوي بعد الموافقة. $attention بنداً للانتباه مع الطبيب. '
          'يخدم الأسرة والمجتمع ولا يزوّج ولا يحرّم ولا يدمج الملفين.',
    );
  }

  bool _rhPair(BloodType x, BloodType y) {
    if (x == BloodType.unknown || y == BloodType.unknown) return false;
    return _negatives.contains(x) != _negatives.contains(y);
  }

  List<String> _shared(Iterable<String> left, Iterable<String> right) {
    final folded = right.map((item) => item.trim().toLowerCase()).toSet();
    return left
        .where((item) => folded.contains(item.trim().toLowerCase()))
        .toSet()
        .toList();
  }
}
