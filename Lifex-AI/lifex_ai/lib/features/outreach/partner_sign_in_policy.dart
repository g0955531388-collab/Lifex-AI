/// =============================================================
/// Lifex-AI — الدخول لدى الشركاء
/// الملف: partner_sign_in_policy.dart
/// حساب لايفكس يحق له طلب الدخول لأي موقع غير إباحي. التنفيذ يتم
/// فقط إن كان الموقع شريكاً يستقبل حسابنا. لا جلسة وهمية في الذكاء الاصطناعي.
/// =============================================================
library lifex_ai.features.outreach.partner_sign_in_policy;

enum PartnerSignInKind { allowedPartner, notPartner, adultBlocked, invalid }

class PartnerSignInDecision {
  const PartnerSignInDecision({
    required this.kind,
    required this.messageAr,
  });

  final PartnerSignInKind kind;
  final String messageAr;

  bool get mayProceed => kind == PartnerSignInKind.allowedPartner;
}

class PartnerSignInPolicy {
  const PartnerSignInPolicy({this.partnerHosts = const {}});

  /// مضيفون وافقوا صراحة على استقبال حساب لايفكس. القائمة فارغة حتى يُعقد اتفاق.
  final Set<String> partnerHosts;

  static const _adultTokens = [
    'porn',
    'xxx',
    'xvideos',
    'pornhub',
    'xnxx',
    'xhamster',
    'redtube',
    'onlyfans',
    'chaturbate',
    'adult-video',
    'sex.com',
    'إباحي',
    'اباحي',
    'جنس+',
  ];

  PartnerSignInDecision evaluate(String rawDestination) {
    final trimmed = rawDestination.trim();
    if (trimmed.isEmpty) {
      return const PartnerSignInDecision(
        kind: PartnerSignInKind.invalid,
        messageAr: 'أدخل عنوان الموقع الذي تريد الدخول إليه بحساب لايفكس.',
      );
    }
    final folded = trimmed.toLowerCase();
    if (_isAdult(folded)) {
      return const PartnerSignInDecision(
        kind: PartnerSignInKind.adultBlocked,
        messageAr:
            'المواقع الإباحية محظورة. حساب لايفكس لا يُستخدم هناك ولا تُشارك الموسوعة إليها.',
      );
    }
    final host = _hostOf(folded);
    if (host.isEmpty) {
      return const PartnerSignInDecision(
        kind: PartnerSignInKind.invalid,
        messageAr: 'العنوان غير مفهوم. اكتب موقعاً مثل example.com دون محتوى إباحي.',
      );
    }
    if (partnerHosts.contains(host)) {
      return PartnerSignInDecision(
        kind: PartnerSignInKind.allowedPartner,
        messageAr:
            'هذا مضيف شريك. يمكن إبراز معرّف لايفكس المحلي له. لا يُرسل الملف الصحي تلقائياً.',
      );
    }
    return PartnerSignInDecision(
      kind: PartnerSignInKind.notPartner,
      messageAr:
          'يحق لك طلب الدخول بحساب نظامنا إلى مواقع الذكاء الاصطناعي وغيرها ما عدا الإباحي. '
          '«$host» ليس شريكاً بعد، فلا نفتح جلسة هناك ولا نخزّن كلمة سر ذلك الموقع. '
          'حساب لايفكس يعمل داخل نظامنا حتى يوقع الموقع اتفاقاً معنا.',
    );
  }

  bool _isAdult(String folded) {
    for (final token in _adultTokens) {
      if (folded.contains(token)) return true;
    }
    return false;
  }

  String _hostOf(String folded) {
    var value = folded;
    if (!value.contains('://')) value = 'https://$value';
    final uri = Uri.tryParse(value);
    if (uri == null || uri.host.isEmpty) return '';
    return uri.host.replaceFirst(RegExp(r'^www\.'), '');
  }
}
