import 'package:flutter_test/flutter_test.dart';
import 'package:lifex_ai/core/permission_transparency.dart';

void main() {
  test('الإذن غير ممنوح قبل القرار الصريح', () {
    final manager = PermissionTransparencyManager.instance;
    expect(manager.isGranted(LifexSensitivePermission.camera), isFalse);
  });

  test('الموافقة الصريحة تُسجَّل ويمكن إيقافها لاحقاً', () {
    final manager = PermissionTransparencyManager.instance;
    manager.decide(
      permission: LifexSensitivePermission.microphone,
      granted: true,
    );
    expect(manager.isGranted(LifexSensitivePermission.microphone), isTrue);
    expect(
      manager.useIfGranted(LifexSensitivePermission.microphone),
      isTrue,
    );

    manager.decide(
      permission: LifexSensitivePermission.microphone,
      granted: false,
    );
    expect(manager.isGranted(LifexSensitivePermission.microphone), isFalse);
    expect(
      manager.useIfGranted(LifexSensitivePermission.microphone),
      isFalse,
    );
  });
}
