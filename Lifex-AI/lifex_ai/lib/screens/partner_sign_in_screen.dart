/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: partner_sign_in_screen.dart
/// طلب الدخول بحساب لايفكس إلى موقع يختاره المستخدم، ما عدا الإباحي.
/// =============================================================
library lifex_ai.screens.partner_sign_in_screen;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../features/outreach/partner_sign_in_policy.dart';
import '../features/profile/active_profile_controller.dart';
import '../features/profile/health_identity_manager.dart';
import '../widgets/honesty_banner.dart';

class PartnerSignInScreen extends StatefulWidget {
  const PartnerSignInScreen({super.key});

  @override
  State<PartnerSignInScreen> createState() => _PartnerSignInScreenState();
}

class _PartnerSignInScreenState extends State<PartnerSignInScreen> {
  final _destination = TextEditingController();
  PartnerSignInDecision? _decision;

  @override
  void dispose() {
    _destination.dispose();
    super.dispose();
  }

  void _evaluate() {
    setState(() {
      _decision = const PartnerSignInPolicy().evaluate(_destination.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ActiveProfileController>().activeProfile;
    final lifexId = profile == null
        ? null
        : HealthIdentityManager.instance.getByProfileId(profile.profileId)?.lifexId;

    return Scaffold(
      appBar: AppBar(title: const Text('الدخول بحساب لايفكس')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const HonestyBanner(
            messageAr:
                'يحق لصاحب الحساب طلب الدخول بأي موقع يريده — ذكاء اصطناعي أو غيره — ما عدا المواقع الإباحية. '
                'التنفيذ يتم داخل نظامنا. المواقع غير الشريكة لا تُفتح لها جلسة ولا تُحفظ كلمات سرها هنا.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _destination,
            decoration: const InputDecoration(
              labelText: 'عنوان الموقع',
              hintText: 'مثال: chatgpt.com أو عيادة شريكة',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _evaluate(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _evaluate,
            child: const Text('التحقق من حق الدخول'),
          ),
          if (_decision != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_decision!.messageAr),
              ),
            ),
          ],
          if (_decision?.mayProceed == true && lifexId != null) ...[
            const SizedBox(height: 8),
            ListTile(
              title: const Text('معرّف لايفكس المحلي للشريك'),
              subtitle: Text(lifexId),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: lifexId));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('نُسخ المعرّف. بلا بيانات مرض.')),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
