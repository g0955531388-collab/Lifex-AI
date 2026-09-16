/// =============================================================
/// Lifex-AI — النواة
/// الملف: trial_manager.dart
/// تجربة محلية ثم طوارئ ودم ومحفظة، مع إعفاء الهمم والمزمنين.
/// =============================================================
library lifex_ai.core.trial_manager;

import 'package:shared_preferences/shared_preferences.dart';

import 'app_constants.dart';

enum TrialPhase { full, expired }

class TrialManager {
  TrialManager(this._prefs);

  final SharedPreferences _prefs;
  static const _keyInstalledAt = 'lifex_installed_at';

  DateTime get installedAt {
    final raw = _prefs.getString(_keyInstalledAt);
    if (raw == null) {
      final now = DateTime.now().toIso8601String();
      _prefs.setString(_keyInstalledAt, now);
      return DateTime.now();
    }
    return DateTime.tryParse(raw) ?? DateTime.now();
  }

  int get daysSinceInstall => DateTime.now().difference(installedAt).inDays;

  TrialPhase get phase => daysSinceInstall < AppConstants.trialPeriodDays
      ? TrialPhase.full
      : TrialPhase.expired;

  bool get emergencyAndBloodOnly => phase == TrialPhase.expired;
}

class SessionAccessPolicy {
  const SessionAccessPolicy();

  static const alwaysOpen = {
    'emergency',
    'blood',
    'wallet',
    'settings',
  };

  bool canOpenUnit(
    String unitId, {
    required bool expired,
    required bool feeExempt,
  }) {
    if (!expired || feeExempt) return true;
    return alwaysOpen.contains(unitId);
  }
}
