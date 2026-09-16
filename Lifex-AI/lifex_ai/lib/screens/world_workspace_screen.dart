/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: world_workspace_screen.dart
/// سحابة، إحصاء، شاشات عامة، لوحة داخلية، تراسل عائلي.
/// =============================================================
library lifex_ai.screens.world_workspace_screen;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/network_box/profile_box_store.dart';
import '../features/network_box/sector_analytics.dart';
import '../features/network_box/unified_booking_service.dart';
import '../features/profile/active_profile_controller.dart';
import '../services/cloud/cloud_sync_manager.dart';
import '../widgets/honesty_banner.dart';

class WorldWorkspaceScreen extends StatelessWidget {
  const WorldWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('العالم والفراغ'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'سحابة'),
              Tab(text: 'إحصاء'),
              Tab(text: 'شاشة عامة'),
              Tab(text: 'لوحة داخلية'),
              Tab(text: 'تراسل'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _CloudTab(),
            _AnalyticsTab(),
            _PublicDisplayTab(),
            _InternalDashboardTab(),
            _FamilyMessagingTab(),
          ],
        ),
      ),
    );
  }
}

class _CloudTab extends StatelessWidget {
  const _CloudTab();

  @override
  Widget build(BuildContext context) {
    final sync = context.watch<CloudSyncManager>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        HonestyBanner(
          messageAr: sync.isEndpointConfigured
              ? 'الخادم مضبوط. المزامنة ترفع الطابور عند الطلب.'
              : 'لا يوجد عنوان خادم عامل. الطابور محلي ولن يُرفع كنتيجة ناجحة.',
        ),
        const SizedBox(height: 12),
        Text('عمليات معلّقة: ${sync.pendingOperationsCount}'),
        const SizedBox(height: 8),
        for (final op in sync.pendingOperations)
          Card(
            child: ListTile(
              title: Text(op.entityType.name),
              subtitle: Text('${op.entityId} — محاولات ${op.retryCount}'),
            ),
          ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: !sync.isEndpointConfigured
              ? null
              : () => sync.syncPendingOperations(),
          child: const Text('مزامنة الآن'),
        ),
      ],
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ActiveProfileController>();
    final profile = controller.activeProfile;
    if (profile == null) {
      return const Center(child: Text('لا يوجد ملف صحي نشط.'));
    }
    final counts = SectorAnalytics.unitCounts(profile);
    final blood = SectorAnalytics.anonymizedBloodTypes(controller.allProfiles);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const HonestyBanner(
          messageAr:
              'الأرقام من هذا الجهاز فقط وبلا أسماء. الإحصاء القطاعي يحتاج مواقع متعددة وخادماً.',
        ),
        const SizedBox(height: 12),
        for (final entry in counts.entries)
          ListTile(
            title: Text(entry.key),
            trailing: Text('${entry.value}'),
          ),
        const Divider(),
        const Text('زمر الدم على الجهاز'),
        for (final entry in blood.entries)
          ListTile(
            title: Text(entry.key),
            trailing: Text('${entry.value}'),
          ),
      ],
    );
  }
}

class _PublicDisplayTab extends StatelessWidget {
  const _PublicDisplayTab();

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ActiveProfileController>().activeProfile;
    if (profile == null) {
      return const Center(child: Text('لا يوجد ملف صحي نشط.'));
    }
    final queue = UnifiedBookingService(ProfileBoxStore(profile)).publicQueue();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const HonestyBanner(
          messageAr:
              'شاشة انتظار بلا أسماء مرضى. الحملات العامة تحتاج شبكة مواقع.',
        ),
        const SizedBox(height: 12),
        if (queue.isEmpty)
          const Text('لا أرقام دور محلية.')
        else
          for (final item in queue)
            Card(
              child: ListTile(
                title: Text(item['code'] ?? ''),
                subtitle: Text('${item['unit']} — ${item['time']}'),
              ),
            ),
      ],
    );
  }
}

class _InternalDashboardTab extends StatelessWidget {
  const _InternalDashboardTab();

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ActiveProfileController>().activeProfile;
    if (profile == null) {
      return const Center(child: Text('لا يوجد ملف صحي نشط.'));
    }
    final counts = SectorAnalytics.unitCounts(profile);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const HonestyBanner(
          messageAr:
              'لوحة موظفين من سجلات هذا الجهاز. لوحة المستشفى الكاملة تحتاج حساب جهة وخادماً.',
        ),
        const SizedBox(height: 12),
        for (final entry in counts.entries)
          Card(
            child: ListTile(
              title: Text(entry.key),
              trailing: Text('${entry.value}'),
            ),
          ),
      ],
    );
  }
}

class _FamilyMessagingTab extends StatefulWidget {
  const _FamilyMessagingTab();

  @override
  State<_FamilyMessagingTab> createState() => _FamilyMessagingTabState();
}

class _FamilyMessagingTabState extends State<_FamilyMessagingTab> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveProfileController>(
      builder: (context, controller, _) {
        final profile = controller.activeProfile;
        if (profile == null) {
          return const Center(child: Text('لا يوجد ملف صحي نشط.'));
        }
        final store = ProfileBoxStore(profile);
        final messages = store.list(BoxKeys.familyMessages);
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: HonestyBanner(
                messageAr:
                    'التراسل هنا بين ملفات العائلة على هذا الجهاز. الطبيب والمستشفى يحتاجان خادماً. الهوية المستعارة تُستخدم خارج الدائرة الطبية.',
              ),
            ),
            Expanded(
              child: messages.isEmpty
                  ? const Center(child: Text('لا رسائل عائلية بعد.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: messages.length,
                      itemBuilder: (_, index) {
                        final message = messages[index];
                        return Align(
                          alignment: message['fromId'] == profile.profileId
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                '${message['fromName']}: ${message['text']}',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      decoration: const InputDecoration(
                        labelText: 'رسالة للعائلة على هذا الجهاز',
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'إرسال',
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final text = _input.text.trim();
                      if (text.isEmpty) return;
                      store.add(BoxKeys.familyMessages, {
                        'fromId': profile.profileId,
                        'fromName': profile.fullName,
                        'text': text,
                      });
                      controller.saveActiveProfileChanges();
                      _input.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
