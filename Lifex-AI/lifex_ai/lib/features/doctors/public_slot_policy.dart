/// =============================================================
/// Lifex-AI — الأطباء
/// الملف: public_slot_policy.dart
/// حصص الصفحة العامة: صباح ومساء، تعديل قبل 12 ساعة، بلا مرضى وهميين.
/// =============================================================
library lifex_ai.features.doctors.public_slot_policy;

class PublicSlotPolicy {
  const PublicSlotPolicy({
    this.stepMinutes = 30,
    this.modifyLead = const Duration(hours: 12),
  });

  final int stepMinutes;
  final Duration modifyLead;

  List<String> clockLabels() => clocksFor(
        workHours: 3 + 4,
        stepMinutes: stepMinutes,
        startHour: 9,
        afternoonStart: 15,
        afternoonHours: 4,
      );

  /// يوم عمل متواصل يقدّره الطبيب: 12 ساعة كل نصف ساعة = 24 حصة.
  List<String> clocksFor({
    required int workHours,
    required int stepMinutes,
    required int startHour,
    int afternoonStart = -1,
    int afternoonHours = 0,
  }) {
    final step = stepMinutes < 5 ? 5 : stepMinutes;
    final out = <String>[];
    void range(int start, int hours) {
      final end = start + hours;
      for (var h = start; h < end; h++) {
        for (var m = 0; m < 60; m += step) {
          out.add(
            '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}',
          );
        }
      }
    }

    if (afternoonStart < 0) {
      range(startHour, workHours);
    } else {
      range(startHour, 3);
      range(afternoonStart, afternoonHours);
    }
    return out;
  }

  DateTime slotAt(DateTime day, String clock) {
    final parts = clock.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  bool canModify(DateTime slot, DateTime now) =>
      slot.difference(now) > modifyLead;
}
