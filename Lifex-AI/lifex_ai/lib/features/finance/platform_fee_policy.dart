/// =============================================================
/// Lifex-AI — المعاملات المالية
/// الملف: platform_fee_policy.dart
/// تحويل الأموال والخدمات غير المشمولة بالاشتراك: رسوم لصالح المنصة.
/// المعفى (همم موثّقة، مرض دائم، مكفوفون) بلا أجور ولا رسوم.
/// سعر الدورة أو الإعلان إن لم يُتفق عليه يبقى تفاوضاً، لا رقماً مختلقاً.
/// =============================================================
library lifex_ai.features.finance.platform_fee_policy;

import '../profile/health_profile.dart';
import 'billing_exemption_policy.dart';
import 'subscription_catalog.dart';

class PlatformCharge {
  const PlatformCharge({
    required this.dueCents,
    required this.messageAr,
    this.needsNegotiation = false,
    this.wasExempt = false,
  });

  final int dueCents;
  final String messageAr;
  final bool needsNegotiation;
  final bool wasExempt;
}

class PlatformFeePolicy {
  const PlatformFeePolicy({
    this.exemptionPolicy = const BillingExemptionPolicy(),
    this.catalog = const SubscriptionCatalog(),
  });

  final BillingExemptionPolicy exemptionPolicy;
  final SubscriptionCatalog catalog;

  PlatformCharge onMoneyTransfer({
    required HealthProfile profile,
    required int transferCents,
  }) {
    if (transferCents <= 0) {
      return const PlatformCharge(
        dueCents: 0,
        messageAr: 'لا تحويل بلا مبلغ أكبر من صفر.',
      );
    }
    final exemption = exemptionPolicy.evaluate(profile);
    if (exemption.isExempt) {
      return PlatformCharge(
        dueCents: 0,
        wasExempt: true,
        messageAr: 'لا رسوم على التحويل: ${exemption.reasonAr}',
      );
    }
    final fee = _percent(transferCents);
    return PlatformCharge(
      dueCents: fee,
      messageAr:
          'رسوم المنصة $fee سنتاً (${SubscriptionCatalog.platformFeePercent}٪) '
          'على تحويل $transferCents سنتاً، لصالح Lifex-AI. ليست ضمن الاشتراك.',
    );
  }

  PlatformCharge onExtraService({
    required HealthProfile profile,
    required ExtraServiceKind kind,
    int? negotiatedCents,
  }) {
    final exemption = exemptionPolicy.evaluate(profile);
    if (exemption.isExempt) {
      return PlatformCharge(
        dueCents: 0,
        wasExempt: true,
        messageAr: 'لا أجور ولا رسوم على هذه الفئة: ${exemption.reasonAr}',
      );
    }
    final label = catalog.extraLabelAr(kind);
    if (negotiatedCents == null || negotiatedCents <= 0) {
      return PlatformCharge(
        dueCents: 0,
        needsNegotiation: true,
        messageAr:
            '$label ليست ضمن الاشتراك. السعر بالتفاوض قبل التحصيل. لا رقم مختلق هنا.',
      );
    }
    final fee = _percent(negotiatedCents);
    return PlatformCharge(
      dueCents: negotiatedCents + fee,
      messageAr:
          '$label: المتفق $negotiatedCents سنتاً + رسوم منصة $fee سنتاً '
          '(${SubscriptionCatalog.platformFeePercent}٪) لصالح Lifex-AI.',
    );
  }

  int _percent(int cents) {
    final fee =
        (cents * SubscriptionCatalog.platformFeePercent) ~/ 100;
    if (cents > 0 && fee < 1) return 1;
    return fee;
  }
}
