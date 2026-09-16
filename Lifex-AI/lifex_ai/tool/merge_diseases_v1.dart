import 'dart:convert';
import 'dart:io';

const _categoryMap = {
  'القلب والأوعية الدموية': 'cardiovascular',
  'الغدد الصماء': 'endocrine',
  'غدد صماء': 'endocrine',
  'الدم والأورام': 'oncology',
  'دم وأورام': 'oncology',
  'الجهاز العصبي': 'neurology',
  'جهاز عصبي': 'neurology',
  'الهضمي والكبد': 'gastroenterology',
  'هضمي وكبد': 'gastroenterology',
  'الكلى والمسالك البولية': 'nephrology',
  'كلى ومسالك بولية': 'nephrology',
  'العظام والمفاصل والروماتيزم': 'rheumatology',
  'عظام ومفاصل وروماتيزم': 'rheumatology',
  'الجلد والأظافر': 'dermatology',
  'جلد وأظافر': 'dermatology',
  'جلد عام': 'dermatology',
  'الجهاز التنفسي': 'respiratory',
  'جهاز تنفسي': 'respiratory',
  'الصحة النفسية': 'psychiatry',
  'صحة نفسية': 'psychiatry',
  'العيون': 'ophthalmology',
  'عيون': 'ophthalmology',
  'الأذن والأنف والحنجرة': 'ent',
  'أذن وأنف وحنجرة': 'ent',
  'أمراض معدية متنوعة': 'infectious',
  'الأمراض المعدية': 'infectious',
};

void main() {
  final currentFile = File(
    'lib/data/medical/diseases_database.json',
  );
  final v1File = File(
    r'C:\Users\sdsds\Downloads\lifex-ai-diseases-database-v1.json',
  );

  final current =
      jsonDecode(currentFile.readAsStringSync()) as Map<String, dynamic>;
  final v1 = jsonDecode(v1File.readAsStringSync()) as Map<String, dynamic>;
  final diseases = (current['diseases'] as List).cast<Map<String, dynamic>>();

  final existingKeys = <String>{};
  var maxId = 0;
  for (final disease in diseases) {
    existingKeys.add(_norm(disease['nameEn'] as String? ?? ''));
    existingKeys.add(_norm(disease['nameAr'] as String? ?? ''));
    final id = disease['id'] as String? ?? 'd000';
    final parsed = int.tryParse(id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (parsed > maxId) maxId = parsed;
  }

  var added = 0;
  v1.forEach((groupName, value) {
    if (value is! List) return;
    for (final raw in value) {
      if (raw is! Map) continue;
      final item = Map<String, dynamic>.from(raw);
      final parsed = _splitName(item['name'] as String? ?? '');
      final nameEn = parsed.$1;
      final nameAr = parsed.$2.isEmpty
          ? (item['description'] as String? ?? nameEn)
          : parsed.$2;
      if (existingKeys.contains(_norm(nameEn)) ||
          existingKeys.contains(_norm(nameAr))) {
        continue;
      }
      maxId += 1;
      added += 1;
      existingKeys
        ..add(_norm(nameEn))
        ..add(_norm(nameAr));
      diseases.add({
        'id': 'd${maxId.toString().padLeft(3, '0')}',
        'nameAr': nameAr,
        'nameEn': nameEn,
        'category': _categoryMap[item['category']] ??
            _categoryMap[groupName] ??
            'general',
        'commonSymptomsIds': <String>[],
        'riskFactors': <String>[],
        'generalInfoAr': item['description'] as String? ?? '',
        'requiresImmediateAttention': false,
        'source': 'lifex-ai-diseases-database-v1',
      });
    }
  });

  final meta = Map<String, dynamic>.from(current['_meta'] as Map);
  meta['lastUpdated'] = '2026-09-16';
  meta['schemaVersion'] = '7.1.0';
  meta['mergedFrom'] =
      'lifex-ai-diseases-database-v1.json (131 unique records; added $added missing)';
  current['_meta'] = meta;
  current['diseases'] = diseases;

  const encoder = JsonEncoder.withIndent('  ');
  currentFile.writeAsStringSync('${encoder.convert(current)}\n');
  stdout.writeln('Added $added diseases. Total now ${diseases.length}.');
}

String _norm(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\u0600-\u06ff]'), '');

(String, String) _splitName(String raw) {
  if (raw.contains('|')) {
    final parts = raw.split('|');
    return (parts.first.trim(), parts.last.replaceAll(RegExp(r'\(.*\)'), '').trim());
  }
  final paren = RegExp(r'^(.*)\(([^)]+)\)\s*$').firstMatch(raw);
  if (paren != null && RegExp(r'[A-Za-z]').hasMatch(paren.group(2)!)) {
    return (paren.group(2)!.trim(), paren.group(1)!.trim());
  }
  if (RegExp(r'[\u0600-\u06ff]').hasMatch(raw)) {
    return (raw, raw);
  }
  return (raw, raw);
}
