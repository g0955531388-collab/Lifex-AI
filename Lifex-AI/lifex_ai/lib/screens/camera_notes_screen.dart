/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: camera_notes_screen.dart
/// التقاط أوراق بموافقة ظاهرة. OCR فارغ حتى محرك معتمد.
/// =============================================================
library lifex_ai.screens.camera_notes_screen;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/permission_transparency.dart';
import '../features/network_box/profile_box_store.dart';
import '../features/profile/active_profile_controller.dart';
import '../features/profile/cv_document_vault.dart';
import '../widgets/honesty_banner.dart';
import 'layered_lens_studio_screen.dart';
import 'live_sight_screen.dart';
import 'medical_reference_screen.dart';
import 'thumbnail_manage_screen.dart';

class CameraNotesScreen extends StatefulWidget {
  const CameraNotesScreen({super.key});

  @override
  State<CameraNotesScreen> createState() => _CameraNotesScreenState();
}

class _CameraNotesScreenState extends State<CameraNotesScreen> {
  final _note = TextEditingController();
  String _kind = 'document';
  String _status = '';

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إذن الكاميرا'),
        content: const Text(
          'لالتقاط أوراق أو شاشات أو منطقة جسم بموافقتك الظاهرة. لا تصوير خفي لمن يمسك الهاتف.',
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
    if (ok != true || !mounted) return;
    PermissionTransparencyManager.instance.decide(
      permission: LifexSensitivePermission.camera,
      granted: true,
    );
    final file = await ImagePicker().pickImage(source: ImageSource.camera);
    if (file == null || !mounted) return;
    final controller = context.read<ActiveProfileController>();
    final profile = controller.activeProfile;
    if (profile == null) return;
    ProfileBoxStore(profile).add(BoxKeys.cameraNotes, {
      'title': _kind,
      'detail': _note.text.trim().isEmpty ? file.path : _note.text.trim(),
      'path': file.path,
    });
    CvDocumentVault(profile).attach(
      title: _kind,
      path: file.path,
      passphrase: profile.profileId,
      detail: _note.text.trim(),
    );
    controller.saveActiveProfileChanges();
    setState(() {
      _status =
          'حُفظ المسار. قراءة OCR الآلية فارغة حتى محرك معتمد. العلامات مرجع إشارات لا تشخيص.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ActiveProfileController>().activeProfile;
    final notes = profile == null
        ? const <Map<String, dynamic>>[]
        : ProfileBoxStore(profile).list(BoxKeys.cameraNotes);
    return Scaffold(
      appBar: AppBar(title: const Text('الكاميرا الذكية')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const HonestyBanner(
            messageAr:
                'أوراق وشاشات وعلامات كإشارات. ليست قراءة إشعاعية وليست تشخيص جلد.',
          ),
          DropdownButtonFormField<String>(
            value: _kind,
            items: const [
              DropdownMenuItem(value: 'document', child: Text('ورقة / وثيقة وطنية')),
              DropdownMenuItem(value: 'screen', child: Text('شاشة جهاز')),
              DropdownMenuItem(value: 'body', child: Text('منطقة جسم')),
              DropdownMenuItem(value: 'bedsore', child: Text('قرحة فراش')),
              DropdownMenuItem(value: 'tongue', child: Text('لسان')),
              DropdownMenuItem(value: 'skin', child: Text('جلد')),
              DropdownMenuItem(value: 'hair', child: Text('شعر')),
              DropdownMenuItem(value: 'vessel', child: Text('شرايين بارزة')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _kind = value);
            },
            decoration: const InputDecoration(labelText: 'نوع الالتقاط'),
          ),
          TextField(
            controller: _note,
            decoration: const InputDecoration(labelText: 'ملاحظة'),
          ),
          FilledButton.icon(
            onPressed: _capture,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('التقاط لقطة ثابتة بعد الموافقة'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              final id =
                  context.read<ActiveProfileController>().activeProfileId;
              if (id == null) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LiveSightScreen(profileId: id),
                ),
              );
            },
            icon: const Icon(Icons.videocam_outlined),
            label: const Text('البث الحي على هذه الشاشة'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LayeredLensStudioScreen(),
                ),
              );
            },
            icon: const Icon(Icons.filter_none_outlined),
            label: const Text('عدسة الشرائح المتراكبة (جلد وتكبير)'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ThumbnailManageScreen(),
                ),
              );
            },
            icon: const Icon(Icons.image_outlined),
            label: const Text('Manage the thumbnail'),
          ),
          if (_status.isNotEmpty) Text(_status),
          for (final note in notes)
            ListTile(
              title: Text(note['title']?.toString() ?? ''),
              subtitle: Text(note['detail']?.toString() ?? ''),
            ),
          ListTile(
            title: const Text('مرجع العلامات البصرية'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MedicalReferenceScreen(
                  kind: MedicalReferenceKind.cameraSigns,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
