/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: layered_lens_studio_screen.dart
/// استوديو الشرائح: تكبير جلدي وعدستان إن سمح الجهاز. بلا تشخيص.
/// =============================================================
library lifex_ai.screens.layered_lens_studio_screen;

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../core/license_manager.dart';
import '../core/permission_transparency.dart';
import '../features/network_box/profile_box_store.dart';
import '../features/profile/active_profile_controller.dart';
import '../features/vision/camera_rig_policy.dart';
import '../features/vision/layered_lens_invention.dart';
import '../features/vision/layered_slice_fusion.dart';
import '../features/vision/optical_zoom_policy.dart';
import '../features/voice/voice_engine.dart';
import '../widgets/honesty_banner.dart';

class LayeredLensStudioScreen extends StatefulWidget {
  const LayeredLensStudioScreen({super.key});

  @override
  State<LayeredLensStudioScreen> createState() =>
      _LayeredLensStudioScreenState();
}

class _LayeredLensStudioScreenState extends State<LayeredLensStudioScreen> {
  static const _invention = LayeredLensInvention();
  static const _zoomPolicy = OpticalZoomPolicy();
  static const _fusion = LayeredSliceFusion();
  static const _rig = CameraRigPolicy();

  CameraController? _lower;
  CameraController? _overlay;
  List<CameraDescription> _rear = const [];
  SliceCaptureMode _mode = SliceCaptureMode.singleLens;
  final _board = StudioSliceBoard();
  double _minZoom = 1;
  double _maxZoom = 1;
  double _zoom = 1;
  double _minExposure = 0;
  double _maxExposure = 0;
  double _flashPercent = 0;
  double _exposureSeconds = 0;
  double _shutterUnit = 0.5;
  double _brightness = 1;
  double _contrast = 1;
  int _timerSeconds = 0;
  bool _torchAvailable = false;
  bool _exposureAvailable = false;
  bool _busy = false;
  bool _voiceOn = true;
  bool _printStamp = true;
  bool _pinned = false;
  bool _showMaster = true;
  double _master = 50;
  double _overlayAlpha = 0.45;
  StudioMasterTarget _masterTarget = StudioMasterTarget.zoom;
  Timer? _hideMaster;
  Offset? _cropStart;
  Offset? _cropEnd;
  String _status = 'هذه الشاشة لتوثيق الجلد بتكبير حقيقي وشريحتين إن وُجدتا.';
  String? _lowerPath;
  String? _overlayPath;

  @override
  void dispose() {
    _hideMaster?.cancel();
    unawaited(_lower?.dispose());
    unawaited(_overlay?.dispose());
    super.dispose();
  }

  void _announce(String line) {
    if (!_voiceOn) return;
    unawaited(VoiceEngine.instance.speak(line));
  }

  void _bumpMaster() {
    _hideMaster?.cancel();
    setState(() => _showMaster = true);
    if (_pinned) return;
    _hideMaster = Timer(const Duration(seconds: 6), () {
      if (!mounted || _pinned) return;
      setState(() => _showMaster = false);
    });
  }

  void _arm(StudioMasterTarget target) {
    _masterTarget = target;
    _bumpMaster();
  }

  void _onMaster(double value) {
    final mapped = _rig.mapMaster(
      target: _masterTarget,
      master: value,
      minZoom: _minZoom,
      maxZoom: _maxZoom,
    );
    setState(() => _master = value);
    switch (_masterTarget) {
      case StudioMasterTarget.zoom:
        unawaited(_applyZoom(mapped));
        break;
      case StudioMasterTarget.flash:
        setState(() => _flashPercent = mapped);
        break;
      case StudioMasterTarget.exposure:
        setState(() => _exposureSeconds = mapped);
        break;
      case StudioMasterTarget.shutter:
        setState(() => _shutterUnit = mapped);
        break;
      case StudioMasterTarget.brightness:
        setState(() => _brightness = mapped);
        break;
      case StudioMasterTarget.contrast:
        setState(() => _contrast = mapped);
        break;
      case StudioMasterTarget.timer:
        setState(() => _timerSeconds = mapped.round());
        break;
    }
    _bumpMaster();
  }

