/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: box_unit_screen.dart
/// مساحة عمل لأي وحدة سجلات في الصندوق.
/// =============================================================
library lifex_ai.screens.box_unit_screen;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/network_box/box_unit_catalog.dart';
import '../features/network_box/profile_box_store.dart';
import '../features/profile/active_profile_controller.dart';
import '../widgets/honesty_banner.dart';

class BoxUnitScreen extends StatelessWidget {
  const BoxUnitScreen({super.key, required this.unit});

  final BoxUnit unit;

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveProfileController>(
      builder: (context, controller, _) {
        final profile = controller.activeProfile;
        if (profile == null) {
          return Scaffold(
            appBar: AppBar(title: Text(unit.titleAr)),
            body: const Center(child: Text('لا يوجد ملف صحي نشط.')),
          );
        }
        final store = ProfileBoxStore(profile);
        final records = store.list(unit.storageKey);
        return Scaffold(
          appBar: AppBar(title: Text(unit.titleAr)),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addRecord(context, controller, store),
            icon: const Icon(Icons.add),
            label: const Text('إضافة سجل'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Text(unit.subtitleAr,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              HonestyBanner.localAndServer(),
              HonestyBanner.medical(),
              const SizedBox(height: 12),
              if (records.isEmpty)
                const Text('لا توجد سجلات بعد. أضف أول سجل من الزر أدناه.')
              else
                for (var i = 0; i < records.length; i++)
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Icon(unit.icon)),
                      title: Text(records[i]['title']?.toString() ?? ''),
                      subtitle: Text(records[i]['detail']?.toString() ?? ''),
                      trailing: IconButton(
                        tooltip: 'حذف السجل',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          store.removeAt(unit.storageKey, i);
                          controller.saveActiveProfileChanges();
                        },
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addRecord(
    BuildContext context,
    ActiveProfileController controller,
    ProfileBoxStore store,
  ) async {
    final title = TextEditingController();
    final detail = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(unit.titleAr),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                autofocus: true,
                decoration: InputDecoration(labelText: unit.primaryLabelAr),
              ),
              TextField(
                controller: detail,
                maxLines: 3,
                decoration: InputDecoration(labelText: unit.detailLabelAr),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    final heading = title.text.trim();
    final note = detail.text.trim();
    title.dispose();
    detail.dispose();
    if (saved != true || heading.isEmpty) return;
    store.add(unit.storageKey, {
      'title': heading,
      'detail': note.isEmpty ? 'بدون تفاصيل' : note,
    });
    controller.saveActiveProfileChanges();
  }
}
