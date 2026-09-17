/// =============================================================
/// Lifex-AI — المشاركة العامة
/// الملف: encyclopedia_share_bridge.dart
/// يفتح ورقة مشاركة النظام بنبذة لايفكس. النسخ احتياطي إن تعذّر القصد.
/// =============================================================
library lifex_ai.features.outreach.encyclopedia_share_bridge;

import 'package:flutter/services.dart';

import 'lifex_public_brief.dart';

class EncyclopediaShareResult {
  const EncyclopediaShareResult({
    required this.openedSheet,
    required this.copied,
    required this.messageAr,
  });

  final bool openedSheet;
  final bool copied;
  final String messageAr;
}

class EncyclopediaShareBridge {
  EncyclopediaShareBridge({
    MethodChannel? channel,
    Future<void> Function(String text)? copy,
  })  : _channel = channel ?? const MethodChannel('lifex_ai/share'),
        _copy = copy;

  final MethodChannel _channel;
  final Future<void> Function(String text)? _copy;

  Future<EncyclopediaShareResult> shareEncyclopedia() async {
    final text = const LifexPublicBrief().fullAr;
    try {
      await _channel.invokeMethod<void>('shareText', {'text': text});
      return const EncyclopediaShareResult(
        openedSheet: true,
        copied: false,
        messageAr:
            'فُتحت ورقة المشاركة. اختر صديقاً أو أيقونة تواصل. المُرسل نبذة النظام لا الملف الصحي.',
      );
    } on MissingPluginException {
      await _copyToClipboard(text);
      return const EncyclopediaShareResult(
        openedSheet: false,
        copied: true,
        messageAr:
            'لا ورقة مشاركة على هذه المنصة. نُسخت النبذة الكاملة. الصقها لصديق أو في تطبيق التواصل.',
      );
    } catch (_) {
      await _copyToClipboard(text);
      return const EncyclopediaShareResult(
        openedSheet: false,
        copied: true,
        messageAr: 'تعذّر فتح المشاركة. نُسخت النبذة إلى الحافظة.',
      );
    }
  }

  Future<void> _copyToClipboard(String text) async {
    if (_copy != null) {
      await _copy!(text);
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
  }
}
