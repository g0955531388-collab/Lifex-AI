/// =============================================================
/// Lifex-AI — المعاملات المالية
/// الملف: subscription_billing_manager.dart
/// المسار: lib/features/finance/subscription_billing_manager.dart
/// الوصف: فوترة الاشتراكات وإيصالات التبرع ومبيعات المتاجر — طبقة منفصلة
/// عن WalletManager (الذي يبقى مسؤولاً عن شحن الرصيد ودفع فواتير
/// المستشفى/التبرعات من الرصيد فقط). كل محاولة فوترة تمر أولاً عبر
/// BillingExemptionPolicy؛ إن كان المستخدم مُعفى، لا تُستدعى أي بوابة
/// دفع خارجية إطلاقاً ولا يُسجَّل أي مبلغ عليه.
/// =============================================================
library lifex_ai.features.finance.subscription_billing_manager;

import '../profile/health_profile.dart';
import 'billing_exemption_policy.dart';
import 'payment_gateway_client.dart';
import 'platform_fee_policy.dart';
import 'subscription_catalog.dart';
import 'transaction_ledger.dart';

class BillingOutcome {
  final bool success;
  final String messageAr;
  final bool wasExempt;

  const BillingOutcome._(this.success, this.messageAr, this.wasExempt);

  factory BillingOutcome.exempt(String reasonAr) =>
      BillingOutcome._(true, reasonAr, true);

  factory BillingOutcome.charged(String messageAr) =>
      BillingOutcome._(true, messageAr, false);

  factory BillingOutcome.failed(String messageAr) =>
      BillingOutcome._(false, messageAr, false);
}

/// المدير المسؤول عن فوترة الاشتراكات ومبيعات المتاجر، مع احترام سياسة
/// الإعفاء والسماح لكل مستخدم باختيار بوابة الدفع المتاحة في بلده.
class SubscriptionBillingManager {
  SubscriptionBillingManager({
    required this.ledger,
    required this.exemptionPolicy,
    this.catalog = const SubscriptionCatalog(),
    this.feePolicy = const PlatformFeePolicy(),
    Map<String, PaymentGatewayClient>? gatewaysByName,
    Map<String, List<String>>? availableGatewayNamesByCountryCode,
  })  : _gatewaysByName = gatewaysByName ?? {},
        _availableGatewayNamesByCountryCode =
            availableGatewayNamesByCountryCode ?? {};

  final TransactionLedger ledger;
  final BillingExemptionPolicy exemptionPolicy;
  final SubscriptionCatalog catalog;
  final PlatformFeePolicy feePolicy;
  final Map<String, PaymentGatewayClient> _gatewaysByName;
  final Map<String, List<String>> _availableGatewayNamesByCountryCode;

  void registerGateway(PaymentGatewayClient gateway) {
    _gatewaysByName[gateway.gatewayName] = gateway;
  }

  void setAvailableGatewaysForCountry({
    required String countryCode,
    required List<String> gatewayNames,
  }) {
    _availableGatewayNamesByCountryCode[countryCode] = gatewayNames;
  }

  /// أسماء بوابات الدفع المتاحة فعلياً لبلد المستخدم — الواجهة تعرض هذه
  /// القائمة فقط، ولا تفترض أن كل بوابة مسجَّلة متاحة في كل بلد
  /// (بعض البوابات محظورة أو غير مدعومة في بعض الدول).
  List<String> availableGatewaysForCountry(String countryCode) {
    return List.unmodifiable(
      _availableGatewayNamesByCountryCode[countryCode] ??
          _gatewaysByName.keys.toList(),
    );
  }

  AnnualPlan annualPlanFor(HealthProfile profile) =>
      catalog.planFor(catalog.parseSeat(profile.billingSeat));

  /// فوترة الاشتراك السنوي حسب المقعد: فرد 100، وحدة 300، مستشفى 600.
  Future<BillingOutcome> chargeAnnualSubscription({
    required HealthProfile profile,
    required String gatewayName,
  }) {
    final plan = annualPlanFor(profile);
    return chargeSubscription(
      profile: profile,
      amountInSmallestUnit: plan.cents,
      currencyCode: SubscriptionCatalog.currency,
      gatewayName: gatewayName,
      planDescriptionAr: '${plan.titleAr} — ${plan.includesAr}',
    );
  }

