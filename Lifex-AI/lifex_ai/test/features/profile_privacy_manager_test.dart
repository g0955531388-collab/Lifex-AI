// =============================================================
// Lifex-AI — اختبارات الوحدة
// الملف: profile_privacy_manager_test.dart
// المسار: test/features/profile_privacy_manager_test.dart
// الوصف: يضمن أن سجل الخصوصية يعيد نفس المدير لكل ملف، وأن قاعدة
// الطوارئ ترفض التخفيض عن الملخص الطبي — هذا هو أساس شاشة الخصوصية.
// =============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:lifex_ai/features/profile/profile_privacy_manager.dart';

void main() {
  setUp(() {
    ProfilePrivacyRegistry.instance.resetForTesting();
  });

  group('ProfilePrivacyRegistry', () {
    test('يعيد نفس مدير الخصوصية لنفس الملف', () {
      final first = ProfilePrivacyRegistry.instance.forProfile('p1');
      first.setVisibility(ViewerCategory.family, DataVisibilityLevel.none);

      final second = ProfilePrivacyRegistry.instance.forProfile('p1');
      expect(identical(first, second), isTrue);
      expect(
        second.visibilityFor(ViewerCategory.family),
        DataVisibilityLevel.none,
      );
    });

    test('يرفض تخفيض صلاحية فرق الطوارئ عن الملخص الطبي', () {
      final manager = ProfilePrivacyRegistry.instance.forProfile('p-emergency');
      final accepted = manager.setVisibility(
        ViewerCategory.emergencyResponder,
        DataVisibilityLevel.none,
      );

      expect(accepted, isFalse);
      expect(
        manager.visibilityFor(ViewerCategory.emergencyResponder),
        DataVisibilityLevel.medicalSummary,
      );
    });
  });
}
