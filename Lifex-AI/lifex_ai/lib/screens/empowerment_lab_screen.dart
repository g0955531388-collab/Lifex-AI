/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: empowerment_lab_screen.dart
/// موسوعة تمكين محلية: استماع وفصل وميثاق. ليست استشارة مالية.
/// =============================================================
library lifex_ai.screens.empowerment_lab_screen;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../features/education/empowerment_chapters.dart';
import '../features/network_box/profile_box_store.dart';
import '../features/profile/active_profile_controller.dart';
import '../features/reports/stamped_report.dart';
import '../features/voice/voice_engine.dart';
import '../widgets/honesty_banner.dart';
import '../widgets/voice_fill_button.dart';

class EmpowermentLabScreen extends StatefulWidget {
  const EmpowermentLabScreen({super.key});

  @override
  State<EmpowermentLabScreen> createState() => _EmpowermentLabScreenState();
}

class _EmpowermentLabScreenState extends State<EmpowermentLabScreen> {
  final _pact = TextEditingController();
  String _clock = '';

  @override
  void initState() {
    super.initState();
    _tick();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final stored = context
        .read<ActiveProfileController>()
        .activeProfile
        ?.questionnaireData[BoxKeys.empowermentPact];
    if (stored is String && _pact.text.isEmpty) {
      _pact.text = stored;
    }
  }

  @override
  void dispose() {
    _pact.dispose();
    super.dispose();
  }

  void _tick() {
    final now = TimeOfDay.now();
    setState(() {
      _clock =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _listen(EmpowermentChapter chapter) async {
    await VoiceEngine.instance.speak(chapter.spokenAr());
  }

  void _savePact() {
    final controller = context.read<ActiveProfileController>();
    final profile = controller.activeProfile;
    if (profile == null) return;
    ProfileBoxStore(profile).setString(
      BoxKeys.empowermentPact,
      _pact.text.trim(),
    );
    controller.saveActiveProfileChanges();
    final stamped = StampedReport(
      profile: profile,
      bodyAr: 'ميثاق تسعين يوماً:\n${_pact.text.trim()}',
    ).toPlainText();
    Clipboard.setData(ClipboardData(text: stamped));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'حُفظ الميثاق محلياً ونُسخ كنص مختوم. تصدير PDF يحتاج محركاً معتمداً.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('موسوعة التمكين'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Center(child: Text(_clock)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            AppConstants.studioBannerCredit,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          const HonestyBanner(
            messageAr:
                'تعليم تمكين بإشراف المالك. ليس استشارة مالية ولا ضمان دخل. '
                'النطق من محرك الجهاز. لقطة الشاشة يحفظها نظام الهاتف لا خادم ليفكس.',
          ),
          for (final chapter in const EmpowermentLibrary().chapters())
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chapter.titleAr,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(chapter.bodyAr),
                    TextButton.icon(
                      onPressed: () => _listen(chapter),
                      icon: const Icon(Icons.headset_outlined),
                      label: const Text('استمع للفصل'),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text('المختبر: ميثاق تسعين يوماً',
              style: Theme.of(context).textTheme.titleMedium),
          TextField(
            controller: _pact,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'أنا … ألتزم داخل ليفكس بـ …',
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: VoiceFillButton(
              onText: (text) {
                setState(() {
                  _pact.text = '${_pact.text} $text'.trim();
                });
              },
            ),
          ),
          FilledButton.icon(
            onPressed: _savePact,
            icon: const Icon(Icons.save_outlined),
            label: const Text('حفظ الميثاق محلياً ونسخه مختوماً'),
          ),
        ],
      ),
    );
  }
}
