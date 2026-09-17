/// =============================================================
/// Lifex-AI — عدسة الشرائح المتراكبة
/// الملف: optical_zoom_policy.dart
/// التكبير حتى حد العتاد. بلا أرقام مكبّرة مختلقة.
/// =============================================================
library lifex_ai.features.vision.optical_zoom_policy;

class OpticalZoomPolicy {
  const OpticalZoomPolicy();

  double clampToHardware({
    required double requested,
    required double minZoom,
    required double maxZoom,
  }) {
    if (maxZoom < minZoom) return minZoom;
    if (requested < minZoom) return minZoom;
    if (requested > maxZoom) return maxZoom;
    return requested;
  }

  bool isNearHardwareLimit(double zoom, double maxZoom) {
    if (maxZoom <= 1) return false;
    return zoom >= maxZoom * 0.85;
  }

  String honestyAr({
    required double zoom,
    required double maxZoom,
    required bool hardwareRead,
  }) {
    if (!hardwareRead) {
      return 'لم تُقرأ حدود التكبير من العدسة بعد.';
    }
    if (isNearHardwareLimit(zoom, maxZoom)) {
      return 'التكبير عند سقف هذه العدسة (${zoom.toStringAsFixed(1)}× من أصل ${maxZoom.toStringAsFixed(1)}×). '
          'ما فوق ذلك قصّ رقمي وليس اختراع الشرائح.';
    }
    return 'التكبير الحالي ${zoom.toStringAsFixed(1)}×. السقف الحقيقي ${maxZoom.toStringAsFixed(1)}×.';
  }
}
