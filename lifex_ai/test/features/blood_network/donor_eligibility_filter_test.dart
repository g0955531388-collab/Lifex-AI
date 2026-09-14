// اختبارات: donor_eligibility_filter.dart — التركيز على استبعاد
// المتبرعين الرافضين لتلقي طلبات التبرع.

import 'package:flutter_test/flutter_test.dart';
import 'package:lifex_ai/features/blood_network/donor_eligibility_filter.dart';
import 'package:lifex_ai/features/blood_network/donor_history_registry.dart';
import 'package:lifex_ai/features/hospital/hospital_blood_bank.dart';

void main() {
  test('متبرع رافض للتبرع (opted-out) لا يظهر أبداً ضمن المؤهلين حتى لو '
      'تطابقت فصيلته وموقعه تماماً', () {
    final filter = DonorEligibilityFilter(
      historyRegistry: DonorHistoryRegistry(),
      donorDirectory: () => [
        const DonorLocation(
          donorLifexId: 'LFX-1',
          bloodType: BloodTypeSimple.oPositive,
          latitude: 33.5,
          longitude: 36.3,
          hasOptedOutOfDonationAlerts: true,
        ),
        const DonorLocation(
          donorLifexId: 'LFX-2',
          bloodType: BloodTypeSimple.oPositive,
          latitude: 33.5,
          longitude: 36.3,
        ),
      ],
    );

    final eligible = filter.findEligibleDonors(
      bloodType: BloodTypeSimple.oPositive,
      centerLatitude: 33.5,
      centerLongitude: 36.3,
      radiusKm: 5,
    );

    expect(eligible.map((d) => d.donorLifexId), ['LFX-2']);
  });

  test('الحالة الافتراضية (لم يُحدَّد الحقل): يُعامَل كمشارك، ليس كرافض', () {
    final filter = DonorEligibilityFilter(
      historyRegistry: DonorHistoryRegistry(),
      donorDirectory: () => [
        const DonorLocation(
          donorLifexId: 'LFX-3',
          bloodType: BloodTypeSimple.aNegative,
          latitude: 33.5,
          longitude: 36.3,
        ),
      ],
    );

    final eligible = filter.findEligibleDonors(
      bloodType: BloodTypeSimple.aNegative,
      centerLatitude: 33.5,
      centerLongitude: 36.3,
      radiusKm: 5,
    );

    expect(eligible, hasLength(1));
  });
}