  void _commitCrop(Size size) {
    final start = _cropStart;
    final end = _cropEnd;
    if (start == null || end == null || size.width <= 0 || size.height <= 0) {
      return;
    }
    final note = _board.addCrop(
      left: start.dx / size.width,
      top: start.dy / size.height,
      width: (end.dx - start.dx) / size.width,
      height: (end.dy - start.dy) / size.height,
      path: _lowerPath,
    );
    setState(() {
      _cropStart = null;
      _cropEnd = null;
      _status = note == null
          ? 'المنطقة أصغر من أن تُحفظ كشريحة.'
          : 'أُضيفت ${note.titleAr}. القصّ من اللقطة المحفوظة، لا من قماش 5000.';
    });
    _announce(_status);
  }

  Future<void> _openLenses() async {
    final agreed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(LayeredLensInvention.titleAr),
        content: Text(
          '${_invention.methodAr()}\n\n${_invention.medicalLimitAr()}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('رفض'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('أوافق على التصوير الظاهر'),
          ),
        ],
      ),
    );
    if (agreed != true || !mounted) return;
    PermissionTransparencyManager.instance.decide(
      permission: LifexSensitivePermission.camera,
      granted: true,
    );
    final granted = await Permission.camera.request();
    if (!granted.isGranted || !mounted) {
      setState(() => _status = 'بدون إذن الكاميرا لا تُفتح العدسات.');
      return;
    }
    try {
      final found = await availableCameras();
      _rear = found
          .where((item) => item.lensDirection == CameraLensDirection.back)
          .toList();
      if (_rear.isEmpty) {
        setState(() => _status = 'لا عدسة خلفية ظاهرة على هذا الجهاز.');
        return;
      }
      final first = CameraController(
        _rear.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await first.initialize();
      final firstMin = await first.getMinZoomLevel();
      final firstMax = await first.getMaxZoomLevel();
      final firstZoom = _zoomPolicy.clampToHardware(
        requested: firstMax,
        minZoom: firstMin,
        maxZoom: firstMax,
      );
      await first.setZoomLevel(firstZoom);
      var minExposure = 0.0;
      var maxExposure = 0.0;
      var exposureAvailable = false;
      var torchAvailable = false;
      try {
        minExposure = await first.getMinExposureOffset();
        maxExposure = await first.getMaxExposureOffset();
        exposureAvailable = maxExposure > minExposure;
      } catch (_) {}
      try {
        await first.setFlashMode(FlashMode.off);
        torchAvailable = true;
      } catch (_) {
        torchAvailable = false;
      }
      CameraController? second;
      var mode = SliceCaptureMode.singleLens;
      if (_rear.length >= 2) {
        try {
          second = CameraController(
            _rear[1],
            ResolutionPreset.high,
            enableAudio: false,
          );
          await second.initialize();
          final secondMax = await second.getMaxZoomLevel();
          final secondMin = await second.getMinZoomLevel();
          await second.setZoomLevel(
            _zoomPolicy.clampToHardware(
              requested: secondMax,
              minZoom: secondMin,
              maxZoom: secondMax,
            ),
          );
          mode = SliceCaptureMode.concurrent;
        } catch (_) {
          await second?.dispose();
          second = null;
          mode = SliceCaptureMode.sequential;
        }
      }
      if (!mounted) {
        await first.dispose();
        await second?.dispose();
        return;
      }
      setState(() {
        _lower = first;
        _overlay = second;
        _mode = mode;
        _minZoom = firstMin;
        _maxZoom = firstMax;
        _zoom = firstZoom;
        _minExposure = minExposure;
        _maxExposure = maxExposure;
        _exposureAvailable = exposureAvailable;
        _torchAvailable = torchAvailable;
        _status = _modeLine();
      });
      _announce(_modeLine());
    } catch (error) {
      setState(() => _status = 'تعذّر فتح العدسات: $error');
    }
  }

  String _modeLine() {
    switch (_mode) {
      case SliceCaptureMode.concurrent:
        return 'عدستان خلفيتان مفتوحتان معاً. ${_zoomPolicy.honestyAr(zoom: _zoom, maxZoom: _maxZoom, hardwareRead: true)}';
      case SliceCaptureMode.sequential:
        return 'وُجدت عدسة ثانية لكن التزامن رُفض. سألتقط الشريحتين بالتتابع. ${_zoomPolicy.honestyAr(zoom: _zoom, maxZoom: _maxZoom, hardwareRead: true)}';
      case SliceCaptureMode.singleLens:
        return 'عدسة خلفية واحدة. التكبير الجلدي يعمل. الدمج الثلاثي ينتظر عدسة ثانية.';
    }
  }

  Future<void> _applyZoom(double value) async {
    final clamped = _zoomPolicy.clampToHardware(
      requested: value,
      minZoom: _minZoom,
      maxZoom: _maxZoom,
    );
    try {
      await _lower?.setZoomLevel(clamped);
      await _overlay?.setZoomLevel(clamped);
    } catch (_) {}
    setState(() {
      _zoom = clamped;
      _status = _modeLine();
    });
  }

  CameraRigApply _planned() {
    return _rig.plan(
      advertisedZoom: _zoom,
      advertisedExposureSeconds: _exposureSeconds,
      advertisedShutter: _shutterUnit,
      advertisedFlashPercent: _flashPercent,
      advertisedBrightness: _brightness,
      advertisedContrast: _contrast,
      minZoom: _minZoom,
      maxZoom: _maxZoom,
      minExposureOffset: _minExposure,
      maxExposureOffset: _maxExposure,
      torchAvailable: _torchAvailable,
      exposureAvailable: _exposureAvailable,
    );
  }

  Future<void> _applyRig() async {
    final lower = _lower;
    if (lower == null || !lower.value.isInitialized) {
      const line =
          'افتح العدسات أولاً. الشرائط وحدها لا تُطبَّق على كاميرا وهمية.';
      setState(() => _status = line);
      _announce(line);
      return;
    }
    final planned = _planned();
    try {
      await lower.setZoomLevel(planned.zoom);
      await _overlay?.setZoomLevel(planned.zoom);
      if (_torchAvailable) {
        await lower.setFlashMode(
          planned.torchOn ? FlashMode.torch : FlashMode.off,
        );
      }
      if (_exposureAvailable) {
        await lower.setExposureOffset(planned.exposureOffset);
      }
    } catch (error) {
      final line = 'رفض العتاد جزءاً من الضبط: $error';
      setState(() => _status = line);
      _announce(line);
      return;
    }
    setState(() {
      _zoom = planned.zoom;
      _status = planned.messageAr;
    });
    _announce(planned.messageAr);
  }

  Future<void> _importFromStudio() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null || !mounted) return;
    _board.addGallery(file.path);
    final controller = context.read<ActiveProfileController>();
    final profile = controller.activeProfile;
    if (profile != null) {
      ProfileBoxStore(profile).add(BoxKeys.layeredSlices, {
        'title': 'من الاستديو',
        'detail': _printStamp
            ? LicenseManager.instance.appendAr(
                'خلفية من المعرض. بلا قماش 5000×5000 مختلق. ${_rig.stampMarkAr()}',
              )
            : 'خلفية من المعرض. بلا قماش 5000×5000 مختلق.',
        'path': file.path,
        'origin': 'gallery',
      });
      controller.saveActiveProfileChanges();
    }
    setState(
      () => _status =
          'حُملت صورة الاستديو كشريحة محلية. الحجم حجم الملف، ليس 5000×5000.',
    );
    _announce(_status);
  }

  Future<void> _capturePair() async {
    if (_busy) return;
    final lower = _lower;
    if (lower == null || !lower.value.isInitialized) {
      setState(() => _status = 'افتح العدسات أولاً.');
      return;
    }
    setState(() => _busy = true);
    try {
      await _applyRig();
      final wait = _rig.clampTimerSeconds(_timerSeconds);
      if (wait > 0) {
        setState(() => _status = 'مؤقت $wait ثانية...');
        await Future<void>.delayed(Duration(seconds: wait));
        if (!mounted) return;
      }
      await lower.setZoomLevel(_zoom);
      final firstShot = await lower.takePicture();
      var overlayPath = '';
      var mode = _mode;
      if (_overlay != null && _overlay!.value.isInitialized) {
        await _overlay!.setZoomLevel(_zoom);
        final secondShot = await _overlay!.takePicture();
        overlayPath = secondShot.path;
        mode = SliceCaptureMode.concurrent;
      } else if (_rear.length >= 2) {
        final swapped = CameraController(
          _rear[1],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await swapped.initialize();
        await swapped.setZoomLevel(_zoom);
        final secondShot = await swapped.takePicture();
        overlayPath = secondShot.path;
        await swapped.dispose();
        mode = SliceCaptureMode.sequential;
      }
      final pair = LayeredSlicePair(
        lowerPath: firstShot.path,
        overlayPath: overlayPath,
        zoomUsed: _zoom,
        mode: overlayPath.isEmpty ? SliceCaptureMode.singleLens : mode,
      );
      final fused = await _fusion.merge(pair);
      if (!mounted) return;
      final controller = context.read<ActiveProfileController>();
      final profile = controller.activeProfile;
      if (profile != null) {
        ProfileBoxStore(profile).add(BoxKeys.layeredSlices, {
          'title': 'شريحة جلد ×${_zoom.toStringAsFixed(1)}',
          'detail': _printStamp
              ? LicenseManager.instance.appendAr(
                  '${fused.messageAr} ${_rig.stampMarkAr()}',
                )
              : fused.messageAr,
          'path': firstShot.path,
          'overlayPath': overlayPath,
          'zoom': _zoom,
          'mode': pair.mode.name,
          'fused': fused.fused,
        });
        controller.saveActiveProfileChanges();
      }
      _board.addCamera(path: firstShot.path, zoom: _zoom);
      if (overlayPath.isNotEmpty) {
        _board.addCamera(path: overlayPath, zoom: _zoom);
      }
      setState(() {
        _lowerPath = firstShot.path;
        _overlayPath = overlayPath.isEmpty ? null : overlayPath;
        _status = fused.messageAr;
      });
      _announce(fused.messageAr);
    } catch (error) {
      setState(() => _status = 'تعذّر التقاط الشرائح: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String get _masterLabel {
    switch (_masterTarget) {
      case StudioMasterTarget.zoom:
        return 'الزوم';
      case StudioMasterTarget.flash:
        return 'الفلاش';
      case StudioMasterTarget.exposure:
        return 'التعريض';
      case StudioMasterTarget.shutter:
        return 'الغالق';
      case StudioMasterTarget.brightness:
        return 'السطوع';
      case StudioMasterTarget.contrast:
        return 'التباين';
      case StudioMasterTarget.timer:
        return 'المؤقت';
    }
  }

  Widget _cornerShutter() {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _busy || _lower == null ? null : () => unawaited(_capturePair()),
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(Icons.camera, color: Colors.white),
        ),
      ),
    );
  }

  Widget _cropStill() {
    final path = _lowerPath;
    if (path == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('اسحب على اللقطة لإضافة شريحة قصّ'),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onPanStart: (details) => setState(() {
                  _cropStart = details.localPosition;
                  _cropEnd = details.localPosition;
                }),
                onPanUpdate: (details) =>
                    setState(() => _cropEnd = details.localPosition),
                onPanEnd: (_) => _commitCrop(constraints.biggest),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(path), fit: BoxFit.contain),
                    if (_cropStart != null && _cropEnd != null)
                      Positioned.fromRect(
                        rect: Rect.fromPoints(_cropStart!, _cropEnd!),
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.tertiary,
                                width: 2,
                              ),
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiary
                                  .withOpacity(0.18),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final lower = _lower;
    return Scaffold(
      appBar: AppBar(title: const Text(LayeredLensInvention.titleAr)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          HonestyBanner(messageAr: _invention.inventorLineAr()),
          const SizedBox(height: 8),
          HonestyBanner(messageAr: _invention.wipoLineAr()),
          const SizedBox(height: 8),
          HonestyBanner(messageAr: _invention.medicalLimitAr()),
          const SizedBox(height: 8),
          HonestyBanner(messageAr: _rig.refuseCssZoomAr(_maxZoom)),
          const SizedBox(height: 8),
          HonestyBanner(messageAr: _rig.exportHonestyAr()),
          const SizedBox(height: 8),
          HonestyBanner(messageAr: _rig.overlayAlphaHonestyAr()),
          const SizedBox(height: 16),
          if (_showMaster)
            Row(
              children: [
                Text('المفتاح العام ($_masterLabel)'),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 100,
                    value: _master,
                    onChanged: _busy ? null : _onMaster,
                  ),
                ),
                IconButton(
                  tooltip: _pinned ? 'مثبّت' : 'تثبيت',
                  onPressed: () {
                    setState(() => _pinned = !_pinned);
                    _bumpMaster();
                  },
                  icon: Icon(
                    _pinned ? Icons.push_pin : Icons.push_pin_outlined,
                  ),
                ),
              ],
            ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('النطق العربي'),
            value: _voiceOn,
            onChanged: (value) => setState(() => _voiceOn = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('طباعة ${_rig.stampMarkAr()}'),
            value: _printStamp,
            onChanged: (value) => setState(() => _printStamp = value),
          ),
          if (lower != null && lower.value.isInitialized)
            AspectRatio(
              aspectRatio: lower.value.aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColorFiltered(
                    colorFilter: ColorFilter.matrix(
                      _rig.previewColorMatrix(
                        brightness: _brightness,
                        contrast: _contrast,
                      ),
                    ),
                    child: CameraPreview(lower),
                  ),
                  if (_overlay != null && _overlay!.value.isInitialized)
                    Opacity(
                      opacity: _overlayAlpha.clamp(0.0, 1.0),
                      child: CameraPreview(_overlay!),
                    ),
                  Positioned(top: 8, left: 8, child: _cornerShutter()),
                  Positioned(bottom: 8, right: 8, child: _cornerShutter()),
                ],
              ),
            )
          else
            Container(
              height: 180,
              alignment: Alignment.center,
              color: Colors.black12,
              child: const Text('العدسة مغلقة حتى الموافقة'),
            ),
          const SizedBox(height: 12),
          Text(
            'شفافية الشريحة العليا ${(_overlayAlpha * 100).round()}٪',
          ),
          Slider(
            min: 0,
            max: 1,
            value: _overlayAlpha,
            onChanged: _busy
                ? null
                : (value) => setState(() => _overlayAlpha = value),
          ),
          Text('تكبير الجلد ${_zoom.toStringAsFixed(1)}×'),
          Slider(
            min: _minZoom,
            max: _maxZoom <= _minZoom ? _minZoom + 0.01 : _maxZoom,
            value: _zoom.clamp(
              _minZoom,
              _maxZoom <= _minZoom ? _minZoom : _maxZoom,
            ),
            onChangeStart: (_) => _arm(StudioMasterTarget.zoom),
            onChanged: _busy || lower == null
                ? null
                : (value) => unawaited(_applyZoom(value)),
          ),
          Text('ضوء الفلاش ${_flashPercent.round()}٪ — تشغيل أو إيقاف، ليست تياراً'),
          Slider(
            min: 0,
            max: 100,
            value: _flashPercent,
            onChangeStart: (_) => _arm(StudioMasterTarget.flash),
            onChanged: _busy
                ? null
                : (value) => setState(() => _flashPercent = value),
          ),
          Text(
            'شريط التعريض ${_exposureSeconds.toStringAsFixed(1)} — ليس ${AdvertisedCameraSliders.exposureSecondsMax.round()} ثانية',
          ),
          Slider(
            min: 0,
            max: AdvertisedCameraSliders.exposureSecondsMax,
            value: _exposureSeconds,
            onChangeStart: (_) => _arm(StudioMasterTarget.exposure),
            onChanged: _busy
                ? null
                : (value) => setState(() => _exposureSeconds = value),
          ),
          Text('شريط الغالق ${_shutterUnit.toStringAsFixed(2)} — نفس إزاحة العتاد'),
          Slider(
            min: 0,
            max: 1,
            value: _shutterUnit,
            onChangeStart: (_) => _arm(StudioMasterTarget.shutter),
            onChanged: _busy
                ? null
                : (value) => setState(() => _shutterUnit = value),
          ),
          Text('سطوع المعاينة ${_brightness.toStringAsFixed(2)} — ليس الحسّاس'),
          Slider(
            min: 0,
            max: AdvertisedCameraSliders.previewFactorMax,
            value: _brightness,
            onChangeStart: (_) => _arm(StudioMasterTarget.brightness),
            onChanged: _busy
                ? null
                : (value) => setState(() => _brightness = value),
          ),
          Text('تباين المعاينة ${_contrast.toStringAsFixed(2)} — ليس الحسّاس'),
          Slider(
            min: 0,
            max: AdvertisedCameraSliders.previewFactorMax,
            value: _contrast,
            onChangeStart: (_) => _arm(StudioMasterTarget.contrast),
            onChanged: _busy
                ? null
                : (value) => setState(() => _contrast = value),
          ),
          Text('مؤقت الالتقاط $_timerSeconds ث'),
          Slider(
            min: 0,
            max: AdvertisedCameraSliders.timerSecondsMax.toDouble(),
            divisions: AdvertisedCameraSliders.timerSecondsMax,
            value: _timerSeconds.toDouble(),
            onChangeStart: (_) => _arm(StudioMasterTarget.timer),
            onChanged: _busy
                ? null
                : (value) => setState(() => _timerSeconds = value.round()),
          ),
          FilledButton.icon(
            onPressed: _busy ? null : () => unawaited(_applyRig()),
            icon: const Icon(Icons.tune),
            label: const Text('تطبيق الضبط على العدسة'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy ? null : () => unawaited(_importFromStudio()),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('فتح من الاستديو'),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: lower == null ? _openLenses : null,
            icon: const Icon(Icons.cameraswitch_outlined),
            label: const Text('فتح العدسات الخلفية'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: _busy || lower == null ? null : _capturePair,
            icon: const Icon(Icons.filter_none_outlined),
            label: Text(_busy ? 'يلتقط الشرائح...' : 'التقاط الشريحة ثم التي فوقها'),
          ),
          const SizedBox(height: 12),
          Text(_status),
          if (_lowerPath != null) ...[
            ListTile(
              title: const Text('الشريحة السفلى'),
              subtitle: Text(_lowerPath!),
            ),
            _cropStill(),
          ],
          if (_overlayPath != null)
            ListTile(
              title: const Text('الشريحة فوقها'),
              subtitle: Text(_overlayPath!),
            ),
          if (_board.tiles.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('الشرائح النشطة'),
            ..._board.tiles.map((tile) {
              final index = _board.tiles.indexOf(tile);
              return SwitchListTile(
                title: Text(tile.titleAr),
                subtitle: Text(tile.path ?? tile.origin),
                value: tile.visible,
                onChanged: (value) =>
                    setState(() => _board.toggle(tile.id, value)),
                secondary: IconButton(
                  tooltip: 'حذف الشريحة',
                  onPressed: index <= 0
                      ? null
                      : () => setState(() => _board.remove(tile.id)),
                  icon: const Icon(Icons.delete_outline),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
