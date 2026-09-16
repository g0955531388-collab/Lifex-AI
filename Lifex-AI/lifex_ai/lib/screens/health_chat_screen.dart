/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: health_chat_screen.dart
/// المسار: lib/screens/health_chat_screen.dart
/// الوصف: محادثة تنظيمية أولية. لا تشخّص. النطق عبر VoiceEngine.
/// =============================================================
library lifex_ai.screens.health_chat_screen;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/local_knowledge.dart';
import '../features/voice/voice_engine.dart';

class HealthChatScreen extends StatefulWidget {
  const HealthChatScreen({super.key});

  @override
  State<HealthChatScreen> createState() => _HealthChatScreenState();
}

class _HealthChatScreenState extends State<HealthChatScreen> {
  final _input = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'assistant',
      'text':
          'مرحبًا. اسألني عن تنظيم ملفك الصحي أو أدويتك أو مواعيدك. لا أستبدل الطبيب.'
    },
  ];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    final response = _answer(text);
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _messages.add({'role': 'assistant', 'text': response});
    });
    await VoiceEngine.instance.speak(response);
  }

  String _answer(String text) {
    final normalized = text.toLowerCase();
    if (normalized.contains('طوارئ') ||
        normalized.contains('ألم صدر') ||
        normalized.contains('ضيق نفس')) {
      return 'إذا كان الخطر فوريًا فاتصل برقم الطوارئ المحلي الآن، ثم افتح زر الطوارئ في التطبيق. لا تعتمد على المحادثة وحدها.';
    }
    if (normalized.contains('دواء') || normalized.contains('جرعة')) {
      return 'يمكنك فتح «أدويتي» لإضافة اسم الدواء والجرعة والوقت. لا تغيّر الجرعة أو توقف دواءً موصوفًا دون الطبيب.';
    }
    if (normalized.contains('موعد') || normalized.contains('طبيب')) {
      return 'يمكنك فتح «مواعيدي» لإضافة موعد الطبيب والمكان والتاريخ، ثم إبقاء المعلومات محدثة في ملفك.';
    }
    if (normalized.contains('ملف') || normalized.contains('استبيان')) {
      return 'افتح «الاستبيان الصحي الشامل» وسجّل المعلومات التي تعرفها، ثم احفظها. شاركها فقط مع جهة موثوقة.';
    }
    if (normalized.contains('صيدلية') || normalized.contains('دواء قريب')) {
      return 'افتح «الصيدلية» لتسجيل مخزون محلي والبحث بأقرب صنف في المدينة التي تدخلها. لا بيع دم.';
    }
    if (normalized.contains('كاميرا') || normalized.contains('ورقة')) {
      return 'افتح «الكاميرا الذكية» بعد موافقة ظاهرة. القراءة الآلية للنص فارغة حتى محرك معتمد.';
    }
    try {
      final knowledge = context.read<LocalKnowledge>();
      final hits = knowledge.search(text);
      if (hits.isNotEmpty) {
        final lines = hits
            .take(3)
            .map((hit) => '${hit.kindAr}: ${hit.titleAr} — ${hit.detailAr}')
            .join('\n');
        return '${knowledge.disclaimerAr}\n$lines';
      }
    } catch (_) {
      // بلا مرجع محلي في الاختبارات المعزولة.
    }
    return 'أستطيع حاليًا مساعدتك في تنظيم الملف الصحي والأدوية والمواعيد والتوجيه الآمن للطوارئ. اكتب سؤالك بشكل أوضح، أو راجع طبيبًا للمشورة الطبية.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المحادثة الصحية')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Card(
                child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                        'هذه محادثة تنظيمية أولية. لا تقدم تشخيصًا ولا تستبدل الطبيب أو خدمات الطوارئ.'))),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _messages.length,
              itemBuilder: (_, index) {
                final message = _messages[index];
                final user = message['role'] == 'user';
                return Align(
                  alignment:
                      user ? Alignment.centerLeft : Alignment.centerRight,
                  child: Card(
                    color: user ? Colors.blue.withOpacity(0.1) : null,
                    child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(message['text']!)),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(children: [
                Expanded(
                    child: TextField(
                        controller: _input,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                            hintText: 'اكتب سؤالك...',
                            border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                    tooltip: 'إرسال'),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
