/// =============================================================
/// Lifex-AI — المرجع المحلي
/// الملف: local_knowledge.dart
/// بحث في قواعد الأمراض والأدوية والأعراض والتحاليل على الجهاز.
/// =============================================================
library lifex_ai.core.local_knowledge;

import 'dart:convert';

import 'package:flutter/services.dart';

class KnowledgeHit {
  const KnowledgeHit({
    required this.kindAr,
    required this.titleAr,
    required this.detailAr,
  });

  final String kindAr;
  final String titleAr;
  final String detailAr;
}

class LocalKnowledge {
  LocalKnowledge({
    required this.diseases,
    required this.medications,
    required this.symptoms,
    required this.tests,
    required this.disclaimerAr,
  });

  final List<Map<String, dynamic>> diseases;
  final List<Map<String, dynamic>> medications;
  final List<Map<String, dynamic>> symptoms;
  final List<Map<String, dynamic>> tests;
  final String disclaimerAr;

  static Future<LocalKnowledge> load() async {
    Future<Map<String, dynamic>> read(String name) async {
      final raw =
          await rootBundle.loadString('lib/data/medical/$name');
      return jsonDecode(raw) as Map<String, dynamic>;
    }

    final diseasesJson = await read('diseases_database.json');
    final medsJson = await read('medications_database.json');
    final symptomsJson = await read('symptoms_database.json');
    final testsJson = await read('tests_database.json');
    return LocalKnowledge(
      diseases: List<Map<String, dynamic>>.from(
          diseasesJson['diseases'] as List? ?? const []),
      medications: List<Map<String, dynamic>>.from(
          medsJson['medications'] as List? ?? const []),
      symptoms: List<Map<String, dynamic>>.from(
          symptomsJson['symptoms'] as List? ?? const []),
      tests: List<Map<String, dynamic>>.from(
          testsJson['tests'] as List? ?? const []),
      disclaimerAr: (diseasesJson['_meta'] as Map?)?['disclaimer_ar']
              as String? ??
          'مرجع توعية فقط. ليس تشخيصاً.',
    );
  }

  List<KnowledgeHit> search(String query) {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final hits = <KnowledgeHit>[];
    void scan(
      List<Map<String, dynamic>> rows,
      String kind,
      List<String> keys,
    ) {
      for (final row in rows) {
        final blob = keys.map((k) => '${row[k] ?? ''}').join(' ');
        if (!blob.contains(q)) continue;
        hits.add(
          KnowledgeHit(
            kindAr: kind,
            titleAr: (row['nameAr'] ?? row['id']).toString(),
            detailAr: (row['generalInfoAr'] ??
                    row['nameEn'] ??
                    row['descriptionAr'] ??
                    '')
                .toString(),
          ),
        );
        if (hits.length >= 12) return;
      }
    }

    scan(diseases, 'مرض', ['nameAr', 'nameEn', 'generalInfoAr']);
    scan(medications, 'دواء', ['nameAr', 'nameEn']);
    scan(symptoms, 'عرض', ['nameAr', 'nameEn']);
    scan(tests, 'تحليل', ['nameAr', 'nameEn']);
    return hits;
  }
}
