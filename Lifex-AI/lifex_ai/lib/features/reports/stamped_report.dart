/// =============================================================
/// Lifex-AI — التقارير
/// الملف: stamped_report.dart
/// تقرير نصي مختوم بالملكية وإخلاء طبي. ليس سجل منشأة.
/// =============================================================
library lifex_ai.features.reports.stamped_report;

import '../../core/app_constants.dart';
import '../profile/health_profile.dart';

class StampedReport {
  StampedReport({
    required this.profile,
    required this.bodyAr,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final HealthProfile profile;
  final String bodyAr;
  final DateTime createdAt;

  String get reportId => 'LIFEX-${createdAt.millisecondsSinceEpoch}';

  static const medicalDisclaimerAr =
      'هذه البيانات للتنظيم الشخصي وليست تشخيصاً ولا بديلاً عن الطبيب أو خدمات الطوارئ.';

  String toPlainText() {
    final buffer = StringBuffer()
      ..writeln('===== ${AppConstants.appName} =====')
      ..writeln(AppConstants.ownershipStatement)
      ..writeln('البريد: ${AppConstants.officialContactEmail}')
      ..writeln('رقم التقرير: $reportId')
      ..writeln('التاريخ: ${createdAt.toIso8601String()}')
      ..writeln()
      ..writeln('الملف: ${profile.fullName}')
      ..writeln('العمر: ${profile.ageInYears}')
      ..writeln('الفصيلة: ${profile.bloodType.name}')
      ..writeln()
      ..writeln(bodyAr)
      ..writeln()
      ..writeln(medicalDisclaimerAr)
      ..writeln(
        'هذا المستند من المنصة وليس سجل المنشأة الرسمية إلا إذا أصدرته الوحدة نفسها.',
      );
    return buffer.toString();
  }
}
