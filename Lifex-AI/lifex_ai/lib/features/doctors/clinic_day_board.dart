/// =============================================================
/// Lifex-AI — يوميات الطبيب
/// الملف: clinic_day_board.dart
/// شارات وإحصاء وموافقة صيدلية محلية. بلا حجوزات مختلقة.
/// =============================================================
library lifex_ai.features.doctors.clinic_day_board;

class ClinicSlotMark {
  const ClinicSlotMark({
    required this.booked,
    required this.specialNeeds,
  });

  final bool booked;
  final bool specialNeeds;

  String badgeAr() {
    if (specialNeeds) return 'حالة خاصة';
    if (booked) return 'محجوز';
    return 'متاح';
  }

  String spokenAr({required String time, required String alias}) {
    final who = booked
        ? (alias.trim().isEmpty ? 'محجوز بلا اسم' : alias.trim())
        : 'حصة فارغة';
    return 'الساعة $time. ${badgeAr()}. $who.';
  }
}

class ClinicDayStats {
  const ClinicDayStats({
    required this.total,
    required this.booked,
    required this.special,
  });

  final int total;
  final int booked;
  final int special;

  int get free => total - booked;

  factory ClinicDayStats.fromSlots(List<Map<String, dynamic>> slots) {
    var booked = 0;
    var special = 0;
    for (final slot in slots) {
      if (slot['booked'] == true) booked++;
      if (slot['specialNeeds'] == true) special++;
    }
    return ClinicDayStats(
      total: slots.length,
      booked: booked,
      special: special,
    );
  }

  String spokenAr() =>
      'حصص $total. محجوز $booked. متاح $free. حالات خاصة $special.';
}

class PharmacyReviewGate {
  const PharmacyReviewGate({
    required this.enabled,
    required this.namedPharmaciesAr,
  });

  final bool enabled;
  final String namedPharmaciesAr;

  String spokenAr() {
    if (!enabled) {
      return 'لا موافقة لمراجعة الصيدلية على هذا اليوم.';
    }
    final names = namedPharmaciesAr.trim();
    if (names.isEmpty) {
      return 'موافقة محلية عامة لمراجعة صيدلي لاحقاً. ليست شبكة حية.';
    }
    return 'موافقة محلية مقيّدة بأسماء تكتبها أنت: $names. ليست شبكة صيدليات.';
  }
}

class ClinicEmptyBoard {
  const ClinicEmptyBoard();

  /// التوليد يملأ أوقاتاً فقط. أي مريض يجب أن يُحجز يدوياً.
  Map<String, dynamic> emptySlot({
    required int index,
    required String time,
  }) =>
      {
        'index': index,
        'time': time,
        'booked': false,
        'specialNeeds': false,
        'alias': '',
        'linkedProfileId': '',
        'doctorNote': '',
        'examNote': '',
      };
}
