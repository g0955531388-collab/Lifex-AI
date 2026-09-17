/// =============================================================
/// Lifex-AI — الموقع
/// الملف: gps_priority_monitor.dart
/// النظام يعمل دائماً بلا GPS. إن وُجد إذن الموقع فحالته ذات أولوية.
/// لا إحداثيات مختلقة.
/// =============================================================
library lifex_ai.features.location.gps_priority_monitor;

enum GpsLane { workingWithoutFix, permissionMissing, permissionReady }

class GpsPrioritySnapshot {
  const GpsPrioritySnapshot({
    required this.lane,
    required this.priority,
    required this.messageAr,
  });

  final GpsLane lane;
  /// أعلى من معظم لافتات الشاشة الرئيسية.
  final int priority;
  final String messageAr;
}

class GpsPriorityMonitor {
  const GpsPriorityMonitor();

  static const bannerPriority = 90;

  GpsPrioritySnapshot fromPermission({required bool granted}) {
    if (granted) {
      return const GpsPrioritySnapshot(
        lane: GpsLane.permissionReady,
        priority: bannerPriority,
        messageAr:
            'حالة GPS أولوية عالية: الإذن موجود. لا نقطة على الخريطة حتى تُقرأ إحداثيات صادقة من الجهاز.',
      );
    }
    return const GpsPrioritySnapshot(
      lane: GpsLane.permissionMissing,
      priority: bannerPriority,
      messageAr:
          'النظام يعمل الآن بلا GPS. حالته تبقى أولوية: اطلب الإذن عند الدم أو الطوارئ فقط.',
    );
  }
}
