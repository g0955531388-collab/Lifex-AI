/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: stamped_reports_screen.dart
/// تقرير السي في مختوم بختم لايفكس. مشاركة يدوية. اقتراح أطباء بالاختصاص والمسافة.
/// =============================================================
library lifex_ai.screens.stamped_reports_screen;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/local_knowledge.dart';
import '../features/network_box/profile_box_store.dart';
import '../features/profile/active_profile_controller.dart';
import '../features/profile/cv_document_vault.dart';
import '../features/profile/cv_report_engine.dart';
import '../widgets/honesty_banner.dart';
import '../widgets/lifex_brand_mark.dart';
import '../widgets/voice_fill_button.dart';
import 'doctor_directory_screen.dart';

class StampedReportsScreen extends StatefulWidget {
  const StampedReportsScreen({super.key});

  @override
  State<StampedReportsScreen> createState() => _StampedReportsScreenState();
}

class _StampedReportsScreenState extends State<StampedReportsScreen> {
  String? _text;
  String? _specialty;
  String? _shareHint;
  List<Map<String, dynamic>> _doctors = const [];

  void _compile() {
    final profile = context.read<ActiveProfileController>().activeProfile;
    if (profile == null) return;
    LocalKnowledge knowledge;
    try {
      knowledge = context.read<LocalKnowledge>();
    } catch (_) {
      knowledge = LocalKnowledge(
        diseases: const [],
        medications: const [],
        symptoms: const [],
        tests: const [],
        namedConditions: const [],
        cameraSigns: const [],
        disclaimerAr: 'مرجع توعية فقط.',
      );
    }
    final store = ProfileBoxStore(profile);
    final bundle = const CvReportEngine().compile(
      profile: profile,
      knowledge: knowledge,
      cameraNotes: store.list(BoxKeys.cameraNotes),
      vault: CvDocumentVault(profile).all(),
    );
    setState(() {
      _text = bundle.report.toPlainText();
      _specialty = bundle.specialtyAr;
      _shareHint = bundle.shareHintAr;
      _doctors = const CvReportEngine().doctorsForSpecialty(
        doctors: store.list(BoxKeys.doctors),
        specialtyAr: bundle.specialtyAr,
      );
    });
  }

  Future<void> _share() async {
    final text = _text;
    if (text == null) return;
    try {
      await const MethodChannel('lifex_ai/share')
          .invokeMethod<void>('shareText', {'text': text});
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'نُسخ التقرير. الصقه في درايف أو واتساب أو للطابعة من حسابك أنت.',
          ),
        ),
      );
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'ورقة المشاركة لجهازك: صديق أو طبيب أو طابعة أو ${CvDocumentVault.cloudChoices.join(' / ')}.',
        ),
      ),
    );
  }

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
                'المحرك الداخلي يقرأ إجاباتك ومسارات الصور ويختم التقرير. '
                'التقدير تقريبي من المرجع المحلي. لا إرسال سري. السحابة يختارها صاحب الحساب.',
          ),
          const LifexBrandMark(size: 96),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: profile == null ? null : _compile,
            child: const Text('إنتاج تقرير السي في المختوم'),
          ),
          if (_shareHint != null) ...[
            const SizedBox(height: 8),
            Text(_shareHint!),
            Text('الاختصاص المقترح: $_specialty'),
          ],
          if (_doctors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('أطباء ملفك — $_specialty — من الأقرب فالأبعد (كم مسجّل)'),
            for (final doctor in _doctors)
              ListTile(
                title: Text(doctor['title']?.toString() ?? ''),
                subtitle: Text(
                  '${doctor['detail']} · ${doctor['km'] ?? '—'} كم',
                ),
              ),
          ],
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DoctorDirectoryScreen()),
            ),
            child: const Text('أطباء النظام على هذا الجهاز'),
          ),
          if (_text != null) ...[
            const SizedBox(height: 12),
            SelectableText(_text!),
            Wrap(
              spacing: 8,
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
                      const SnackBar(content: Text('نُسخ. أرسله أنت إن شئت.')),
                    );
                  },
                  child: const Text('نسخ'),
                ),
                FilledButton(
                  onPressed: _share,
                  child: const Text('مشاركة / سحابة / طباعة'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
