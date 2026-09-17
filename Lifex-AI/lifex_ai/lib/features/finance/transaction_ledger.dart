/// =============================================================
/// Lifex-AI — المعاملات المالية
/// الملف: transaction_ledger.dart
/// المسار: lib/features/finance/transaction_ledger.dart
/// الوصف: سجل شفاف لكل حركة داخل المحفظة الرقمية — شحن، دفع فاتورة
/// مستشفى، تبرع، استرجاع. سجل للقراءة فقط بعد التسجيل (Append-only)
/// حفاظاً على الشفافية المالية الكاملة للمستخدم.
/// =============================================================

enum TransactionType {
  topUp,
  hospitalPayment,
  donationPayment,
  refund,

  /// دفعة اشتراك دوري في المنصة (وليس فاتورة خدمة صحية) — تخضع لسياسة
  /// الإعفاء في billing_exemption_policy.dart قبل الوصول لهذه النقطة
  /// أصلاً، فأي معاملة من هذا النوع مسجَّلة هنا كانت مستحقة فعلاً.
  subscriptionPayment,

  /// عائدات بيع عبر متاجر التطبيقات — للشفافية إن مرّ التحصيل من المتجر.
  appStoreSale,

  /// رسوم المنصة على تحويل أموال أو خدمة إضافية، لصالح Lifex-AI.
  platformFee,

  /// خدمة غير مشمولة بالاشتراك (دورة، إعلان متفق، خاص) بعد تفاوض.
  extraService,
}

class WalletTransaction {
  final String transactionId;
  final String profileId;
  final TransactionType type;
  final int amountInSmallestUnit;
  final String currencyCode;
  final String? relatedGatewayTransactionId;
  final String? relatedEntityId; // مثلاً معرّف فاتورة مستشفى أو تبرع
  final DateTime recordedAt;

  const WalletTransaction({
    required this.transactionId,
    required this.profileId,
    required this.type,
    required this.amountInSmallestUnit,
    required this.currencyCode,
    this.relatedGatewayTransactionId,
    this.relatedEntityId,
    required this.recordedAt,
  });
}

/// سجل المعاملات — لا يُعدَّل أو يُحذَف منه أي سجل بعد إضافته، فقط
/// يُضاف له (Append-only Ledger).
class TransactionLedger {
  TransactionLedger();

  final List<WalletTransaction> _transactions = [];
  int _counter = 0;

  WalletTransaction record({
    required String profileId,
    required TransactionType type,
    required int amountInSmallestUnit,
    required String currencyCode,
    String? relatedGatewayTransactionId,
    String? relatedEntityId,
  }) {
    _counter++;
    final transaction = WalletTransaction(
      transactionId: 'TXN-$_counter',
      profileId: profileId,
      type: type,
      amountInSmallestUnit: amountInSmallestUnit,
      currencyCode: currencyCode,
      relatedGatewayTransactionId: relatedGatewayTransactionId,
      relatedEntityId: relatedEntityId,
      recordedAt: DateTime.now(),
    );
    _transactions.add(transaction);
    return transaction;
  }

  List<WalletTransaction> historyFor(String profileId) {
    return _transactions.where((t) => t.profileId == profileId).toList();
  }

  /// كل المعاملات المسجَّلة عبر كل المستخدمين (للقراءة فقط) — تُستخدم
  /// من خدمات التقارير التي تحتاج البحث بمعرّف كيان مرتبط بدلاً من
  /// معرّف مستخدم معيّن.
  List<WalletTransaction> get allTransactions =>
      List.unmodifiable(_transactions);

  /// الرصيد الحالي المحسوب من السجل الكامل — لا يُخزَّن كرقم منفصل قابل
  /// للتلاعب، بل يُشتق دائماً من مجموع الحركات (شحن/استرجاع موجب،
  /// دفع سالب).
  int currentBalanceFor(String profileId) {
    int balance = 0;
    for (final t in historyFor(profileId)) {
      switch (t.type) {
        case TransactionType.topUp:
        case TransactionType.refund:
          balance += t.amountInSmallestUnit;
          break;
        case TransactionType.hospitalPayment:
        case TransactionType.donationPayment:
        case TransactionType.subscriptionPayment:
        case TransactionType.appStoreSale:
        case TransactionType.platformFee:
        case TransactionType.extraService:
          balance -= t.amountInSmallestUnit;
          break;
      }
    }
    return balance;
  }
}
