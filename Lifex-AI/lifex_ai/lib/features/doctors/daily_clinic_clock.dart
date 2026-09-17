/// =============================================================
/// Lifex-AI — يوميات الطبيب
/// الملف: daily_clinic_clock.dart
/// توليد حصص من التاريخ والعدد ومدة الفحص ووقت البدء. بلا مرضى وهميين.
/// =============================================================
library lifex_ai.features.doctors.daily_clinic_clock;

class ClinicSlotDraft {
  const ClinicSlotDraft({
    required this.index,
    required this.start,
  });

  final int index;
  final DateTime start;

  DateTime endAfter(int minutes) => start.add(Duration(minutes: minutes));

  String clockLabel() {
    final h = start.hour.toString().padLeft(2, '0');
    final m = start.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class DailyClinicClock {
  const DailyClinicClock();

  List<ClinicSlotDraft> buildDay({
    required DateTime day,
    required int maxPatients,
    required int examMinutes,
    required int startHour,
    required int startMinute,
  }) {
    final count = maxPatients < 1 ? 1 : maxPatients;
    final span = examMinutes < 5 ? 5 : examMinutes;
    var cursor = DateTime(day.year, day.month, day.day, startHour, startMinute);
    return List<ClinicSlotDraft>.generate(count, (i) {
      final slot = ClinicSlotDraft(index: i + 1, start: cursor);
      cursor = cursor.add(Duration(minutes: span));
      return slot;
    });
  }
}
