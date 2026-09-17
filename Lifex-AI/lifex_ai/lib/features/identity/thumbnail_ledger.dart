/// =============================================================
/// Lifex-AI — الهوية البصرية
/// الملف: thumbnail_ledger.dart
/// مصدر الصورة المصغّرة: الختم الرسمي أو صورة يختارها صاحب الملف.
/// =============================================================
library lifex_ai.features.identity.thumbnail_ledger;

import '../network_box/profile_box_store.dart';

class ThumbnailLedger {
  ThumbnailLedger(this.store);

  final ProfileBoxStore store;

  String? get customPath {
    final path = store.stringField(BoxKeys.profileThumbnailPath)?.trim();
    if (path == null || path.isEmpty) return null;
    return path;
  }

  bool get usesOfficialSeal => customPath == null;

  String statusAr() {
    if (usesOfficialSeal) {
      return 'المعروضة الآن: ختم Lifex-AI الرسمي.';
    }
    return 'المعروضة الآن: صورة اخترتها لهذا الملف على الجهاز.';
  }

  void setCustomPath(String path) {
    store.setString(BoxKeys.profileThumbnailPath, path.trim());
  }

  void restoreOfficialSeal() {
    store.setString(BoxKeys.profileThumbnailPath, '');
  }
}
