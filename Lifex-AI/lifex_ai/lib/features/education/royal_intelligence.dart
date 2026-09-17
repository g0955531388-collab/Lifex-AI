/// =============================================================
/// Lifex-AI — التأهيل
/// الملف: royal_intelligence.dart
/// تمرين أنماط ملكي محلي. ليس مقياس ذكاء سريري وليست أسئلة صفحة ويب منسوخة.
/// =============================================================
library lifex_ai.features.education.royal_intelligence;

import 'dart:math';

class RoyalItem {
  const RoyalItem({
    required this.promptAr,
    required this.options,
    required this.correctIndex,
  });

  final String promptAr;
  final List<String> options;
  final int correctIndex;
}

enum RoyalBand { excellent, strong, average, retry }

class RoyalScore {
  const RoyalScore({
    required this.correct,
    required this.total,
  });

  final int correct;
  final int total;

  int get percent => total == 0 ? 0 : ((correct * 100) / total).round();

  RoyalBand get band {
    if (percent >= 85) return RoyalBand.excellent;
    if (percent >= 70) return RoyalBand.strong;
    if (percent >= 50) return RoyalBand.average;
    return RoyalBand.retry;
  }

  String get labelAr {
    switch (band) {
      case RoyalBand.excellent:
        return 'ممتاز في هذا التمرين — أنماط ثابتة اليوم.';
      case RoyalBand.strong:
        return 'جيد ومنظّم. أعد الجولة بلا مؤقّت إن أحببت.';
      case RoyalBand.average:
        return 'متوسط. التمرين يحتاج تكراراً لا حكماً على الشخص.';
      case RoyalBand.retry:
        return 'ضعيف في هذه الجولة. ليست درجة طبية. جرّب بلا مؤقّت.';
    }
  }
}

class RoyalIntelligenceBank {
  const RoyalIntelligenceBank();

  static const targetCount = 50;
  static const stageSize = 10;
  static const timerMinutes = 15;
  static const disclaimerAr =
      'تمرين محلي للانتباه والأنماط. ليس اختبار ذكاء معتمداً ولا تشخيصاً نفسياً.';

  List<RoyalItem> deck({required bool childMode, int? seed}) {
    final source = childMode ? _child() : _adult();
    return _fill(source, seed: seed);
  }

  List<RoyalItem> _fill(List<RoyalItem> source, {int? seed}) {
    final out = <RoyalItem>[...source];
    var i = 0;
    while (out.length < targetCount && source.isNotEmpty) {
      out.add(source[i % source.length]);
      i++;
    }
    if (out.length > targetCount) {
      return out.sublist(0, targetCount);
    }
    if (seed != null) {
      out.shuffle(Random(seed));
    }
    return out;
  }

  List<RoyalItem> _adult() => [
        ..._handAdult,
        _addSeq(4, 5, 4),
        _addSeq(7, 3, 5),
        _addSeq(11, 6, 4),
        _addSeq(20, -4, 5),
        _mulSeq(3, 2, 4),
        _mulSeq(2, 3, 4),
        _squares(3),
        _oddWord(const ['نهر', 'بحيرة', 'محيط', 'جبل'], 3),
        _oddWord(const ['كتاب', 'دفتر', 'قلم', 'تفاحة'], 3),
        _oddWord(const ['أحمر', 'أزرق', 'أخضر', 'طاولة'], 3),
        const RoyalItem(
          promptAr: 'آلة : عزف  كما  كتاب : ؟',
          options: ['قراءة', 'رف', 'حبر', 'غلاف'],
          correctIndex: 0,
        ),
        const RoyalItem(
          promptAr: 'إذا كانت كل الأقلام أدوات وبعض الأدوات معدنية، فأي عبارة لازمة؟',
          options: [
            'لا استنتاج عن الأقلام المعدنية',
            'كل الأقلام معدنية',
            'لا قلم أداة',
            'كل المعدني قلم',
          ],
          correctIndex: 0,
        ),
        const RoyalItem(
          promptAr: 'مجموع زوايا المثلث بالدرجات؟',
          options: ['90', '180', '270', '360'],
          correctIndex: 1,
        ),
        const RoyalItem(
          promptAr: 'أوجه المكعب؟',
          options: ['4', '5', '6', '8'],
          correctIndex: 2,
        ),
        const RoyalItem(
          promptAr: 'الجذر التربيعي لـ 64؟',
          options: ['6', '7', '8', '9'],
          correctIndex: 2,
        ),
        const RoyalItem(
          promptAr: '5! = ؟',
          options: ['60', '100', '120', '150'],
          correctIndex: 2,
        ),
        const RoyalItem(
          promptAr: 'بعد غد من الأربعاء؟',
          options: ['الخميس', 'الجمعة', 'السبت', 'الأحد'],
          correctIndex: 1,
        ),
        const RoyalItem(
          promptAr: 'نهار يقابل؟',
          options: ['فجر', 'صباح', 'ليل', 'ظهر'],
          correctIndex: 2,
        ),
        const RoyalItem(
          promptAr: 'إذا 4س = 28 فما س؟',
          options: ['5', '6', '7', '8'],
          correctIndex: 2,
        ),
        const RoyalItem(
          promptAr: 'محيط مربع ضلعه 5؟',
          options: ['10', '15', '20', '25'],
          correctIndex: 2,
        ),
      ];

