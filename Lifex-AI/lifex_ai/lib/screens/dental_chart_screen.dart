/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: dental_chart_screen.dart
/// مخطط أسنان على مستوى السن.
/// =============================================================
library lifex_ai.screens.dental_chart_screen;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/dental/dental_chart.dart';
import '../features/network_box/profile_box_store.dart';
import '../features/profile/active_profile_controller.dart';
import '../widgets/honesty_banner.dart';

class DentalChartScreen extends StatelessWidget {
  const DentalChartScreen({super.key});

  static const _key = 'dentalChart';

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveProfileController>(
      builder: (context, controller, _) {
        final profile = controller.activeProfile;
        if (profile == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('مخطط الأسنان')),
            body: const Center(child: Text('لا يوجد ملف صحي نشط.')),
          );
        }
        final store = ProfileBoxStore(profile);
        final chart = DentalChart.fromJson(store.map(_key));
        return Scaffold(
          appBar: AppBar(title: const Text('مخطط الأسنان')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const HonestyBanner(
                messageAr:
                    'ملاحظات على مستوى السن يكتبها المستخدم أو طبيبه. ليست تشخيص أشعة.',
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tooth in DentalChart.fdiAdult)
                    ActionChip(
                      label: Text('$tooth'),
                      avatar: chart.noteFor(tooth).isEmpty
                          ? null
                          : const Icon(Icons.notes, size: 16),
                      onPressed: () async {
                        final field =
                            TextEditingController(text: chart.noteFor(tooth));
                        final saved = await showDialog<String>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('السن $tooth'),
                            content: TextField(
                              controller: field,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'ملاحظة أو خطة',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('إلغاء'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.pop(context, field.text),
                                child: const Text('حفظ'),
                              ),
                            ],
                          ),
                        );
                        field.dispose();
                        if (saved == null) return;
                        chart.setNote(tooth, saved);
                        store.setMap(_key, chart.toJson());
                        controller.saveActiveProfileChanges();
                      },
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
