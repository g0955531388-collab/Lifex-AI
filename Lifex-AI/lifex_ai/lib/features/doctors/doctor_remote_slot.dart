/// =============================================================
/// Lifex-AI — يوميات الطبيب
/// الملف: doctor_remote_slot.dart
/// المريض يحجز حصة فارغة عن بعد في يوميات الطبيب على هذا الجهاز.
/// =============================================================
library lifex_ai.features.doctors.doctor_remote_slot;

import '../network_box/profile_box_store.dart';
import '../profile/health_profile.dart';
import 'clinic_day_board.dart';
import 'daily_clinic_clock.dart';

class DoctorRemoteSlot {
  const DoctorRemoteSlot();

  static String dayKey(DateTime day) =>
      '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

  List<Map<String, dynamic>> slotsOn(HealthProfile doctor, DateTime day) {
    final rows = ProfileBoxStore(doctor)
        .list(BoxKeys.doctorDiaryDays)
        .where((item) => item['day'] == dayKey(day));
    if (rows.isEmpty) return const [];
    final raw = rows.first['slots'];
    if (raw is! List) return const [];
    return [
      for (final item in raw)
        if (item is Map) Map<String, dynamic>.from(item),
    ];
  }

  bool isEmptyAt(HealthProfile doctor, DateTime day, String time) {
    final slots = slotsOn(doctor, day);
    if (slots.isEmpty) return true;
    final hit = slots.where((item) => item['time'] == time);
    if (hit.isEmpty) return true;
    return hit.first['booked'] != true;
  }

  String? book({
    required HealthProfile doctor,
    required HealthProfile patient,
    required DateTime day,
    required String time,
    required int workHours,
    required int examMinutes,
    required int startHour,
  }) {
    if (!isEmptyAt(doctor, day, time)) {
      return 'الحصة محجوزة.';
    }
    final store = ProfileBoxStore(doctor);
    final days = store.list(BoxKeys.doctorDiaryDays);
    final key = dayKey(day);
    var row = days.where((item) => item['day'] == key).toList();
    List<Map<String, dynamic>> slots;
    if (row.isEmpty) {
      final drafts = const DailyClinicClock().buildDay(
        day: day,
        maxPatients: ((workHours * 60) / examMinutes).floor().clamp(1, 48),
        examMinutes: examMinutes,
        startHour: startHour,
        startMinute: 0,
      );
      slots = [
        for (final draft in drafts)
          const ClinicEmptyBoard().emptySlot(
            index: draft.index,
            time: draft.clockLabel(),
          ),
      ];
    } else {
      final raw = row.first['slots'];
      slots = raw is List
          ? [
              for (final item in raw)
                if (item is Map) Map<String, dynamic>.from(item),
            ]
          : [];
    }
    final index = slots.indexWhere((item) => item['time'] == time);
    if (index < 0) {
      slots.add({
        ...const ClinicEmptyBoard().emptySlot(index: slots.length + 1, time: time),
        'booked': true,
        'alias': patient.fullName,
        'linkedProfileId': patient.profileId,
      });
    } else {
      if (slots[index]['booked'] == true) return 'الحصة محجوزة.';
      slots[index]['booked'] = true;
      slots[index]['alias'] = patient.fullName;
      slots[index]['linkedProfileId'] = patient.profileId;
    }
    days.removeWhere((item) => item['day'] == key);
    days.add({
      'day': key,
      'slots': slots,
    });
    store.setList(BoxKeys.doctorDiaryDays, days);
    return null;
  }
}
