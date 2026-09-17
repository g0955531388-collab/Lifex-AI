/// =============================================================
/// Lifex-AI — المعاملات المالية
/// الملف: billing_exemption_policy.dart
/// المسار: lib/features/finance/billing_exemption_policy.dart
/// الوصف: إعفاء بلا أجور ولا رسوم لذوي الإعاقة بعد بطاقة من بلد الحساب،
/// والمرضى الدائمين في الملف، والمكفوفين. الاشتراك العادي للأفراد 100
/// دولار سنوياً ولا يشمل الإعلانات ولا الخدمات الخاصة.
/// =============================================================
library lifex_ai.features.finance.billing_exemption_policy;

import '../profile/determination_credential_policy.dart';
import '../profile/health_profile.dart';

class BillingExemptionResult {
  final bool isExempt;
  final String? reasonAr;

  const BillingExemptionResult._(this.isExempt, this.reasonAr);

  const BillingExemptionResult.exempt(String reasonAr)
      : this._(true, reasonAr);

  const BillingExemptionResult.notExempt() : this._(false, null);
}

/// سياسة الإعفاء من الرسوم — دالة واحدة، صريحة، وغير قابلة للتجاوز من
/// أي طبقة أعلى (الواجهة لا تملك خياراً لتعطيل هذا الفحص).
class BillingExemptionPolicy {
  const BillingExemptionPolicy();

  BillingExemptionResult evaluate(HealthProfile profile) {
    final determination =
        const DeterminationCredentialPolicy().evaluate(profile);
    if (determination.recognized) {
      return const BillingExemptionResult.exempt(
        'إعفاء دائم: بطاقة همم من بلد صاحب الحساب (وطنية أو إعاقة أو مرض دائم).',
      );
    }

    if (profile.isBlind) {
      return const BillingExemptionResult.exempt(
        'إعفاء دائم: لا أجور ولا رسوم على المكفوفين في هذه الفئة.',
      );
    }

    final hasActiveChronicCondition =
        profile.chronicConditions.any((c) => c.isActive);
    if (hasActiveChronicCondition) {
      return const BillingExemptionResult.exempt(
        'إعفاء دائم: لا أجور ولا رسوم على المرضى الدائمين المسجَّلين في الملف.',
      );
    }

    return const BillingExemptionResult.notExempt();
  }
}
