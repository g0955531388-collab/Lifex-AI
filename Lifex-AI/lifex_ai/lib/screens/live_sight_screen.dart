/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: live_sight_screen.dart
/// بث عدسة على الشاشة المفتوحة. يصف إن وُجد محرك، وإلا يصرّح بالنقص.
/// =============================================================
library lifex_ai.screens.live_sight_screen;

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/permission_transparency.dart';
import '../features/accessibility/assistive_vision_engine.dart';
import '../features/accessibility/live_sight_conductor.dart';
import '../features/voice/voice_engine.dart';
import '../widgets/honesty_banner.dart';

class LiveSightScreen extends StatefulWidget {
  const LiveSightScreen({super.key, required this.profileId});

  final String profileId;

  @override
  State<LiveSightScreen> createState() => _LiveSightScreenState();
}

class _LiveSightScreenState extends State<LiveSightScreen> {
  final LiveSightConductor _conductor = LiveSightConductor();
  CameraController? _lens;
  Timer? _pulseTimer;
  bool _consented = false;
  bool _busyPulse = false;
  String _spokenAr =
      'هذه أذن رقمية على الشاشة فقط. ليست تجسساً في الخلفية وليست تشخيصاً.';

  @override
  void dispose() {
    _pulseTimer?.cancel();
    unawaited(_lens?.dispose());
    super.dispose();
  }

  Future<void> _askConsentThenOpen() async {
    final agreed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('بث حي على هذه الشاشة'),
        content: const Text(
          'سأفتح العدسة أمامك ما دامت هذه الصفحة مفتوحة. '
          'أغلق الصفحة فيتوقف البث. لا أرسل الصورة لخادم، ولا أصف جداراً إن لم يعمل محرك رؤية معتمد.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('رفض'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('أوافق على البث هنا'),
          ),
        ],
      ),
    );
    if (agreed != true || !mounted) return;
    PermissionTransparencyManager.instance.decide(
      permission: LifexSensitivePermission.camera,
      granted: true,
    );
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (!status.isGranted) {
      setState(() {
        _spokenAr = 'رفض النظام إذن الكاميرا. البث الحي متوقف.';
      });
      await VoiceEngine.instance.speak(_spokenAr);
      return;
    }
    setState(() => _consented = true);
    await _attachLens();
  }

  Future<void> _attachLens() async {
    try {
      final found = await availableCameras();
      if (found.isEmpty) {
        setState(() => _spokenAr = 'لا توجد عدسة ظاهرة لهذا الجهاز.');
        await VoiceEngine.instance.speak(_spokenAr);
        return;
      }
      final rear = found.where(
        (item) => item.lensDirection == CameraLensDirection.back,
      );
      final chosen = rear.isNotEmpty ? rear.first : found.first;
      final controller = CameraController(
        chosen,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _lens = controller);
      _pulseTimer?.cancel();
      _pulseTimer = Timer.periodic(const Duration(seconds: 7), (_) {
        unawaited(_onePulse());
      });
      await _announce(
        'العدسة مفتوحة على هذه الشاشة. سأحاول قراءة إطار كل بضع ثوان.',
      );
      await _onePulse();
    } catch (error) {
      setState(() {
        _spokenAr =
            'تعذّر تشغيل العدسة الحية على هذا الجهاز. $error';
      });
      await VoiceEngine.instance.speak(_spokenAr);
    }
  }

  Future<void> _onePulse() async {
    if (_busyPulse || !mounted) return;
    _busyPulse = true;
    try {
      final lens = _lens;
      List<int>? bytes;
      if (lens != null && lens.value.isInitialized) {
        final shot = await lens.takePicture();
        bytes = await shot.readAsBytes();
      }
      AssistiveVisionResult? vision;
      if (bytes != null && bytes.isNotEmpty && mounted) {
        final engine = AssistiveVisionEngine.instance;
        vision = await engine.process(
          imageOrFrameInput: bytes,
          type: AssistiveFeatureType.sceneDescription,
          context: {'profileId': widget.profileId, 'live': true},
        );
      }
      if (!mounted) return;
      final pulse = _conductor.pulse(
        cameraReady: lens != null && lens.value.isInitialized,
        userConsentedOnThisScreen: _consented,
        frameBytes: bytes,
        vision: vision,
      );
      setState(() => _spokenAr = pulse.spokenAr);
      if (pulse.speakNow) {
        await VoiceEngine.instance.speak(pulse.spokenAr);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _spokenAr = 'انقطع نبض الإطار. البث يتوقف إن أغلقت الصفحة. $error';
      });
    } finally {
      _busyPulse = false;
    }
  }

  Future<void> _announce(String text) async {
    setState(() => _spokenAr = text);
    await VoiceEngine.instance.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final lens = _lens;
    return Scaffold(
      appBar: AppBar(title: const Text('البث الحي للعدسة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const HonestyBanner(
            messageAr:
                'مساعدة إضافية فقط. ليست بديلاً عن العصا البيضاء أو كلب الإرشاد، وليست تشخيصاً طبياً.',
          ),
          const SizedBox(height: 12),
          if (lens != null && lens.value.isInitialized)
            AspectRatio(
              aspectRatio: lens.value.aspectRatio,
              child: CameraPreview(lens),
            )
          else
            Container(
              height: 220,
              alignment: Alignment.center,
              color: Colors.black12,
              child: Text(
                _consented ? 'العدسة لم تُهيأ بعد' : 'البث مغلق حتى الموافقة',
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _consented ? null : _askConsentThenOpen,
            icon: const Icon(Icons.videocam_outlined),
            label: Text(_consented ? 'البث يعمل على هذه الصفحة' : 'ابدأ البث الحي'),
          ),
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Text(_spokenAr, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
