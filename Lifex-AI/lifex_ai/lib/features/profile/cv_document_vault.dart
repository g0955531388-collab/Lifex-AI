/// =============================================================
/// Lifex-AI — السي في الصحي
/// الملف: cv_document_vault.dart
/// وثائق الكاميرا تُرفق للسي في بغلاف محلي. ليست AES عسكرياً ولا درايف مربوطاً.
/// =============================================================
library lifex_ai.features.profile.cv_document_vault;

import '../network_box/profile_box_store.dart';
import 'health_profile.dart';

class CvDocumentVault {
  CvDocumentVault(this.profile);

  final HealthProfile profile;

  static const cloudChoices = [
    'Google Drive',
    'OneDrive',
    'Dropbox',
    'سحابة أخرى يختارها صاحب الحساب',
  ];

  int _fold(String text) {
    var hash = 2166136261;
    for (final unit in text.codeUnits) {
      hash ^= unit;
      hash = (hash * 16777619) & 0x7fffffff;
    }
    return hash;
  }

  Map<String, dynamic> attach({
    required String title,
    required String path,
    required String passphrase,
    String detail = '',
  }) {
    final seal = _fold('$passphrase|$path|${profile.profileId}');
    return ProfileBoxStore(profile).add(BoxKeys.cvVault, {
      'title': title,
      'detail': detail,
      'path': path,
      'sealed': true,
      'seal': seal,
      'honestyAr':
          'غلاف محلي بعبارة سرّ صاحب الحساب. الملف على الجهاز. رفع درايف أو غيرها من ورقة المشاركة بحسابه هو.',
    });
  }

  bool unlock(Map<String, dynamic> record, String passphrase) {
    final path = record['path']?.toString() ?? '';
    final expected = record['seal'];
    return expected == _fold('$passphrase|$path|${profile.profileId}');
  }

  List<Map<String, dynamic>> all() => ProfileBoxStore(profile).list(BoxKeys.cvVault);
}
