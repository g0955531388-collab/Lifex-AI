/// =============================================================
/// Lifex-AI — عدسة الشرائح المتراكبة
/// الملف: layered_slice_fusion.dart
/// زوج شرائح + محاولة دمج. بلا صورة ثلاثية مختلقة قبل محرك الاختراع.
/// =============================================================
library lifex_ai.features.vision.layered_slice_fusion;

enum SliceCaptureMode { concurrent, sequential, singleLens }

class LayeredSlicePair {
  const LayeredSlicePair({
    required this.lowerPath,
    required this.overlayPath,
    required this.zoomUsed,
    required this.mode,
  });

  final String lowerPath;
  final String overlayPath;
  final double zoomUsed;
  final SliceCaptureMode mode;

  bool get hasTwoSlices =>
      lowerPath.isNotEmpty && overlayPath.isNotEmpty && lowerPath != overlayPath;
}

class LayeredSliceFusionResult {
  const LayeredSliceFusionResult({
    required this.fused,
    required this.messageAr,
    this.fusedPath,
  });

  final bool fused;
  final String messageAr;
  final String? fusedPath;
}

typedef LayeredFusionEngine = Future<String?> Function(LayeredSlicePair pair);

class LayeredSliceFusion {
  const LayeredSliceFusion({this.engine});

  final LayeredFusionEngine? engine;

  Future<LayeredSliceFusionResult> merge(LayeredSlicePair pair) async {
    if (!pair.hasTwoSlices) {
      return const LayeredSliceFusionResult(
        fused: false,
        messageAr:
            'لا شريحتان بعد. الاختراع يحتاج إطاراً سفلياً وإطاراً فوقه من عدسة ثانية.',
      );
    }
    if (pair.mode == SliceCaptureMode.singleLens) {
      return LayeredSliceFusionResult(
        fused: false,
        messageAr:
            'عدسة خلفية واحدة فقط على هذا الجهاز. حُفظت لقطة مكبّرة للجلد. '
            'الدمج الثلاثي ينتظر عدسة ثانية. التكبير ${pair.zoomUsed.toStringAsFixed(1)}×.',
      );
    }
    final bound = engine;
    if (bound == null) {
      final timing = pair.mode == SliceCaptureMode.concurrent
          ? 'التُقطت الشريحتان معاً قدر ما سمح العتاد.'
          : 'التُقطت الشريحتان بالتتابع لأن التزامن رفضه النظام.';
      return LayeredSliceFusionResult(
        fused: false,
        messageAr:
            '$timing الشريحتان محفوظتان محلياً. محرك دمج الاختراع غير مربوط هنا، '
            'فلن أركّب صورة ثلاثية وهمية. أرسل ملف الويبو أو خوارزمية الدمج لربطها.',
      );
    }
    final path = await bound(pair);
    if (path == null || path.isEmpty) {
      return const LayeredSliceFusionResult(
        fused: false,
        messageAr: 'رفض محرك الدمج الإخراج. الشريحتان باقيتان بلا تركيب مختلق.',
      );
    }
    return LayeredSliceFusionResult(
      fused: true,
      fusedPath: path,
      messageAr: 'أُنتج مسار الدمج من المحرك المعتمد. ليس تشخيصاً جلدياً.',
    );
  }
}
