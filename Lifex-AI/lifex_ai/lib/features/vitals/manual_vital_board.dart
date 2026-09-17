/// =============================================================
/// Lifex-AI — القياسات الحيوية
/// الملف: manual_vital_board.dart
/// لوحة قياسات يدوية. الأرقام من المستخدم أو جهازه، وليست من بكسل
/// صورة ولا من قيم ثابتة (37 / 98 / 72 / 120/80). لون البول ملاحظة
/// تُدخل، لا تحليل مخبري. نغمة MIDI تُحسب من النبض المدخل دون منفذ.
/// =============================================================
library lifex_ai.features.vitals.manual_vital_board;

import 'dart:math' as math;

class ManualVitalDraft {
  const ManualVitalDraft({
    this.tempC,
    this.oxygenPercent,
    this.pulseBpm,
    this.bloodPressure,
    this.urineColorNote,
  });

  final double? tempC;
  final int? oxygenPercent;
  final int? pulseBpm;
  final String? bloodPressure;
  final String? urineColorNote;

  bool get hasAnyValue =>
      tempC != null ||
      oxygenPercent != null ||
      pulseBpm != null ||
      (bloodPressure != null && bloodPressure!.trim().isNotEmpty) ||
      (urineColorNote != null &&
          urineColorNote!.trim().isNotEmpty &&
          urineColorNote != UrineColorNote.none);
}

class ManualVitalScore {
  const ManualVitalScore({
    required this.points,
    required this.statusAr,
    required this.messageAr,
    required this.completeEnough,
  });

  final int points;
  final String statusAr;
  final String messageAr;
  final bool completeEnough;
}

/// قواعد محلية على أرقام أدخلها المستخدم. ليست تشخيصاً.
class ManualVitalPolicy {
  const ManualVitalPolicy();

  static const refuseBitmapAnalysisAr =
      'لن أستخرج حرارة أو أكسجين أو نبضاً أو لون بول من صورة. '
      'أدخل الأرقام من ميزانك أو مقياس الأكسجين أو المختبر.';

  static const neverInventAr =
      'لا تُملأ القيم الناقصة بـ 37 أو 98 أو 72 أو 120/80.';

  ManualVitalScore score(ManualVitalDraft draft) {
    if (!draft.hasAnyValue) {
      return const ManualVitalScore(
        points: 0,
        statusAr: 'لا أرقام بعد',
        messageAr:
            'لم تُدخل قياساً. لن أعلن استقراراً ولن أخترع قراءة من كاميرا.',
        completeEnough: false,
      );
    }

    var points = 0;
    final notes = <String>[];
    if (draft.oxygenPercent != null) {
      if (draft.oxygenPercent! < 94) {
        points += 40;
        notes.add('الأكسجين الذي أدخلته أقل من 94.');
      } else {
        notes.add('الأكسجين الذي أدخلته لا يتجاوز عتبة التنبيه المحلية.');
      }
    }
    if (draft.tempC != null) {
      if (draft.tempC! > 38.5) {
        points += 30;
        notes.add('الحرارة التي أدخلتها أعلى من 38.5.');
      } else {
        notes.add('الحرارة التي أدخلتها لا تتجاوز عتبة التنبيه المحلية.');
      }
    }
    if (draft.pulseBpm != null) {
      notes.add('النبض المسجّل ${draft.pulseBpm} — ليس من حسّاس مربوط.');
    }
    if (draft.bloodPressure != null && draft.bloodPressure!.trim().isNotEmpty) {
      notes.add('الضغط كما كتبته: ${draft.bloodPressure!.trim()}.');
    }
    if (draft.urineColorNote != null &&
        draft.urineColorNote!.trim().isNotEmpty &&
        draft.urineColorNote != UrineColorNote.none) {
      notes.add(UrineColorNote.lineAr(draft.urineColorNote!));
    }

    points = points.clamp(0, 100);
    final alert = points > 50;
    return ManualVitalScore(
      points: points,
      statusAr: alert
          ? 'تنبيه من الأرقام التي أدخلتها'
          : 'لا عتبة محلية على الأرقام المكتملة',
      messageAr:
          '${notes.join(' ')} النتيجة $points من 100 محلياً. ليست تشخيصاً ولا نتيجة مختبر.',
      completeEnough: true,
    );
  }
}

class UrineColorNote {
  const UrineColorNote._();

  static const none = 'لم يُدخل';
  static const options = [
    none,
    'فاتح',
    'أصفر',
    'داكن',
    'محمر',
    'أخرى كما أصفها',
  ];

  static const honestyAr =
      'لون البول ملاحظة تدخلها أنت. ليس تحليلاً مخبرياً ولا قراءة من بكسل الصورة.';

  static String lineAr(String color) =>
      'ملاحظة لون البول: $color. ليست نتيجة تحليل.';
}

/// حساب نغمة من النبض المدخل. المنفذ غير مربوط حتى يوجد MIDI حقيقي.
class MidiPulseCue {
  const MidiPulseCue({this.portBound = false});

  final bool portBound;

  int noteForBpm(int bpm) {
    if (bpm <= 0) return 0;
    final raw = 69 + (12 * (math.log(bpm / 60) / math.ln2));
    return raw.truncate().clamp(0, 127);
  }

  String lineAr(int bpm) {
    final note = noteForBpm(bpm);
    if (portBound) {
      return 'نغمة MIDI رقم $note من نبض $bpm الذي أدخلته.';
    }
    return 'نغمة MIDI رقم $note محسوبة من نبض $bpm الذي أدخلته. '
        'لا منفذ MIDI مربوط على هذا الجهاز.';
  }
}
