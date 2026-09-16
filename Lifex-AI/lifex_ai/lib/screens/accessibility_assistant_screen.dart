/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: accessibility_assistant_screen.dart
/// المسار: lib/screens/accessibility_assistant_screen.dart
/// الوصف: واجهة مساعدة المكفوفين وضعاف البصر — وصف مشهد، كشف عوائق،
/// قراءة نص/عملة. تلتقط صورة عبر الكاميرا وتمرّرها لـ AssistiveVisionEngine،
/// ثم تنطق النتيجة فوراً.
///
/// ⚠️ ملاحظة تشغيلية صادقة: حتى ربط محرك رؤية حاسوبية فعلي (ML Kit أو
/// ما يعادله) في main.dart، ستعرض هذه الشاشة رسالة "الميزة غير متاحة
/// حالياً" بدلاً من نتيجة وهمية — نفس المبدأ المتّبع في بقية التطبيق
/// (مثل بوابة الدفع) من عدم الادّعاء بعمل ميزة قبل اكتمال ربطها الفعلي.
/// =============================================================
library lifex_ai.screens.accessibility_assistant_screen;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/app_config.dart';
import '../features/accessibility/assistive_vision_engine.dart';
import '../features/voice/voice_engine.dart';
import '../widgets/accessible_widgets.dart';
import 'medical_reference_screen.dart';
import 'optical_radar_screen.dart';

class AccessibilityAssistantScreen extends StatefulWidget {
  const AccessibilityAssistantScreen({super.key, required this.profileId});

  final String profileId;

  @override
  State<AccessibilityAssistantScreen> createState() =>
      _AccessibilityAssistantScreenState();
}

class _AccessibilityAssistantScreenState
    extends State<AccessibilityAssistantScreen> {
  bool _isProcessing = false;
  String? _lastResultAr;

  Future<void> _runFeature(AssistiveFeatureType type, String labelAr) async {
    setState(() {
      _isProcessing = true;
      _lastResultAr = null;
    });

    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(source: ImageSource.camera);

      if (photo == null) {
        setState(() {
          _isProcessing = false;
          _lastResultAr = 'لم يتم التقاط صورة.';
        });
        return;
      }

      final imageBytes = await photo.readAsBytes();

      if (!mounted) return;
      final engine = Provider.of<AssistiveVisionEngine>(context, listen: false);

      final result = await engine.process(
        imageOrFrameInput: imageBytes,
        type: type,
        context: {'profileId': widget.profileId},
      );

      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _lastResultAr = result.spokenMessageAr;
      });

      announceForScreenReader(context, result.spokenMessageAr);
      if (AppConfig.instance.voiceGuidanceEnabledByDefault) {
        await VoiceEngine.instance.speak(result.spokenMessageAr);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _lastResultAr = 'تعذّر تشغيل "$labelAr" حالياً.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المساعد البصري')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Semantics(
              label: 'تنويه: هذه أداة مساعدة إضافية ولا تغني عن العصا '
                  'البيضاء أو كلب الإرشاد أو الحذر المعتاد، خصوصاً عند '
                  'عبور الطرق.',
              child: const ExcludeSemantics(
                child: Text(
                  '⚠️ هذه أداة مساعدة إضافية ولا تغني عن العصا البيضاء '
                  'أو كلب الإرشاد أو الحذر المعتاد، خصوصاً عند عبور الطرق.',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _FeatureButton(
              icon: Icons.remove_red_eye_outlined,
              label: 'صف لي المكان',
              onTap: _isProcessing
                  ? null
                  : () => _runFeature(
                        AssistiveFeatureType.sceneDescription,
                        'وصف المشهد',
                      ),
            ),
            _FeatureButton(
              icon: Icons.warning_amber_outlined,
              label: 'هل يوجد عائق أمامي؟',
              onTap: _isProcessing
                  ? null
                  : () => _runFeature(
                        AssistiveFeatureType.obstacleDetection,
                        'كشف العوائق',
                      ),
            ),
            _FeatureButton(
              icon: Icons.text_fields_outlined,
              label: 'اقرأ لي هذا النص',
              onTap: _isProcessing
                  ? null
                  : () => _runFeature(
                        AssistiveFeatureType.textAndCurrencyReading,
                        'قراءة النص',
                      ),
            ),
            _FeatureButton(
              icon: Icons.flash_on_outlined,
              label: 'الرادار الضوئي',
              onTap: _isProcessing
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OpticalRadarScreen(),
                        ),
                      );
                    },
            ),
            _FeatureButton(
              icon: Icons.biotech_outlined,
              label: 'مرجع العلامات البصرية',
              onTap: _isProcessing
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MedicalReferenceScreen(
                            kind: MedicalReferenceKind.cameraSigns,
                          ),
                        ),
                      );
                    },
            ),
            const SizedBox(height: 20),
            if (_isProcessing)
              const Center(child: CircularProgressIndicator())
            else if (_lastResultAr != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      _lastResultAr!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FeatureButton extends StatelessWidget {
  const _FeatureButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
