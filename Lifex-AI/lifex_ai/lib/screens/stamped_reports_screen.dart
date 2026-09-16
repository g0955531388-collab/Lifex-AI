/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: stamped_reports_screen.dart
/// استخراج سيرة مختومة كنص. لا إرسال سري تلقائي.
/// =============================================================
library lifex_ai.screens.stamped_reports_screen;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../features/network_box/box_unit_catalog.dart';
import '../features/network_box/profile_box_store.dart';
import '../features/profile/active_profile_controller.dart';
import '../features/reports/stamped_report.dart';
import '../widgets/honesty_banner.dart';
import '../widgets/voice_fill_button.dart';

class StampedReportsScreen extends StatefulWidget {
  const StampedReportsScreen({super.key});

  @override
  State<StampedReportsScreen> createState() => _StampedReportsScreenState();
}

class _StampedReportsScreenState extends State<StampedReportsScreen> {
  String? _text;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ActiveProfileController>().activeProfile;
    return Scaffold(
      appBar: AppBar(title: const Text('التقارير المختومة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const HonestyBanner(
            messageAr:
                'يحق لصاحب الحساب استخراج سيرته كنص للطباعة أو الإرسال اليدوي. لا إرسال سري تلقائي.',
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: profile == null
                ? null
                : () {
                    final store = ProfileBoxStore(profile);
                    final labs = store
                        .list(BoxUnitCatalog.labs.storageKey)
                        .map((item) => item['title'])
                        .join('، ');
                    final meds = profile.currentMedicationNames.join('، ');
                    final report = StampedReport(
                      profile: profile,
                      bodyAr: 'أدوية: ${meds.isEmpty ? '—' : meds}\n'
                          'تحاليل محلية: ${labs.isEmpty ? '—' : labs}\n'
                          'حساسية: ${profile.allergies.isEmpty ? '—' : profile.allergies.map((a) => a.substance).join('، ')}',
                    );
                    setState(() => _text = report.toPlainText());
                  },
            child: const Text('استخراج التقرير'),
          ),
          if (_text != null) ...[
            const SizedBox(height: 12),
            SelectableText(_text!),
            Row(
              children: [
                VoiceFillButton(
                  onText: (text) {
                    setState(() => _text = '$_text\n$text');
                  },
                ),
                FilledButton.tonal(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: _text!));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('نُسخ النص. أرسله أنت إن شئت.')),
                    );
                  },
                  child: const Text('نسخ'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
