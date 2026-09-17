/// =============================================================
/// Lifex-AI — المراقبة عن بعد
/// الملف: watch_bond_ledger.dart
/// علاقة مريض ↔ مراقب على الجهاز نفسه. ليست قناة فيديو.
/// =============================================================
library lifex_ai.features.device_guardian.watch_bond_ledger;

enum WatchBondGrade {
  notices,
  followup,
  liveWatch,
  emergency,
}

class WatchBond {
  const WatchBond({
    required this.counterpartProfileId,
    required this.grade,
    required this.proposerAccepted,
    required this.counterpartAccepted,
  });

  final String counterpartProfileId;
  final WatchBondGrade grade;
  final bool proposerAccepted;
  final bool counterpartAccepted;

  bool get bothSidesAgreed => proposerAccepted && counterpartAccepted;

  bool get asksForLiveFeed =>
      grade == WatchBondGrade.liveWatch || grade == WatchBondGrade.emergency;

  String get gradeAr {
    switch (grade) {
      case WatchBondGrade.notices:
        return 'إشعارات';
      case WatchBondGrade.followup:
        return 'متابعة';
      case WatchBondGrade.liveWatch:
        return 'نية بث حي';
      case WatchBondGrade.emergency:
        return 'طوارئ عائلية';
    }
  }

  String honestyAr() {
    if (!bothSidesAgreed) {
      return 'الربط ناقص: يحتاج موافقة الطرفين الظاهرين على هذا الجهاز.';
    }
    if (asksForLiveFeed) {
      return 'النية محفوظة محلياً. البث للمراقب في بلد آخر يحتاج قناة شبكة معتمدة.';
    }
    if (grade == WatchBondGrade.followup) {
      return 'متابعة محلية بين ملفين على هذا الهاتف. ليست مراقبة سريرية.';
    }
    return 'إشعارات محلية بين الملفين. لا صورة ولا موقع يُرسلان.';
  }

  Map<String, dynamic> toMap() => {
        'targetId': counterpartProfileId,
        'grade': grade.name,
        'proposerAccepted': proposerAccepted,
        'counterpartAccepted': counterpartAccepted,
      };

  static WatchBond fromMap(Map<String, dynamic> raw) {
    return WatchBond(
      counterpartProfileId: raw['targetId']?.toString() ?? '',
      grade: _gradeFrom(raw),
      proposerAccepted: raw['proposerAccepted'] == true ||
          (raw['approved'] == true && _numericLevel(raw) <= 2),
      counterpartAccepted: raw['counterpartAccepted'] == true ||
          (raw['approved'] == true && _numericLevel(raw) <= 2),
    );
  }

  static int _numericLevel(Map<String, dynamic> raw) {
    final level = raw['level'];
    if (level is int) return level;
    return int.tryParse(level?.toString() ?? '') ?? 0;
  }

  static WatchBondGrade _gradeFrom(Map<String, dynamic> raw) {
    final named = raw['grade']?.toString();
    for (final value in WatchBondGrade.values) {
      if (value.name == named) return value;
    }
    switch (_numericLevel(raw)) {
      case 2:
        return WatchBondGrade.followup;
      case 3:
        return WatchBondGrade.liveWatch;
      case 4:
        return WatchBondGrade.emergency;
      default:
        return WatchBondGrade.notices;
    }
  }
}

class WatchBondLedger {
  WatchBondLedger(this.rows);

  final List<Map<String, dynamic>> rows;

  WatchBond? forProfile(String profileId) {
    for (final row in rows) {
      final bond = WatchBond.fromMap(row);
      if (bond.counterpartProfileId == profileId) return bond;
    }
    return null;
  }

  void put(WatchBond bond) {
    rows.removeWhere((row) => row['targetId'] == bond.counterpartProfileId);
    rows.add(bond.toMap());
  }

  /// المستوى 1 و2 يكتملان بموافقة واحدة على الجهاز. الحيّ والطوارئ يحتاجان الطرفين.
  WatchBond propose({
    required String counterpartProfileId,
    required WatchBondGrade grade,
    required bool counterpartStandingHere,
  }) {
    final needsBoth = grade == WatchBondGrade.liveWatch ||
        grade == WatchBondGrade.emergency;
    final bond = WatchBond(
      counterpartProfileId: counterpartProfileId,
      grade: grade,
      proposerAccepted: true,
      counterpartAccepted: needsBoth ? counterpartStandingHere : true,
    );
    put(bond);
    return bond;
  }
}
