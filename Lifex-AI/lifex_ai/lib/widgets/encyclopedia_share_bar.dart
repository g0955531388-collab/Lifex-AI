/// =============================================================
/// Lifex-AI — المكوّنات المشتركة
/// الملف: encyclopedia_share_bar.dart
/// أيقونات التواصل وزر المشاركة في الأسفل لنشر نبذة الموسوعة.
/// =============================================================
library lifex_ai.widgets.encyclopedia_share_bar;

import 'package:flutter/material.dart';

import '../features/outreach/encyclopedia_share_bridge.dart';

class EncyclopediaShareBar extends StatelessWidget {
  const EncyclopediaShareBar({super.key, this.bridge});

  final EncyclopediaShareBridge? bridge;

  Future<void> _share(BuildContext context) async {
    final result = await (bridge ?? EncyclopediaShareBridge()).shareEncyclopedia();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.messageAr)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'يحق لك مشاركة هذه الموسوعة مع صديق أو مواقع التواصل',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ShareIcon(
                    icon: Icons.share,
                    label: 'مشاركة',
                    onTap: () => _share(context),
                  ),
                  _ShareIcon(
                    icon: Icons.chat,
                    label: 'واتساب',
                    onTap: () => _share(context),
                  ),
                  _ShareIcon(
                    icon: Icons.send,
                    label: 'تلغرام',
                    onTap: () => _share(context),
                  ),
                  _ShareIcon(
                    icon: Icons.public,
                    label: 'تواصل',
                    onTap: () => _share(context),
                  ),
                  _ShareIcon(
                    icon: Icons.groups,
                    label: 'أصدقاء',
                    onTap: () => _share(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareIcon extends StatelessWidget {
  const _ShareIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      hint: 'يشارك نبذة لايفكس: الخدمات والإسناد والأسعار',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              Text(label, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
