// اختبارات: billing_exemption_policy.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:lifex_ai/features/finance/billing_exemption_policy.dart';
import 'package:lifex_ai/features/profile/health_profile.dart';

HealthProfile _buildProfile({
  bool isPersonOfDetermination = false,
  List<ChronicConditionRecord>? chronicConditions,
}) {
  return HealthProfile(
    profileId: 'p1',
    fullName: 'مستخدم اختباري',
    dateOfBirth: DateTime(1990, 1, 1),
    isPersonOfDetermination: isPersonOfDetermination,
    chronicConditions: chronicConditions,
  );
}

void main() {
  const policy = BillingExemptionPolicy();

  test('مستخدم عادي بلا حالات مزمنة وغير من ذوي الهمم: غير مُعفى', () {
    final profile = _buildProfile();
    expect(policy.evaluate(profile).isExempt, isFalse);
  });

  test('شخص من ذوي الهمم: مُعفى دائماً', () {
    final profile = _buildProfile(isPersonOfDetermination: true);
    final result = policy.evaluate(profile);
    expect(result.isExempt, isTrue);
    expect(result.reasonAr, isNotNull);
  });

  test('مريض بحالة مزمنة نشطة: مُعفى', () {
    final profile = _buildProfile(chronicConditions: [
      ChronicConditionRecord(conditionName: 'السكري', diagnosedAt: DateTime(2020, 1, 1)),
    ]);
    expect(policy.evaluate(profile).isExempt, isTrue);
  });

  test('حالة مزمنة غير نشطة (isActive=false): لا تُعفي', () {
    final profile = _buildProfile(chronicConditions: [
      ChronicConditionRecord(
        conditionName: 'كسر قديم شُفي',
        diagnosedAt: DateTime(2015, 1, 1),
        isActive: false,
      ),
    ]);
    expect(policy.evaluate(profile).isExempt, isFalse);
  });
}