  List<RoyalItem> _child() => [
        ..._handChild,
        _addSeq(2, 2, 4),
        _addSeq(1, 3, 4),
        _addSeq(10, 10, 3),
        _addSeq(5, 5, 4),
        _oddWord(const ['قطة', 'كلب', 'حصان', 'كرسي'], 3),
        _oddWord(const ['تفاحة', 'موز', 'برتقال', 'سيارة'], 3),
        const RoyalItem(
          promptAr: 'شكل بثلاث زوايا؟',
          options: ['دائرة', 'مثلث', 'مربع', 'خط'],
          correctIndex: 1,
        ),
        const RoyalItem(
          promptAr: 'لون السماء نهاراً غالباً؟',
          options: ['أخضر', 'أزرق', 'أسود', 'ذهبي'],
          correctIndex: 1,
        ),
        const RoyalItem(
          promptAr: '3 + 4 = ؟',
          options: ['5', '6', '7', '8'],
          correctIndex: 2,
        ),
        const RoyalItem(
          promptAr: 'أصابع اليد الواحدة غالباً؟',
          options: ['4', '5', '6', '8'],
          correctIndex: 1,
        ),
        const RoyalItem(
          promptAr: 'العدد بعد 9؟',
          options: ['8', '10', '11', '19'],
          correctIndex: 1,
        ),
        const RoyalItem(
          promptAr: 'حيوان يقول مواء؟',
          options: ['كلب', 'قطة', 'بقرة', 'عصفور'],
          correctIndex: 1,
        ),
        const RoyalItem(
          promptAr: 'عكس النهار؟',
          options: ['الليل', 'الظهر', 'العصر', 'الفجر'],
          correctIndex: 0,
        ),
        const RoyalItem(
          promptAr: 'الحرف بعد أ؟',
          options: ['ب', 'ت', 'ج', 'د'],
          correctIndex: 0,
        ),
        const RoyalItem(
          promptAr: 'شهور السنة؟',
          options: ['10', '11', '12', '13'],
          correctIndex: 2,
        ),
        const RoyalItem(
          promptAr: '2 × 4 = ؟',
          options: ['6', '7', '8', '9'],
          correctIndex: 2,
        ),
        const RoyalItem(
          promptAr: 'يوم بعد الجمعة؟',
          options: ['الخميس', 'السبت', 'الأحد', 'الإثنين'],
          correctIndex: 1,
        ),
        const RoyalItem(
          promptAr: 'الماء في الكأس غالباً؟',
          options: ['صلب', 'سائل', 'نار', 'خشب'],
          correctIndex: 1,
        ),
        const RoyalItem(
          promptAr: 'شكل دائري؟',
          options: ['مربع', 'مثلث', 'دائرة', 'نجمة حادة'],
          correctIndex: 2,
        ),
      ];

  static const _handAdult = [
    RoyalItem(
      promptAr: 'أكمل مربعات: 9، 16، 25، …',
      options: ['30', '32', '36', '49'],
      correctIndex: 2,
    ),
    RoyalItem(
      promptAr: 'سلسلة: 1، 1، 2، 3، 5، …',
      options: ['7', '8', '9', '10'],
      correctIndex: 1,
    ),
    RoyalItem(
      promptAr: 'أعداد أولية: 11، 13، 17، 19، …',
      options: ['21', '23', '25', '27'],
      correctIndex: 1,
    ),
    RoyalItem(
      promptAr: '(9 − 3) × 2 = ؟',
      options: ['8', '10', '12', '18'],
      correctIndex: 2,
    ),
  ];

  static const _handChild = [
    RoyalItem(
      promptAr: '2، 4، 6، 8، …',
      options: ['9', '10', '12', '16'],
      correctIndex: 1,
    ),
    RoyalItem(
      promptAr: '1، 3، 5، …',
      options: ['6', '7', '8', '9'],
      correctIndex: 1,
    ),
    RoyalItem(
      promptAr: 'المختلف: شمس، قمر، نجمة، قلم',
      options: ['شمس', 'قمر', 'نجمة', 'قلم'],
      correctIndex: 3,
    ),
  ];

