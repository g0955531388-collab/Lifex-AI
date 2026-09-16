/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: admin_dashboard_screen.dart
/// المسار: lib/screens/admin_dashboard_screen.dart
/// الوصف: لوحة تحكم الأدمن العالمية — منح/سحب أدوار (أدمن/مشرف)، والتحكم
/// بمفاتيح الأحداث الدقيقة على مستوى النظام. لا تظهر هذه الشاشة أصلاً في
/// أي تنقل إلا لمستخدم يملك دوراً إدارياً فعلياً (انظر شرط الدخول في
/// settings_screen.dart)، وحتى داخلها كل إجراء يمر عبر GlobalAdminManager
/// الذي يرفض أي عملية تتجاوز صلاحية المستخدم الحالي.
/// =============================================================
library lifex_ai.screens.admin_dashboard_screen;

import 'package:flutter/material.dart';

import '../core/admin/admin_manager.dart';
import '../core/admin/admin_permissions.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key, required this.currentUserLifexId});

  /// معرّف Lifex-ID للمستخدم الحالي — يُستخدم لتحديد ما يُعرض وما يُسمح
  /// بفعله في هذه الشاشة تحديداً.
  final String currentUserLifexId;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _admin = GlobalAdminManager.instance;
  final _targetIdController = TextEditingController();
  String? _statusMessageAr;

  @override
  void dispose() {
    _targetIdController.dispose();
    super.dispose();
  }

  void _showStatus(String messageAr) {
    setState(() => _statusMessageAr = messageAr);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(messageAr)));
  }

  void _grant(GlobalAdminRole role) {
    final targetId = _targetIdController.text.trim();
    if (targetId.isEmpty) {
      _showStatus('أدخل معرّف Lifex-ID للمستخدم أولاً.');
      return;
    }
    final result = _admin.grantRole(
      granterLifexId: widget.currentUserLifexId,
      targetLifexId: targetId,
      role: role,
    );
    _showStatus(result.messageAr);
  }

  void _revoke() {
    final targetId = _targetIdController.text.trim();
    if (targetId.isEmpty) {
      _showStatus('أدخل معرّف Lifex-ID للمستخدم أولاً.');
      return;
    }
    final result = _admin.revokeRole(
      granterLifexId: widget.currentUserLifexId,
      targetLifexId: targetId,
    );
    _showStatus(result.messageAr);
  }

  void _toggleEvent(String key, bool value) {
    final result = _admin.setEventToggle(
      actorLifexId: widget.currentUserLifexId,
      eventKey: key,
      enabled: value,
    );
    _showStatus(result.messageAr);
    setState(() {}); // لإعادة قراءة القيمة الفعلية من المدير بعد الرفض/القبول
  }

  @override
  Widget build(BuildContext context) {
    final myRole = _admin.roleOf(widget.currentUserLifexId);
    final canGrantAdmin =
        _admin.hasPermission(widget.currentUserLifexId, GlobalAdminPermission.grantAdminRole);
    final canGrantModerator =
        _admin.hasPermission(widget.currentUserLifexId, GlobalAdminPermission.grantModeratorRole);
    final canManageToggles = _admin.hasPermission(
      widget.currentUserLifexId,
      GlobalAdminPermission.manageSystemEventToggles,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('لوحة تحكم الأدمن')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: const Text('دورك الحالي'),
              subtitle: Text(_roleLabelAr(myRole)),
            ),
          ),
          const SizedBox(height: 16),
          if (canGrantAdmin || canGrantModerator) ...[
            Text('إدارة أدوار المستخدمين', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _targetIdController,
              decoration: const InputDecoration(
                labelText: 'معرّف Lifex-ID للمستخدم المستهدف',
                border: OutlineInputBorder(),
                hintText: 'مثال: LFX-482913',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (canGrantAdmin)
                  FilledButton.icon(
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: const Text('منح دور أدمن'),
                    onPressed: () => _grant(GlobalAdminRole.admin),
                  ),
                if (canGrantModerator)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.shield_outlined),
                    label: const Text('منح دور مشرف'),
                    onPressed: () => _grant(GlobalAdminRole.moderator),
                  ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.remove_moderator_outlined),
                  label: const Text('سحب الدور'),
                  onPressed: _revoke,
                ),
              ],
            ),
            const Divider(height: 32),
          ],
          if (canManageToggles) ...[
            Text('مفاتيح الأحداث الدقيقة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text(
              'تفعيل أو تعطيل ميزات على مستوى النظام كاملاً دون الحاجة '
              'لتحديث التطبيق.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ..._admin.allEventToggles.entries.map(
              (entry) => SwitchListTile(
                title: Text(_eventLabelAr(entry.key)),
                value: entry.value,
                onChanged: (value) => _toggleEvent(entry.key, value),
              ),
            ),
          ],
          if (_statusMessageAr != null) ...[
            const SizedBox(height: 16),
            Text(_statusMessageAr!, style: const TextStyle(fontSize: 13)),
          ],
        ],
      ),
    );
  }

  String _roleLabelAr(GlobalAdminRole role) {
    switch (role) {
      case GlobalAdminRole.owner:
        return 'المالك المؤسس';
      case GlobalAdminRole.admin:
        return 'أدمن';
      case GlobalAdminRole.moderator:
        return 'مشرف';
      case GlobalAdminRole.none:
        return 'مستخدم عادي';
    }
  }

  String _eventLabelAr(String key) {
    const labels = {
      'blood_network_flash_alerts_enabled': 'تنبيهات شبكة الدم الفورية',
      'emergency_silent_light_mode_enabled': 'وضع الطوارئ الصامت (ضوء بدل صوت)',
      'ai_gateway_enabled': 'بوابة الذكاء الاصطناعي الموحّدة',
      'remote_health_camera_monitoring_enabled': 'المراقبة الصحية عن بُعد بالكاميرا',
    };
    return labels[key] ?? key;
  }
}
