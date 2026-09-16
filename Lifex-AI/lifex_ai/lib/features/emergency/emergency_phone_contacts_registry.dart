/// =============================================================
/// Lifex-AI — الطوارئ
/// الملف: emergency_phone_contacts_registry.dart
/// المسار: lib/features/emergency/emergency_phone_contacts_registry.dart
/// الوصف: قائمة أرقام الهاتف الموثوقة لكل مستخدم، والتي تصل إليها رسائل
/// الاستغاثة تلقائياً عند تفعيل حالة طوارئ. محدودة بعشرة أرقام كحد أقصى
/// لكل مستخدم بناءً على طلب صريح، وتُستخدم أيضاً للتحقق مما إذا كانت
/// مكالمة واردة أثناء وضع الطوارئ الصامت (انظر
/// silent_emergency_signal_controller.dart) صادرة من رقم موثوق أم لا.
/// =============================================================
library lifex_ai.features.emergency.emergency_phone_contacts_registry;

/// الحد الأقصى الثابت لعدد الأرقام الموثوقة — قرار منتج صريح، وليس حداً
/// تقنياً عشوائياً؛ لا يجوز رفعه من الواجهة مباشرة.
const int maxEmergencyPhoneContactsPerProfile = 10;

class EmergencyPhoneContact {
  final String phoneNumber;
  final DateTime addedAt;

  EmergencyPhoneContact({required this.phoneNumber, DateTime? addedAt})
      : addedAt = addedAt ?? DateTime.now();
}

class EmergencyContactActionResult {
  final bool success;
  final String messageAr;

  const EmergencyContactActionResult._(this.success, this.messageAr);

  factory EmergencyContactActionResult.ok(String messageAr) =>
      EmergencyContactActionResult._(true, messageAr);

  factory EmergencyContactActionResult.rejected(String messageAr) =>
      EmergencyContactActionResult._(false, messageAr);
}

/// المدير المسؤول عن أرقام الطوارئ الموثوقة لكل مستخدم.
class EmergencyPhoneContactsRegistry {
  EmergencyPhoneContactsRegistry();

  final Map<String, List<EmergencyPhoneContact>> _contactsByProfileId = {};

  List<EmergencyPhoneContact> contactsFor(String profileId) =>
      List.unmodifiable(_contactsByProfileId[profileId] ?? const []);

  EmergencyContactActionResult addContact({
    required String profileId,
    required String phoneNumber,
  }) {
    final normalized = phoneNumber.trim();
    if (normalized.isEmpty) {
      return EmergencyContactActionResult.rejected('رقم الهاتف غير صالح.');
    }

    final existing = _contactsByProfileId.putIfAbsent(profileId, () => []);

    if (existing.any((c) => c.phoneNumber == normalized)) {
      return EmergencyContactActionResult.rejected('هذا الرقم مضاف بالفعل.');
    }

    if (existing.length >= maxEmergencyPhoneContactsPerProfile) {
      return EmergencyContactActionResult.rejected(
        'وصلت للحد الأقصى ($maxEmergencyPhoneContactsPerProfile أرقام). '
        'احذف رقماً أولاً لإضافة رقم جديد.',
      );
    }

    existing.add(EmergencyPhoneContact(phoneNumber: normalized));
    return EmergencyContactActionResult.ok('تمت إضافة الرقم إلى جهات الاتصال الموثوقة للطوارئ.');
  }

  EmergencyContactActionResult removeContact({
    required String profileId,
    required String phoneNumber,
  }) {
    final existing = _contactsByProfileId[profileId];
    if (existing == null || !existing.any((c) => c.phoneNumber == phoneNumber)) {
      return EmergencyContactActionResult.rejected('هذا الرقم غير موجود أصلاً.');
    }
    existing.removeWhere((c) => c.phoneNumber == phoneNumber);
    return EmergencyContactActionResult.ok('تم حذف الرقم من جهات الاتصال الموثوقة للطوارئ.');
  }

  bool isTrustedNumber(String profileId, String phoneNumber) {
    final existing = _contactsByProfileId[profileId];
    if (existing == null) return false;
    return existing.any((c) => c.phoneNumber == phoneNumber.trim());
  }
}
