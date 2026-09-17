/// =============================================================
/// Lifex-AI — المعاملات المالية
/// الملف: subscription_catalog.dart
/// اشتراك سنوي عادي فقط. لا إعلانات ولا خدمات خاصة داخل السعر.
/// الأفراد 100 دولار، الوحدات الصحية 300، المستشفيات 600.
/// التحويل والخدمات الأخرى برسوم لصالح المنصة أو بتفاوض.
/// =============================================================
library lifex_ai.features.finance.subscription_catalog;

enum BillingSeat { individual, healthUnit, hospital }

enum ExtraServiceKind { trainingCourse, advertisement, otherSpecial }

class AnnualPlan {
  const AnnualPlan({
    required this.seat,
    required this.usd,
    required this.titleAr,
    required this.includesAr,
    required this.excludesAr,
  });

  final BillingSeat seat;
  final int usd;
  int get cents => usd * 100;
  final String titleAr;
  final String includesAr;
  final String excludesAr;
}

class SubscriptionCatalog {
  const SubscriptionCatalog();

  static const currency = 'USD';
  static const platformFeePercent = 5;

  static const individual = AnnualPlan(
    seat: BillingSeat.individual,
    usd: 100,
    titleAr: 'اشتراك الأفراد السنوي',
    includesAr: 'اشتراك عادي لسنة واحدة. الوحدات المعتادة على الجهاز.',
    excludesAr:
        'لا إعلانات ولا خدمات خاصة. التحويل والخدمات الأخرى برسوم أو تفاوض.',
  );

  static const healthUnit = AnnualPlan(
    seat: BillingSeat.healthUnit,
    usd: 300,
    titleAr: 'اشتراك الوحدة الصحية السنوي',
    includesAr: 'اشتراك الوحدة لسنة واحدة للخدمات المعتادة.',
    excludesAr:
        'الدورات التدريبية والإعلانات وأي خدمة غير معتادة: ثمن منفصل أو تفاوض.',
  );

  static const hospital = AnnualPlan(
    seat: BillingSeat.hospital,
    usd: 600,
    titleAr: 'اشتراك المستشفى السنوي',
    includesAr: 'ستمئة دولار سنوياً لكل مستشفى. اشتراك عادي فقط.',
    excludesAr: 'ما زاد على الاشتراك (إعلانات وخدمات خاصة) لا يشمله السعر.',
  );

  AnnualPlan planFor(BillingSeat seat) {
    switch (seat) {
      case BillingSeat.individual:
        return individual;
      case BillingSeat.healthUnit:
        return healthUnit;
      case BillingSeat.hospital:
        return hospital;
    }
  }

  BillingSeat parseSeat(String raw) {
    for (final seat in BillingSeat.values) {
      if (seat.name == raw.trim()) return seat;
    }
    return BillingSeat.individual;
  }

  String extraLabelAr(ExtraServiceKind kind) {
    switch (kind) {
      case ExtraServiceKind.trainingCourse:
        return 'دورة تدريبية';
      case ExtraServiceKind.advertisement:
        return 'إعلانات';
      case ExtraServiceKind.otherSpecial:
        return 'خدمة خاصة أخرى';
    }
  }
}
