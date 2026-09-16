/// =============================================================
/// Lifex-AI — المكوّنات المشتركة
/// الملف: voice_fill_button.dart
/// ملء حقل بالصوت بعد موافقة الميكروفون. ليس تجسساً في الخلفية.
/// =============================================================
library lifex_ai.widgets.voice_fill_button;

import 'package:flutter/material.dart';

import '../core/permission_transparency.dart';
import '../features/voice/voice_engine.dart';

class VoiceFillButton extends StatelessWidget {
  const VoiceFillButton({super.key, required this.onText});

  final void Function(String text) onText;

  Future<void> _listen(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إذن الميكروفون'),
        content: const Text(
          'لملء الحقل بالصوت وأنت تضغط. ليس تجسساً في الخلفية ولا قراءة رسائل.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('رفض'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    PermissionTransparencyManager.instance.decide(
      permission: LifexSensitivePermission.microphone,
      granted: true,
    );
    PermissionTransparencyManager.instance
        .useIfGranted(LifexSensitivePermission.microphone);
    final result = await VoiceEngine.instance.startListening();
    final text = result.textResult?.trim() ?? '';
    if (text.isNotEmpty) onText(text);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'ملء بالصوت',
      onPressed: () => _listen(context),
      icon: const Icon(Icons.mic),
    );
  }
}
