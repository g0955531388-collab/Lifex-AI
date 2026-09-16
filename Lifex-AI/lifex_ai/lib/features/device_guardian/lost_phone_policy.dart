/// =============================================================
/// Lifex-AI — حماية الجهاز
/// الملف: lost_phone_policy.dart
/// سياسة فقدان الهاتف من النسخة المكتبية: قريب/بعيد، بلا تصوير الخاطف.
/// =============================================================
library lifex_ai.features.device_guardian.lost_phone_policy;

class LostPhonePolicy {
  const LostPhonePolicy();

  static const String farSmsKeyword = 'أين جوالي';

  bool pinMatches(String storedPin, String input) =>
      storedPin.isNotEmpty && storedPin == input.trim();

  String nearbyActionAr() =>
      'قريب: رسالة أنا هنا + إنذار صوتي ظاهر. بلا تصوير من يمسك الهاتف.';

  String farSmsTemplate() =>
      '$farSmsKeyword ثم الرمز. إن صح: موقع تقريبي محفوظ، توفير طاقة، صامت، '
      'إطفاء الشاشة، تشغيل بيانات أو GPS إن أذن المستخدم مسبقاً.';

  String simChangeWithoutPinAr() =>
      'تغيير الشريحة بلا الرمز ينبّه النسخة الاحتياطية وعشرة أرقام موثوقة. '
      'ليس قفلاً خفياً للجهاز ولا Device Admin.';
}
