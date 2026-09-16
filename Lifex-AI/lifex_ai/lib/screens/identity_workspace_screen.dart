/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: identity_workspace_screen.dart
/// الهوية الحقيقية والمستعارة ومن التكوين.
/// =============================================================
library lifex_ai.screens.identity_workspace_screen;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/network_box/profile_box_store.dart';
import '../features/profile/active_profile_controller.dart';
import '../features/profile/health_identity_manager.dart';
import '../widgets/honesty_banner.dart';
import '../widgets/voice_fill_button.dart';

class IdentityWorkspaceScreen extends StatefulWidget {
  const IdentityWorkspaceScreen({super.key});

  @override
  State<IdentityWorkspaceScreen> createState() =>
      _IdentityWorkspaceScreenState();
}

class _IdentityWorkspaceScreenState extends State<IdentityWorkspaceScreen> {
  late final TextEditingController _alias;
  late final TextEditingController _origin;
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _alias = TextEditingController();
    _origin = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    final store = _store();
    _alias.text = store?.stringField(BoxKeys.aliasName) ?? '';
    _origin.text = store?.stringField(BoxKeys.lifeOriginNotes) ?? '';
    _seeded = true;
  }

  ProfileBoxStore? _store() {
    final profile =
        context.read<ActiveProfileController>().activeProfile;
    if (profile == null) return null;
    return ProfileBoxStore(profile);
  }

  @override
  void dispose() {
    _alias.dispose();
    _origin.dispose();
    super.dispose();
  }

  void _save() {
    final controller = context.read<ActiveProfileController>();
    final store = _store();
    if (store == null) return;
    store.setString(BoxKeys.aliasName, _alias.text.trim());
    store.setString(BoxKeys.lifeOriginNotes, _origin.text.trim());
    controller.saveActiveProfileChanges();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('حُفظت الهوية في ملفك على هذا الجهاز.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveProfileController>(
      builder: (context, controller, _) {
        final profile = controller.activeProfile;
        final identity = profile == null
            ? null
            : HealthIdentityManager.instance.getByProfileId(profile.profileId);
        return Scaffold(
          appBar: AppBar(title: const Text('الهوية من الصفر')),
          body: profile == null
              ? const Center(child: Text('لا يوجد ملف صحي نشط.'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const HonestyBanner(
                      messageAr:
                          'الهوية الحقيقية للجهات الصحية المخوّلة فقط. الهوية المستعارة للمجتمع والتعليم. التحقق الوثائقي يحتاج خادماً.',
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      title: const Text('الاسم الحقيقي'),
                      subtitle: Text(profile.fullName),
                    ),
                    ListTile(
                      title: const Text('Lifex-Health ID'),
                      subtitle: Text(identity?.lifexId ?? 'يُنشأ مع الملف'),
                    ),
                    ListTile(
                      title: const Text('مستوى التحقق'),
                      subtitle: Text(
                          identity?.verificationLevel.name ?? 'unverified'),
                    ),
                    TextField(
                      controller: _alias,
                      decoration: const InputDecoration(
                        labelText: 'الهوية المستعارة',
                        hintText: 'مثال: مريض الأمل',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _origin,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'من التكوين: حمل أو ولادة أو بداية الملف',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: VoiceFillButton(
                        onText: (text) {
                          _origin.text = _origin.text.isEmpty
                              ? text
                              : '${_origin.text} $text';
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _save,
                      child: const Text('حفظ الهوية'),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
