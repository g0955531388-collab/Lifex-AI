/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: women_cycle_screen.dart
/// دورة وحمل اختيارية على الملف الأنثوي فقط.
/// =============================================================
library lifex_ai.screens.women_cycle_screen;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/network_box/profile_box_store.dart';
import '../features/profile/active_profile_controller.dart';
import '../features/women_health/female_cycle_tracker.dart';
import '../widgets/honesty_banner.dart';

class WomenCycleScreen extends StatelessWidget {
  const WomenCycleScreen({super.key});

  static const _enabledKey = 'cycleTrackingEnabled';
  static const _startsKey = 'cycleStarts';
  static const _lmpKey = 'lastMenstrualPeriod';

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveProfileController>(
      builder: (context, controller, _) {
        final profile = controller.activeProfile;
        if (profile == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('دورة وحمل')),
            body: const Center(child: Text('لا يوجد ملف صحي نشط.')),
          );
        }
        final store = ProfileBoxStore(profile);
        final enabled = store.stringField(_enabledKey) == 'true';
        final starts = store
            .list(_startsKey)
            .map((item) => DateTime.tryParse(item['date']?.toString() ?? ''))
            .whereType<DateTime>()
            .toList();
        final tracker = FemaleCycleTracker(profileId: profile.profileId);
        if (enabled) tracker.enableTracking();
        for (final start in starts) {
          tracker.logCycleStart(start);
        }
        final prediction = tracker.predictNextCycle();
        final lmpRaw = store.stringField(_lmpKey);
        final lmp = lmpRaw == null ? null : DateTime.tryParse(lmpRaw);
        final due = lmp == null
            ? null
            : FemaleCycleTracker.estimatedDueFromLmp(lmp);
        return Scaffold(
          appBar: AppBar(title: const Text('دورة وحمل')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const HonestyBanner(
                messageAr:
                    'هذه الوحدة اختيارية وعلى هذا الملف فقط. التقدير تقريبي وليس وسيلة منع حمل.',
              ),
              SwitchListTile(
                title: const Text('تفعيل التتبّع'),
                value: enabled,
                onChanged: (value) {
                  store.setString(_enabledKey, value ? 'true' : 'false');
                  controller.saveActiveProfileChanges();
                },
              ),
              if (enabled) ...[
                FilledButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 400)),
                      lastDate: DateTime.now(),
                    );
                    if (picked == null || !context.mounted) return;
                    store.add(_startsKey, {'date': picked.toIso8601String()});
                    controller.saveActiveProfileChanges();
                  },
                  child: const Text('تسجيل بداية دورة'),
                ),
                const SizedBox(height: 12),
                Text('دورات مسجّلة: ${starts.length}'),
                if (prediction.estimatedNextCycleStart != null)
                  Text(
                    'تقدير البداية التالية: ${prediction.estimatedNextCycleStart!.year}/'
                    '${prediction.estimatedNextCycleStart!.month}/'
                    '${prediction.estimatedNextCycleStart!.day}',
                  ),
                Text(prediction.disclaimer),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: lmp ?? DateTime.now(),
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 320)),
                      lastDate: DateTime.now(),
                    );
                    if (picked == null || !context.mounted) return;
                    store.setString(_lmpKey, picked.toIso8601String());
                    controller.saveActiveProfileChanges();
                  },
                  child: const Text('تسجيل آخر دورة لتقدير الحمل'),
                ),
                if (due != null)
                  Text(
                    'تقدير موعد الولادة: ${due.year}/${due.month}/${due.day}. '
                    'تقريبي وليس موعداً طبياً مؤكداً.',
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}
