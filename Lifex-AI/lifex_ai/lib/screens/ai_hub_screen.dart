/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: ai_hub_screen.dart
/// المسار: lib/screens/ai_hub_screen.dart
/// الوصف: يسمح للمستخدم بربط حسابه الشخصي بمحرك ذكاء اصطناعي خارجي
/// (Gemini/ChatGPT/Claude) بمفتاحه الخاص، عبر UnifiedAiHubGateway،
/// دون أن يلمس التطبيق أو خوادمنا هذا المفتاح بشكل غير آمن.
/// =============================================================
library lifex_ai.screens.ai_hub_screen;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/ai/unified_ai_hub_gateway.dart';
import 'ai_agent_screen.dart';
import 'partner_sign_in_screen.dart';

class AiHubScreen extends StatefulWidget {
  const AiHubScreen({super.key, required this.profileId});

  final String profileId;

  @override
  State<AiHubScreen> createState() => _AiHubScreenState();
}

class _AiHubScreenState extends State<AiHubScreen> {
  bool _isConnecting = false;
  String? _statusMessageAr;

  static const Map<ExternalAiProvider, String> _providerLabelsAr = {
    ExternalAiProvider.gemini: 'Gemini',
    ExternalAiProvider.chatgpt: 'ChatGPT',
    ExternalAiProvider.claude: 'Claude',
    ExternalAiProvider.custom: 'محرك آخر',
  };

  Future<void> _showConnectDialog(ExternalAiProvider provider) async {
    final keyController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('ربط حساب ${_providerLabelsAr[provider]}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'أدخل مفتاح API الخاص بك. يُحفظ على هذا الجهاز فقط. '
              'لن أختبره مع ${_providerLabelsAr[provider]} حتى يوجد اتصال حقيقي بالمحرك.',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keyController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'مفتاح API',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('ربط الحساب'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;
    if (keyController.text.trim().isEmpty) {
      setState(() => _statusMessageAr = 'يُرجى إدخال مفتاح صالح.');
      return;
    }

    setState(() {
      _isConnecting = true;
      _statusMessageAr = null;
    });

    final gateway = Provider.of<UnifiedAiHubGateway>(context, listen: false);
    final success = await gateway.connectAccount(
      profileId: widget.profileId,
      provider: provider,
      accountLabel: 'حسابي الشخصي',
      apiKeyOrToken: keyController.text.trim(),
    );

    if (!mounted) return;
    setState(() {
      _isConnecting = false;
      _statusMessageAr = success
          ? 'حُفظ مفتاح ${_providerLabelsAr[provider]} على هذا الجهاز. '
              'لم يُختبر مع المحرك بعد. التخزين الحالي في الذاكرة وليس خزنة مشفّرة.'
          : 'تعذّر حفظ المفتاح على هذا الجهاز.';
    });
  }

  Future<void> _disconnect(ExternalAiProvider provider) async {
    final gateway = Provider.of<UnifiedAiHubGateway>(context, listen: false);
    await gateway.disconnectAccount(
      profileId: widget.profileId,
      provider: provider,
    );
    if (!mounted) return;
    setState(() {
      _statusMessageAr = 'تم فصل حساب ${_providerLabelsAr[provider]}.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final gateway = Provider.of<UnifiedAiHubGateway>(context, listen: false);
    final connectedAccounts = gateway.connectedAccountsFor(widget.profileId);
    final connectedProviders = connectedAccounts.map((a) => a.provider).toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('مركز الذكاء الاصطناعي')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'حساب لايفكس لا يسجّل دخولاً نيابة عنك في Gemini أو ChatGPT أو غيرها. '
              'إن حفظت مفتاحك فهو على هذا الجهاز فقط، ولم يُختبر مع المحرك حتى يوجد اتصال حقيقي. '
              'طلب الدخول بأي موقع غير إباحي حقّك؛ التنفيذ للشركاء فقط.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PartnerSignInScreen(),
                  ),
                );
              },
              child: const Text('طلب الدخول بحساب لايفكس لموقع تختاره'),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.psychology_outlined),
                title: const Text('الوكيل الذكي'),
                subtitle: const Text(
                  'محادثة مباشرة أو تخطيط متعدد الخطوات فوق المعرفة الطبية',
                ),
                trailing: const Icon(Icons.chevron_left),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          AiAgentScreen(profileId: widget.profileId),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            if (_statusMessageAr != null) ...[
              Text(_statusMessageAr!, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
            ],
            for (final provider in [
              ExternalAiProvider.gemini,
              ExternalAiProvider.chatgpt,
              ExternalAiProvider.claude,
            ])
              Card(
                child: ListTile(
                  leading: const Icon(Icons.smart_toy_outlined),
                  title: Text(_providerLabelsAr[provider]!),
                  subtitle: Text(
                    connectedProviders.contains(provider)
                        ? 'متصل'
                        : 'غير متصل',
                    style: TextStyle(
                      color: connectedProviders.contains(provider)
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                  trailing: _isConnecting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : connectedProviders.contains(provider)
                          ? OutlinedButton(
                              onPressed: () => _disconnect(provider),
                              child: const Text('فصل'),
                            )
                          : FilledButton(
                              onPressed: () => _showConnectDialog(provider),
                              child: const Text('ربط'),
                            ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
