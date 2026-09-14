/// =============================================================
/// Lifex-AI — المعاملات المالية
/// الملف: billing_exemption_policy.dart
/// المسار: lib/features/finance/billing_exemption_policy.dart
/// الوصف: سياسة إعفاء ثابتة وصريحة — كل مريض بحالة مزمنة أو مستعصية
/// نشطة، وكل شخص من ذوي الهمم، مُعفى بشكل دائم من أي رسوم أو اشتراكات
/// في المنصة، بصرف النظر عن أي ظرف آخر. هذا الملف هو المصدر الوحيد
/// لهذا القرار؛ SubscriptionBillingManager يستدعيه دائماً قبل أي محاولة
/// فوترة، ولا يُطبَّق الإعفاء أو يُعاد تعريفه في أي مكان آخر من الكود.
/// =============================================================
library lifex_ai.features.finance.billing_exemption_policy;

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
    if (profile.isPersonOfDetermination) {
      return const BillingExemptionResult.exempt(
        'إعفاء دائم: صاحب الحساب من ذوي الهمم.',
      );
    }

    final hasActiveChronicCondition =
        profile.chronicConditions.any((c) => c.isActive);
    if (hasActiveChronicCondition) {
      return const BillingExemptionResult.exempt(
        'إعفاء دائم: صاحب الحساب لديه حالة مزمنة أو مستعصية نشطة مسجَّلة '
        'في ملفه الصحي.',
      );
    }

    return const BillingExemptionResult.notExempt();
  }
}
