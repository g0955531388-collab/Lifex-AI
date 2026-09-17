/// =============================================================
/// Lifex-AI — المشاركة العامة
/// الملف: lifex_public_brief.dart
/// النبذة التي تُنشر عند المشاركة: خدمات، إسناد، أسعار. بلا ملف صحي.
/// =============================================================
library lifex_ai.features.outreach.lifex_public_brief;

import '../../core/app_constants.dart';
import '../finance/subscription_catalog.dart';

class LifexPublicBrief {
  const LifexPublicBrief();

  String get fullAr {
    const catalog = SubscriptionCatalog();
    final individual = catalog.planFor(BillingSeat.individual);
    final unit = catalog.planFor(BillingSeat.healthUnit);
    final hospital = catalog.planFor(BillingSeat.hospital);
    return [
      'موسوعة Lifex-AI الصحية — نظام محلي على الجهاز، محترم للأسرة.',
      '',
      'الخدمات العامة: ملف صحي شخصي، مرجع طبي للتوعية، استبيان، أدوية، '
          'مواعيد، شبكة تبرع بالدم، طوارئ على الجهاز، وحدة النساء الخاصة، '
          'قران بنسبة توافق بعد موافقة الطرفين، تعليم وتمكين، محفظة، '
          'ووحدات صحية ومشافٍ حسب الاشتراك. ليس تشخيصاً طبياً ولا بديلاً عن الطبيب.',
      '',
      'الإسناد والملكية:',
      AppConstants.builderAttributionAr,
      AppConstants.ownershipStatement,
      '${AppConstants.academyNameAr} — ${AppConstants.officialContactEmail}',
      '',
      'الأسعار السنوية العادية (دولار أمريكي، بلا إعلانات داخل الاشتراك):',
      '${individual.titleAr}: ${individual.usd} ${SubscriptionCatalog.currency}. ${individual.includesAr} ${individual.excludesAr}',
      '${unit.titleAr}: ${unit.usd} ${SubscriptionCatalog.currency}. ${unit.includesAr}',
      '${hospital.titleAr}: ${hospital.usd} ${SubscriptionCatalog.currency}. ${hospital.includesAr}',
      'رسوم المنصة على التحويل والخدمات الإضافية: ${SubscriptionCatalog.platformFeePercent}٪ أو تفاوض.',
      AppConstants.humanitarianExemptionStatementAr,
      '',
      'يحق لصاحب الحساب مشاركة هذه الموسوعة مع صديق أو عبر أيقونات التواصل. '
          'لا تُشارك المواقع الإباحية. حساب لايفكس يعمل داخل نظامنا؛ '
          'الدخول لموقع خارجي يتم فقط إن كان شريكاً مسجّلاً.',
    ].join('\n');
  }
}
