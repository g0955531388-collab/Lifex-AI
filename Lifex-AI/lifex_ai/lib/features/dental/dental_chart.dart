/// =============================================================
/// Lifex-AI — طب الأسنان
/// الملف: dental_chart.dart
/// مخطط أسنان FDI على مستوى السن، من النسخة المكتبية.
/// =============================================================
library lifex_ai.features.dental.dental_chart;

class DentalChart {
  DentalChart({Map<String, String>? notes, this.nextVisit = ''})
      : notes = notes ?? {};

  static const List<int> fdiAdult = [
    18, 17, 16, 15, 14, 13, 12, 11,
    21, 22, 23, 24, 25, 26, 27, 28,
    48, 47, 46, 45, 44, 43, 42, 41,
    31, 32, 33, 34, 35, 36, 37, 38,
  ];

  final Map<String, String> notes;
  String nextVisit;

  String noteFor(int tooth) => notes['$tooth'] ?? '';

  void setNote(int tooth, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      notes.remove('$tooth');
    } else {
      notes['$tooth'] = trimmed;
    }
  }

  Map<String, dynamic> toJson() => {
        'notes': notes,
        'nextVisit': nextVisit,
      };

  factory DentalChart.fromJson(Map<String, dynamic> json) => DentalChart(
        notes: Map<String, String>.from(
          (json['notes'] as Map? ?? {}).map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ),
        ),
        nextVisit: json['nextVisit'] as String? ?? '',
      );
}
