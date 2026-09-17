/// =============================================================
/// Lifex-AI — وحدة الصوت
/// الملف: spoken_blood_type.dart
/// فهم الفصيلة من الكلام أو الكتابة، بما فيها تقريب النطق.
/// =============================================================
library lifex_ai.features.voice.spoken_blood_type;

import '../hospital/hospital_blood_bank.dart';

class SpokenBloodType {
  const SpokenBloodType();

  BloodTypeSimple? match(String raw) {
    final folded = raw.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    final compact = folded.replaceAll(' ', '');
    const pairs = <String, BloodTypeSimple>{
      'o+': BloodTypeSimple.oPositive,
      'o-': BloodTypeSimple.oNegative,
      'a+': BloodTypeSimple.aPositive,
      'a-': BloodTypeSimple.aNegative,
      'b+': BloodTypeSimple.bPositive,
      'b-': BloodTypeSimple.bNegative,
      'ab+': BloodTypeSimple.abPositive,
      'ab-': BloodTypeSimple.abNegative,
      'أو+': BloodTypeSimple.oPositive,
      'او+': BloodTypeSimple.oPositive,
      'أو-': BloodTypeSimple.oNegative,
      'او-': BloodTypeSimple.oNegative,
    };
    for (final entry in pairs.entries) {
      if (compact.contains(entry.key)) return entry.value;
    }
    if (_has(folded, ['أو موجب', 'او موجب', 'o positive', 'o موجب', 'زمرة أو'])) {
      if (!folded.contains('سالب') && !folded.contains('negative')) {
        return BloodTypeSimple.oPositive;
      }
    }
    if (_has(folded, ['أو سالب', 'او سالب', 'o negative', 'o سالب'])) {
      return BloodTypeSimple.oNegative;
    }
    if (_has(folded, ['أي بي موجب', 'ab موجب', 'ab positive'])) {
      return BloodTypeSimple.abPositive;
    }
    if (_has(folded, ['أي بي سالب', 'ab سالب', 'ab negative'])) {
      return BloodTypeSimple.abNegative;
    }
    if (_has(folded, ['أيه موجب', 'a موجب', 'a positive']) &&
        !folded.contains('ab')) {
      return BloodTypeSimple.aPositive;
    }
    if (_has(folded, ['أيه سالب', 'a سالب', 'a negative']) &&
        !folded.contains('ab')) {
      return BloodTypeSimple.aNegative;
    }
    if (_has(folded, ['بي موجب', 'b موجب', 'b positive']) &&
        !folded.contains('ab')) {
      return BloodTypeSimple.bPositive;
    }
    if (_has(folded, ['بي سالب', 'b سالب', 'b negative']) &&
        !folded.contains('ab')) {
      return BloodTypeSimple.bNegative;
    }
    return null;
  }

  /// بقايا البحث بعد نزع طلب الفصيلة، مثل «كاسم» إن لم تُعرف الزمرة.
  String leftoverQuery(String raw) {
    var text = raw;
    const drop = [
      'أريد',
      'اريد',
      'افتح',
      'بنك الدم',
      'طلب دم',
      'شبكة الدم',
      'البحث عن',
      'ابحث عن',
      'ابحث',
      'بحث',
      'زمرة',
      'فصيلة',
      'blood bank',
      'blood type',
    ];
    for (final token in drop) {
      text = text.replaceAll(RegExp(token, caseSensitive: false), ' ');
    }
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  bool looksLikeBloodRequest(String raw) {
    final folded = raw.toLowerCase();
    const keys = [
      'بنك الدم',
      'طلب دم',
      'شبكة الدم',
      'زمرة',
      'فصيلة',
      'blood bank',
      'blood type',
      'blood group',
    ];
    return keys.any(folded.contains);
  }

  bool _has(String folded, List<String> needles) =>
      needles.any(folded.contains);
}