  RoyalItem _addSeq(int start, int step, int terms) {
    final values = [for (var i = 0; i < terms; i++) start + i * step];
    final next = start + terms * step;
    return RoyalItem(
      promptAr: 'أكمل بالجمع الثابت: ${values.join('، ')}، …',
      options: ['$next', '${next + step.abs()}', '${next - 1}', '${next + 2}'],
      correctIndex: 0,
    );
  }

  RoyalItem _mulSeq(int start, int factor, int terms) {
    final values = <int>[start];
    var n = start;
    for (var i = 1; i < terms; i++) {
      n *= factor;
      values.add(n);
    }
    final next = n * factor;
    return RoyalItem(
      promptAr: 'أكمل بالضرب: ${values.join('، ')}، …',
      options: ['$next', '${next + factor}', '${values.last + factor}', '${next * 2}'],
      correctIndex: 0,
    );
  }

  RoyalItem _squares(int from) {
    final values = [for (var i = from; i < from + 3; i++) i * i];
    final next = (from + 3) * (from + 3);
    return RoyalItem(
      promptAr: 'مربعات متتالية: ${values.join('، ')}، …',
      options: ['$next', '${next + from}', '${next - 1}', '${next + 5}'],
      correctIndex: 0,
    );
  }

  RoyalItem _oddWord(List<String> words, int oddIndex) {
    return RoyalItem(
      promptAr: 'الكلمة المختلفة: ${words.join('، ')}',
      options: words,
      correctIndex: oddIndex,
    );
  }
}

class RoyalIntelligenceSession {
  RoyalIntelligenceSession.start({
    required this.childMode,
    required this.shuffle,
    required this.useTimer,
    DateTime? now,
    int? seed,
  })  : startedAt = now ?? DateTime.now(),
        items = const RoyalIntelligenceBank().deck(
          childMode: childMode,
          seed: shuffle ? (seed ?? (now ?? DateTime.now()).millisecondsSinceEpoch) : null,
        ) {
    deadline = useTimer
        ? startedAt.add(
            const Duration(minutes: RoyalIntelligenceBank.timerMinutes),
          )
        : null;
  }

  final bool childMode;
  final bool shuffle;
  final bool useTimer;
  final DateTime startedAt;
  late final DateTime? deadline;
  final List<RoyalItem> items;
  final Map<int, int> picks = {};

  void pick(int index, int option) {
    if (index < 0 || index >= items.length) return;
    if (option < 0 || option >= items[index].options.length) return;
    picks[index] = option;
  }

  bool timedOut(DateTime now) =>
      deadline != null && !now.isBefore(deadline!);

  Duration remaining(DateTime now) {
    if (deadline == null) return Duration.zero;
    final left = deadline!.difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  String clockLabel(DateTime now) {
    if (deadline == null) return 'بدون مؤقّت';
    if (timedOut(now)) return 'انتهى الوقت';
    final left = remaining(now);
    final m = left.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = left.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool immediateCorrect(int index) {
    final chosen = picks[index];
    if (chosen == null) return false;
    return chosen == items[index].correctIndex;
  }

  RoyalScore grade() {
    var correct = 0;
    for (var i = 0; i < items.length; i++) {
      if (picks[i] == items[i].correctIndex) correct++;
    }
    return RoyalScore(correct: correct, total: items.length);
  }

  String reportAr() {
    final score = grade();
    final mode = childMode ? 'أطفال' : 'كبار';
    final buffer = StringBuffer()
      ..writeln('تمرين الذكاء الملكي — وضع $mode')
      ..writeln('النتيجة: ${score.correct} من ${score.total} (${score.percent}%)')
      ..writeln(score.labelAr)
      ..writeln(RoyalIntelligenceBank.disclaimerAr);
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final chosen = picks[i];
      final you = chosen == null ? 'بلا إجابة' : item.options[chosen];
      buffer
        ..writeln('س${i + 1}: ${item.promptAr}')
        ..writeln('- إجابتك: $you')
        ..writeln('- المعتمدة في التمرين: ${item.options[item.correctIndex]}');
    }
    return buffer.toString();
  }

  String speakItem(int index) {
    if (index < 0 || index >= items.length) {
      return 'لا سؤال معروضاً. ابدأ التمرين.';
    }
    final item = items[index];
    final parts = <String>['سؤال ${index + 1}: ${item.promptAr}'];
    for (var i = 0; i < item.options.length; i++) {
      parts.add('خيار ${i + 1}: ${item.options[i]}');
    }
    return parts.join(' . ');
  }
}