  BillingOutcome quoteExtraService({
    required HealthProfile profile,
    required ExtraServiceKind kind,
    int? negotiatedCents,
  }) {
    final quote = feePolicy.onExtraService(
      profile: profile,
      kind: kind,
      negotiatedCents: negotiatedCents,
    );
    if (quote.wasExempt) {
      return BillingOutcome.exempt(quote.messageAr);
    }
    if (quote.needsNegotiation) {
      return BillingOutcome.failed(quote.messageAr);
    }
    return BillingOutcome.charged(quote.messageAr);
  }

  WalletTransaction? recordPlatformFeeIfDue({
    required HealthProfile profile,
    required int transferCents,
  }) {
    final quote = feePolicy.onMoneyTransfer(
      profile: profile,
      transferCents: transferCents,
    );
    if (quote.wasExempt || quote.dueCents <= 0) return null;
    return ledger.record(
      profileId: profile.profileId,
      type: TransactionType.platformFee,
      amountInSmallestUnit: quote.dueCents,
      currencyCode: SubscriptionCatalog.currency,
      relatedEntityId: 'transfer',
    );
  }

  /// فوترة اشتراك دوري — يفحص الإعفاء أولاً وجوباً.
  Future<BillingOutcome> chargeSubscription({
    required HealthProfile profile,
    required int amountInSmallestUnit,
    required String currencyCode,
    required String gatewayName,
    String? planDescriptionAr,
  }) async {
    final exemption = exemptionPolicy.evaluate(profile);
    if (exemption.isExempt) {
      return BillingOutcome.exempt(exemption.reasonAr!);
    }

    final gateway = _gatewaysByName[gatewayName];
    if (gateway == null) {
      return BillingOutcome.failed('بوابة الدفع "$gatewayName" غير مسجَّلة.');
    }

    final result = await gateway.chargeAmount(
      amountInSmallestUnit: amountInSmallestUnit,
      currencyCode: currencyCode,
      description: planDescriptionAr ?? 'اشتراك Lifex-AI',
    );

    if (result.status != PaymentStatus.succeeded) {
      return BillingOutcome.failed(
        result.errorMessageAr ?? 'فشلت عملية الفوترة. حاول مرة أخرى.',
      );
    }

    ledger.record(
      profileId: profile.profileId,
      type: TransactionType.subscriptionPayment,
      amountInSmallestUnit: amountInSmallestUnit,
      currencyCode: currencyCode,
      relatedGatewayTransactionId: result.gatewayTransactionId,
    );

    return BillingOutcome.charged('تم تفعيل الاشتراك بنجاح.');
  }

  /// تسجيل عملية بيع تمّت فعلياً عبر نظام فوترة متجر التطبيقات (Google
  /// Play/App Store) — لا تستدعي أي بوابة دفع خارجية لأن المتجر نفسه
  /// تولّى التحصيل؛ هذا فقط لتوثيق العملية في سجل الشفافية المالية.
  /// يخضع أيضاً لسياسة الإعفاء: مستخدم مُعفى لا يجب أن يُطلب منه الدفع
  /// أصلاً على مستوى واجهة المتجر، لكن الفحص هنا حماية إضافية.
  BillingOutcome recordAppStoreSale({
    required HealthProfile profile,
    required int amountInSmallestUnit,
    required String currencyCode,
    required String storeTransactionId,
  }) {
    final exemption = exemptionPolicy.evaluate(profile);
    if (exemption.isExempt) {
      return BillingOutcome.exempt(exemption.reasonAr!);
    }

    ledger.record(
      profileId: profile.profileId,
      type: TransactionType.appStoreSale,
      amountInSmallestUnit: amountInSmallestUnit,
      currencyCode: currencyCode,
      relatedGatewayTransactionId: storeTransactionId,
    );

    return BillingOutcome.charged('تم تسجيل عملية الشراء بنجاح.');
  }
}
