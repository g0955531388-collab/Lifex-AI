// اختبارات: billing_exemption_policy.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:lifex_ai/features/finance/billing_exemption_policy.dart';
import 'package:lifex_ai/features/profile/health_profile.dart';

HealthProfile _buildProfile({
  bool isPersonOfDetermination = false,
  bool isBlind = false,
  String accountCountry = '',
  String determinationCardKind = '',
  String determinationCardCountry = '',
  String determinationCardRef = '',
  List<ChronicConditionRecord>? chronicConditions,
}) {
  return HealthProfile(
    profileId: 'p1',
    fullName: 'مستخدم اختباري',
    dateOfBirth: DateTime(1990, 1, 1),
    isPersonOfDetermination: isPersonOfDetermination,
    isBlind: isBlind,
    accountCountry: accountCountry,
    determinationCardKind: determinationCardKind,
    determinationCardCountry: determinationCardCountry,
    determinationCardRef: determinationCardRef,
    chronicConditions: chronicConditions,
  );
}

void main() {
  const policy = BillingExemptionPolicy();

  test('مستخدم عادي بلا حالات مزمنة وغير من ذوي الهمم: غير مُعفى', () {
    final profile = _buildProfile();
    expect(policy.evaluate(profile).isExempt, isFalse);
  });

  test('تصريح همم بلا بطاقة من بلد الحساب: لا يُعفى', () {
    final profile = _buildProfile(isPersonOfDetermination: true);
    expect(policy.evaluate(profile).isExempt, isFalse);
  });

  test('بطاقة إعاقة من بلد صاحب الحساب: مُعفى', () {
    final profile = _buildProfile(
      isPersonOfDetermination: true,
      accountCountry: 'سوريا',
      determinationCardKind: 'disabilityCard',
      determinationCardCountry: 'سوريا',
      determinationCardRef: 'ID-99',
    );
    final result = policy.evaluate(profile);
    expect(result.isExempt, isTrue);
    expect(result.reasonAr, isNotNull);
  });

  test('مكفوف: مُعفى بلا رسوم', () {
    expect(policy.evaluate(_buildProfile(isBlind: true)).isExempt, isTrue);
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
