/// =============================================================
/// Lifex-AI — المعاملات المالية
/// الملف: paypal_payment_gateway_client.dart
/// المسار: lib/features/finance/paypal_payment_gateway_client.dart
/// الوصف: تنفيذ PaymentGatewayClient عبر PayPal — هذا هو مزوّد الدفع
/// المعتمد فعلياً في المنظومة حسب توجيه صريح، وليس بديلاً اختيارياً عن
/// Stripe؛ SubscriptionBillingManager يختار من بين البوابات المسجَّلة
/// (Stripe/PayPal/غيرها لاحقاً) حسب ما هو متاح فعلياً في بلد المستخدم.
/// هيكل فقط حتى الآن — يتطلب ربط SDK حقيقي (paypal_payment أو REST API
/// مباشر لـ PayPal Checkout/Orders v2) واعتماد حساب PayPal تجاري حقيقي
/// للمشروع قبل قبول أي دفعة فعلية.
/// =============================================================
library lifex_ai.features.finance.paypal_payment_gateway_client;

import 'payment_gateway_client.dart';

class PayPalPaymentGatewayClient implements PaymentGatewayClient {
  PayPalPaymentGatewayClient({required this.clientId});

  final String clientId;

  @override
  String get gatewayName => 'PayPal';

  @override
  Future<PaymentResult> chargeAmount({
    required int amountInSmallestUnit,
    required String currencyCode,
    required String description,
  }) async {
    // TODO: استبدال هذا بالاستدعاء الفعلي لـ PayPal Orders API (إنشاء
    // Order ثم Capture) عند اعتماد حساب PayPal تجاري حقيقي للمشروع.
    return const PaymentResult(
      status: PaymentStatus.failed,
      errorMessageAr: 'بوابة PayPal غير مُفعَّلة بعد. يُرجى المحاولة لاحقاً.',
    );
  }

  @override
  Future<PaymentResult> refund({
    required String gatewayTransactionId,
    int? partialAmountInSmallestUnit,
  }) async {
    return const PaymentResult(
      status: PaymentStatus.failed,
      errorMessageAr: 'بوابة PayPal غير مُفعَّلة بعد.',
    );
  }
}
