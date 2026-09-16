/// =============================================================
/// Lifex-AI — صندوق المشروع
/// الملف: profile_box_store.dart
/// يخزّن سجلات الوحدات داخل الملف الصحي الحي دون خادم.
/// =============================================================
library lifex_ai.features.network_box.profile_box_store;

import '../profile/health_profile.dart';

class BoxKeys {
  BoxKeys._();

  static const aliasName = 'aliasName';
  static const lifeOriginNotes = 'lifeOriginNotes';
  static const publicIdentityMode = 'publicIdentityMode';
  static const doctors = 'doctorNetworkRecords';
  static const patients = 'patientNetworkRecords';
  static const labs = 'labRecords';
  static const radiology = 'radiologyRecords';
  static const pharmacy = 'pharmacyRecords';
  static const hospital = 'hospitalRecords';
  static const dental = 'dentalRecords';
  static const women = 'womenHealthRecords';
  static const donations = 'donationRecords';
  static const education = 'careTrainingRecords';
  static const connectedDevices = 'connectedDeviceRecords';
  static const medicalDevices = 'medicalDeviceRegistry';
  static const biometrics = 'biometricManualLogs';
  static const chronicPlans = 'chronicCarePlans';
  static const bookings = 'unifiedBookings';
  static const guardian = 'deviceGuardianState';
  static const remoteLinks = 'remoteGuardianLinks';
  static const familyMessages = 'familyMessages';
  static const pharmacyStock = 'pharmacyStock';
  static const cameraNotes = 'cameraNotes';
  static const careOrders = 'careOrders';
  static const accountEmail = 'accountEmail';
  static const accountPhone = 'accountPhone';
}

/// قراءة وكتابة قوائم الصندوق داخل [HealthProfile.questionnaireData].
class ProfileBoxStore {
  ProfileBoxStore(this.profile);

  final HealthProfile profile;

  List<Map<String, dynamic>> list(String key) {
    final raw = profile.questionnaireData[key];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  void setList(String key, List<Map<String, dynamic>> items) {
    profile.questionnaireData[key] = items;
    profile.lastUpdatedAt = DateTime.now();
  }

  Map<String, dynamic> add(String key, Map<String, dynamic> record) {
    final items = list(key);
    final stored = Map<String, dynamic>.from(record);
    stored['id'] ??= 'REC-${DateTime.now().millisecondsSinceEpoch}';
    stored['createdAt'] ??= DateTime.now().toIso8601String();
    items.add(stored);
    setList(key, items);
    return stored;
  }

  void removeAt(String key, int index) {
    final items = list(key);
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
    setList(key, items);
  }

  String? stringField(String key) {
    final value = profile.questionnaireData[key];
    return value is String ? value : null;
  }

  void setString(String key, String value) {
    profile.questionnaireData[key] = value;
    profile.lastUpdatedAt = DateTime.now();
  }

  Map<String, dynamic> map(String key) {
    final raw = profile.questionnaireData[key];
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return {};
  }

  void setMap(String key, Map<String, dynamic> value) {
    profile.questionnaireData[key] = value;
    profile.lastUpdatedAt = DateTime.now();
  }
}
