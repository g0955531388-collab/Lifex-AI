// اختبارات: silent_emergency_signal_controller.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:lifex_ai/features/accessibility/multi_sensory_alert_manager.dart';
import 'package:lifex_ai/features/emergency/emergency_phone_contacts_registry.dart';
import 'package:lifex_ai/features/emergency/silent_emergency_signal_controller.dart';

class _FakeVibrationExecutor implements VibrationExecutor {
  int callCount = 0;

  @override
  Future<void> vibrate({required List<int> patternMs}) async {
    callCount++;
  }
}

class _FakeVisualFlashExecutor implements VisualFlashExecutor {
  int screenFlashCount = 0;
  int cameraFlashCount = 0;

  @override
  Future<void> flashScreen({required int repeatCount}) async {
    screenFlashCount++;
  }

  @override
  Future<void> flashCameraLight({required int repeatCount}) async {
    cameraFlashCount++;
  }
}

void main() {
  late _FakeVibrationExecutor vibration;
  late _FakeVisualFlashExecutor flash;
  late MultiSensoryAlertManager multiSensory;
  late EmergencyPhoneContactsRegistry contactsRegistry;

  setUp(() {
    vibration = _FakeVibrationExecutor();
    flash = _FakeVisualFlashExecutor();
    multiSensory = MultiSensoryAlertManager(
      vibrationExecutor: vibration,
      visualFlashExecutor: flash,
    );
    contactsRegistry = EmergencyPhoneContactsRegistry();
  });

  test('الوضع الصامت مفعَّل: ضوء فقط، بلا صوت ولا اهتزاز', () async {
    final controller = SilentEmergencySignalController(
      multiSensoryAlertManager: multiSensory,
      emergencyContactsRegistry: contactsRegistry,
      isSilentModeEnabledSystemWide: () => true,
    );

    await controller.signalEmergency(
      profileId: 'p1',
      severity: AlertSeverityForSenses.critical,
    );

    expect(vibration.callCount, 0);
    expect(flash.screenFlashCount, 0);
    expect(flash.cameraFlashCount, 1);
  });

  test('الوضع الصامت غير مفعَّل: السلوك الطبيعي الكامل (صوت واهتزاز وومضة)', () async {
    final controller = SilentEmergencySignalController(
      multiSensoryAlertManager: multiSensory,
      emergencyContactsRegistry: contactsRegistry,
      isSilentModeEnabledSystemWide: () => false,
    );

    await controller.signalEmergency(
      profileId: 'p1',
      severity: AlertSeverityForSenses.critical,
    );

    expect(vibration.callCount, 1);
    expect(flash.screenFlashCount, 1);
  });

  test('مكالمة واردة من رقم موثوق تُلغي الوضع الصامت لهذا المستخدم فقط', () async {
    contactsRegistry.addContact(profileId: 'p1', phoneNumber: '+963900000000');

    final controller = SilentEmergencySignalController(
      multiSensoryAlertManager: multiSensory,
      emergencyContactsRegistry: contactsRegistry,
      isSilentModeEnabledSystemWide: () => true,
    );

    controller.notifyIncomingCall(
      profileId: 'p1',
      callerPhoneNumber: '+963900000000',
    );

    await controller.signalEmergency(
      profileId: 'p1',
      severity: AlertSeverityForSenses.critical,
    );

    // عاد للسلوك الطبيعي بعد الاتصال الموثوق
    expect(vibration.callCount, 1);

    await controller.signalEmergency(
      profileId: 'p2', // مستخدم آخر لم يتصل به أحد
      severity: AlertSeverityForSenses.critical,
    );
    // لا يزال صامتاً لمستخدم مختلف — لم يُلغَ الوضع الصامت عالمياً
    expect(flash.cameraFlashCount, 1);
  });

  test('مكالمة من رقم غير موثوق لا تُلغي الوضع الصامت', () async {
    contactsRegistry.addContact(profileId: 'p1', phoneNumber: '+963900000000');

    final controller = SilentEmergencySignalController(
      multiSensoryAlertManager: multiSensory,
      emergencyContactsRegistry: contactsRegistry,
      isSilentModeEnabledSystemWide: () => true,
    );

    controller.notifyIncomingCall(
      profileId: 'p1',
      callerPhoneNumber: '+900000000000', // رقم غير مسجَّل كموثوق
    );

    await controller.signalEmergency(
      profileId: 'p1',
      severity: AlertSeverityForSenses.critical,
    );

    expect(vibration.callCount, 0);
    expect(flash.cameraFlashCount, 1);
  });
}
