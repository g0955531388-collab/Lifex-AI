/// =============================================================
/// Lifex-AI — صندوق المشروع
/// الملف: sector_analytics.dart
/// إحصاء مجهّل من الجهاز فقط. الإحصاء القطاعي يحتاج مواقع متعددة.
/// =============================================================
library lifex_ai.features.network_box.sector_analytics;

import '../profile/health_profile.dart';
import 'box_unit_catalog.dart';
import 'profile_box_store.dart';
import 'unified_booking_service.dart';

class SectorAnalytics {
  SectorAnalytics._();

  static Map<String, int> unitCounts(HealthProfile profile) {
    final store = ProfileBoxStore(profile);
    final counts = <String, int>{};
    for (final unit in BoxUnitCatalog.recordUnits) {
      counts[unit.id] = store.list(unit.storageKey).length;
    }
    counts['bookings'] = store.list(BoxKeys.bookings).length;
    return counts;
  }

  static Map<String, int> anonymizedBloodTypes(List<HealthProfile> profiles) {
    final counts = <String, int>{};
    for (final profile in profiles) {
      final key = profile.bloodType.name;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  static int waitingBookings(HealthProfile profile) =>
      UnifiedBookingService(ProfileBoxStore(profile)).all().length;
}
