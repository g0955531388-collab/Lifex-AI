/// =============================================================
/// Lifex-AI — الرؤية
/// الملف: optical_radar_engine.dart
/// المسار: lib/features/vision/optical_radar_engine.dart
/// الوصف: رادار ضوئي بوميض الفلاش. قياس زمن الرحلة الحقيقي يحتاج
/// حسّاس ToF. هذا المحرك لا يخترع أمتاراً على هاتف عادي.
/// =============================================================
library lifex_ai.features.vision.optical_radar_engine;

import '../../core/permission_transparency.dart';

class OpticalRadarResult {
  const OpticalRadarResult({
    required this.success,
    required this.messageAr,
    this.distanceMeters,
  });

  final bool success;
  final String messageAr;
  final double? distanceMeters;
}

class OpticalRadarEngine {
  OpticalRadarEngine._internal();
  static final OpticalRadarEngine instance = OpticalRadarEngine._internal();

  OpticalRadarResult probe() {
    final permissions = PermissionTransparencyManager.instance;
    if (!permissions.isGranted(LifexSensitivePermission.camera)) {
      return const OpticalRadarResult(
        success: false,
        messageAr:
            'الرادار الضوئي يحتاج موافقة الكاميرا والفلاش من شاشة شفافية الصلاحيات أولاً.',
      );
    }
    permissions.recordOf(LifexSensitivePermission.camera)?.recordUsage();
    return const OpticalRadarResult(
      success: false,
      messageAr:
          'تقدير المسافة بوميض الفلاش (GFRS، اختراع غازي سليم بكفلاوي) '
          'يحتاج حسّاس زمن رحلة موقوتاً. فرق الإضاءة أو لوغاريتم اللمعان '
          'لا يُعلن أمتاراً على هذا الهاتف. يمكنك استخدام كشف العوائق مع العصا البيضاء.',
    );
  }
}
