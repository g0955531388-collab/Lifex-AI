import 'package:flutter_test/flutter_test.dart';
import 'package:lifex_ai/features/profile/health_profile.dart';
import 'package:lifex_ai/features/women_health/pregnancy_cv_guard.dart';
import 'package:lifex_ai/features/women_health/private_female_notice.dart';
import 'package:lifex_ai/features/women_health/women_ashram_engine.dart';

void main() {
  const engine = WomenAshramEngine();

  test('متوسط الدورة من بداية إلى بداية', () {
    final mean = engine.meanStartToStartDays([
      DateTime(2026, 1, 1),
      DateTime(2026, 1, 29),
      DateTime(2026, 2, 26),
    ]);
    expect(mean, 28);
  });

  test('موعد الأربعين أسبوعاً يتعدل إن كان متوسطها 32 يوماً', () {
    final lmp = DateTime(2026, 1, 1);
    final due28 = engine.dueFromCycles(
      lmp: lmp,
      starts: [lmp, DateTime(2026, 1, 29)],
    );
    final due32 = engine.dueFromCycles(
      lmp: lmp,
      starts: [lmp, DateTime(2026, 2, 2)],
    );
    expect(due32.difference(due28).inDays, 4);
  });

  test('التأخير يفتح رسالة خاصة بلا عنوان صريح', () {
    final snap = engine.evaluate(
      now: DateTime(2026, 2, 20),
      starts: [DateTime(2026, 1, 1)],
      trackingEnabled: true,
      pregnancyConfirmed: false,
    );
    expect(snap.lateByDays, greaterThan(7));
    expect(snap.notices, isNotEmpty);
    expect(PrivateFemaleNotice.publicTitleAr, 'لديك رسالة خاصة');
    expect(PrivateFemaleNotice.publicTitleAr.contains('دورة'), isFalse);
    expect(PrivateFemaleNotice.publicTitleAr.contains('حمل'), isFalse);
  });

  test('قبل الموعد بيومين: رسالة خاصة للهدأة', () {
    final snap = engine.evaluate(
      now: DateTime(2026, 1, 27),
      starts: [DateTime(2026, 1, 1)],
      trackingEnabled: true,
      pregnancyConfirmed: false,
    );
    expect(snap.daysUntilNext, 2);
    expect(snap.notices.first.bodyAr.contains('إحراج'), isFalse);
  });

  test('تأكيد الحمل يراجع دواء الملف نحو الطبيبة', () {
    final profile = HealthProfile(
      profileId: 'w1',
      fullName: 'اختبار',
      dateOfBirth: DateTime(1995, 1, 1),
      currentMedicationNames: const ['وارفارين'],
    );
    final flags = const PregnancyCvGuard().flagsFor(profile);
    expect(flags.join(), contains('وارفارين'));

    final snap = engine.evaluate(
      now: DateTime(2026, 3, 1),
      starts: [DateTime(2026, 1, 1), DateTime(2026, 1, 29)],
      trackingEnabled: true,
      pregnancyConfirmed: true,
      lmp: DateTime(2026, 1, 1),
      profile: profile,
    );
    expect(snap.pregnancyActive, isTrue);
    expect(snap.gestationalWeek, greaterThan(0));
    expect(snap.cvFlags.join(), contains('طبيبة'));
  });
}
