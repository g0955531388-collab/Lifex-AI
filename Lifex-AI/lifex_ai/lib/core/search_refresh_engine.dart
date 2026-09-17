/// =============================================================
/// Lifex-AI — تحديث قواعد البحث
/// الملف: search_refresh_engine.dart
/// زر البحث والجلب: يمسح الأصول المحلية ويجرب الخادم ثم يضيف للقواعد الدائمة.
/// =============================================================
library lifex_ai.core.search_refresh_engine;

import '../data/medical_database_manager.dart';
import 'lasting_search_index.dart';
import 'local_knowledge.dart';

class SearchRefreshReport {
  const SearchRefreshReport({
    required this.localIngested,
    required this.remoteOk,
    required this.messageAr,
  });

  final int localIngested;
  final bool remoteOk;
  final String messageAr;
}

class SearchRefreshEngine {
  const SearchRefreshEngine();

  Future<SearchRefreshReport> refresh({
    required LocalKnowledge knowledge,
    required LastingSearchIndex lasting,
    required MedicalDatabaseManager database,
  }) async {
    final before = lasting.count;
    lasting.ingest(knowledge.diseases);
    lasting.ingest(knowledge.medications);
    lasting.ingest(knowledge.symptoms);
    lasting.ingest(knowledge.tests);
    lasting.ingest(knowledge.namedConditions);
    lasting.ingest(knowledge.cameraSigns);
    final localIngested = lasting.count - before;

    final remote = await database.downloadAndUpdateBundle();
    final remoteLine = remote.success
        ? remote.messageAr
        : 'الخادم لم يُضف حزمة: ${remote.messageAr} يبقى البحث المحلي بلا انقطاع.';

    return SearchRefreshReport(
      localIngested: localIngested,
      remoteOk: remote.success,
      messageAr:
          'جُلب $localIngested بنداً من قواعد الجهاز إلى المحرك الداخلي الدائم. $remoteLine',
    );
  }
}
