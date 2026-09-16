/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: voice_control_screen.dart
/// المسار: lib/screens/voice_control_screen.dart
/// الوصف: أوامر عربية عبر VoiceEngine وCommandParser. الطوارئ تحتاج تأكيداً.
/// =============================================================
library lifex_ai.screens.voice_control_screen;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/emergency/emergency_manager.dart';
import '../features/profile/active_profile_controller.dart';
import '../features/voice/command_parser.dart';
import '../features/voice/voice_engine.dart';
import '../widgets/accessible_widgets.dart';
import 'appointments_screen.dart';
import 'camera_notes_screen.dart';
import 'doctor_directory_screen.dart';
import 'health_profile_screen.dart';
import 'medications_screen.dart';
import 'pharmacy_stock_screen.dart';
import 'project_box_hub_screen.dart';
import 'smart_health_questionnaire_screen.dart';
import 'system_search_screen.dart';

class VoiceControlScreen extends StatefulWidget {
  const VoiceControlScreen({super.key});

  @override
  State<VoiceControlScreen> createState() => _VoiceControlScreenState();
}

class _VoiceControlScreenState extends State<VoiceControlScreen> {
  final _parser = CommandParser();
  String _status = 'اضغط على الميكروفون وتحدث بالعربية';
  String? _lastText;
  bool _busy = false;

  Future<void> _listen() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _status = 'أستمع الآن...';
    });
    final result = await VoiceEngine.instance.startListening();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _lastText = result.textResult;
      _status = result.success
          ? 'تم التعرف على الأمر'
          : (result.errorMessageAr ?? 'تعذّر التعرف على الكلام');
    });
    if (result.textResult != null && result.textResult!.trim().isNotEmpty) {
      await _handleText(result.textResult!);
    } else {
      await VoiceEngine.instance.speak(_status);
    }
  }

  Future<void> _handleText(String text) async {
    final command = _parser.parse(text);
    final profiles = context.read<ActiveProfileController>();
    switch (command.intent) {
      case VoiceCommandIntent.openHealthProfile:
        await VoiceEngine.instance.speak('سأفتح ملفك الصحي');
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HealthProfileScreen(profile: profiles.activeProfile),
          ),
        );
        break;
      case VoiceCommandIntent.openMedications:
        await VoiceEngine.instance.speak('سأفتح سجل أدويتك');
        if (!mounted) return;
        final profileId = profiles.activeProfileId;
        if (profileId == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MedicationsScreen(profileId: profileId),
          ),
        );
        break;
      case VoiceCommandIntent.openAppointments:
        await VoiceEngine.instance.speak('سأفتح مواعيدك');
        if (!mounted) return;
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AppointmentsScreen()));
        break;
      case VoiceCommandIntent.callEmergency:
        await VoiceEngine.instance
            .speak('فهمت أنك تطلب الطوارئ. اضغط زر التأكيد لإرسال الاستغاثة.');
        if (!mounted) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('طلب طوارئ'),
            content: const Text(
                'هل تريد إرسال تنبيه الطوارئ لجهات الثقة؟ لا يتم إرسال أي رسالة دون تأكيدك.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('إلغاء')),
              FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('تأكيد الطوارئ')),
            ],
          ),
        );
        if (confirmed == true && mounted) {
          context.read<EmergencyManager>().triggerEmergency(
                profileId: profiles.activeProfileId ?? 'unknown_profile',
                reasonAr: 'أمر صوتي مؤكَّد من شاشة التحكم الصوتي.',
              );
          announceForScreenReader(context, 'تم إرسال تنبيه الطوارئ لجهات الثقة.');
        }
        break;
      case VoiceCommandIntent.addSymptom:
        await VoiceEngine.instance
            .speak('سجّل العرض في الاستبيان الصحي الشامل');
        if (!mounted) return;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const SmartHealthQuestionnaireScreen()));
        break;
      case VoiceCommandIntent.readLastLabResult:
        await VoiceEngine.instance
            .speak('لا توجد نتيجة مخبرية مرتبطة بملفك حتى الآن.');
        break;
      case VoiceCommandIntent.switchProfile:
        await VoiceEngine.instance
            .speak('يمكنك تبديل الملف من إعدادات الحساب.');
        break;
      case VoiceCommandIntent.openProjectBox:
        await VoiceEngine.instance.speak('سأفتح صندوق المشروع');
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProjectBoxHubScreen()),
        );
        break;
      case VoiceCommandIntent.openSearch:
        await VoiceEngine.instance.speak('سأفتح البحث');
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SystemSearchScreen()),
        );
        break;
      case VoiceCommandIntent.openPharmacy:
        await VoiceEngine.instance.speak('سأفتح الصيدلية');
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PharmacyStockScreen()),
        );
        break;
      case VoiceCommandIntent.openDoctors:
        await VoiceEngine.instance.speak('سأفتح دليل الأطباء');
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DoctorDirectoryScreen()),
        );
        break;
      case VoiceCommandIntent.openCamera:
        await VoiceEngine.instance.speak('سأفتح الكاميرا بعد موافقتك');
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CameraNotesScreen()),
        );
        break;
      case VoiceCommandIntent.unknown:
        await VoiceEngine.instance.speak(
            'لم أفهم الأمر. جرّب: افتح ملفي الصحي أو افتح أدويتي أو افتح صندوق المشروع.');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التحكم الصوتي')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(_busy ? Icons.hearing : Icons.mic,
                  size: 90,
                  color: _busy
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary),
              const SizedBox(height: 18),
              Text(_status,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium),
              if (_lastText != null) ...[
                const SizedBox(height: 16),
                Card(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('سمعت: $_lastText',
                            textAlign: TextAlign.center))),
              ],
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _busy ? null : _listen,
                icon: const Icon(Icons.mic),
                label: Text(_busy ? 'جارٍ الاستماع...' : 'تحدث الآن'),
              ),
              const SizedBox(height: 18),
              const Text(
                  'أمثلة: افتح ملفي الصحي، افتح أدويتي، افتح مواعيدي، سجّل عرض، أريد الطوارئ',
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
