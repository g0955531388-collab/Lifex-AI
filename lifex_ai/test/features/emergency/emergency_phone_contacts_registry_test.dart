// اختبارات: emergency_phone_contacts_registry.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:lifex_ai/features/emergency/emergency_phone_contacts_registry.dart';

void main() {
  test('لا يمكن إضافة أكثر من عشرة أرقام لنفس المستخدم', () {
    final registry = EmergencyPhoneContactsRegistry();
    for (var i = 0; i < maxEmergencyPhoneContactsPerProfile; i++) {
      final result =
          registry.addContact(profileId: 'p1', phoneNumber: '+96395500000$i');
      expect(result.success, isTrue);
    }

    final overflowResult =
        registry.addContact(profileId: 'p1', phoneNumber: '+963955000099');
    expect(overflowResult.success, isFalse);
    expect(registry.contactsFor('p1'), hasLength(maxEmergencyPhoneContactsPerProfile));
  });

  test('لا يمكن إضافة نفس الرقم مرتين', () {
    final registry = EmergencyPhoneContactsRegistry();
    registry.addContact(profileId: 'p1', phoneNumber: '+963900000000');
    final result =
        registry.addContact(profileId: 'p1', phoneNumber: '+963900000000');

    expect(result.success, isFalse);
    expect(registry.contactsFor('p1'), hasLength(1));
  });

  test('حذف رقم يعيد فتح مكان جديد', () {
    final registry = EmergencyPhoneContactsRegistry();
    registry.addContact(profileId: 'p1', phoneNumber: '+963900000000');
    final removeResult =
        registry.removeContact(profileId: 'p1', phoneNumber: '+963900000000');

    expect(removeResult.success, isTrue);
    expect(registry.contactsFor('p1'), isEmpty);
  });

  test('isTrustedNumber يتحقق فقط من أرقام هذا المستخدم تحديداً', () {
    final registry = EmergencyPhoneContactsRegistry();
    registry.addContact(profileId: 'p1', phoneNumber: '+963900000000');

    expect(registry.isTrustedNumber('p1', '+963900000000'), isTrue);
    expect(registry.isTrustedNumber('p2', '+963900000000'), isFalse);
  });
}
