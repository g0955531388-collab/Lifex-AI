/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: box_unit_screen.dart
/// مساحة عمل لأي وحدة: فروع السيناريو ثم السجلات، وليست قائمة مسطحة.
/// =============================================================
library lifex_ai.screens.box_unit_screen;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/finance/billing_exemption_policy.dart';
import '../features/network_box/box_unit_catalog.dart';
import '../features/network_box/profile_box_store.dart';
import '../features/network_box/unit_branch_catalog.dart';
import '../features/profile/active_profile_controller.dart';
import '../widgets/honesty_banner.dart';
import 'unit_branch_navigator.dart';

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
        final branches = UnitBranchCatalog.forUnit(unit.id);
        return Scaffold(
          appBar: AppBar(title: Text(unit.titleAr)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(unit.subtitleAr,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              HonestyBanner.localAndServer(),
              HonestyBanner.medical(),
              if (unit.id == 'women') ...[
                const SizedBox(height: 12),
                _WomenMembershipCard(store: store, controller: controller),
              ],
              if (unit.id == 'chronicPlans') ...[
                const SizedBox(height: 12),
                _ExemptionCard(),
              ],
              const SizedBox(height: 16),
              Text('أقسام الوحدة',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (branches.isEmpty)
                const Text('لا فروع معرفة لهذه الوحدة بعد.')
              else
                for (final branch in branches)
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Icon(branch.icon)),
                      title: Text(branch.titleAr),
                      subtitle: Text(
                        _branchSubtitle(store, branch),
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => UnitBranchNavigator.open(
                        context,
                        branch,
                        profileId: profile.profileId,
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  String _branchSubtitle(ProfileBoxStore store, UnitBranch branch) {
    final extra = branch.needsServer ? 'ينتظر خادماً للتأكيد الخارجي. ' : '';
    if (!branch.isRecords) {
      return '$extra${branch.subtitleAr}';
    }
    final count = store.list(branch.storageKey!).length;
    return '$extra${branch.subtitleAr}\nسجلات هذا الفرع: $count';
  }
}

class _WomenMembershipCard extends StatelessWidget {
  const _WomenMembershipCard({
    required this.store,
    required this.controller,
  });

  final ProfileBoxStore store;
  final ActiveProfileController controller;

  @override
  Widget build(BuildContext context) {
    final membership = store.stringField(BoxKeys.womenMembership) ?? '';
    String label;
    switch (membership) {
      case 'interested':
        label = 'مهتمة: معرفة عامة بلا ملف متابعة خاص.';
      case 'enrolled':
        label = 'منتسبة: الفروع التالية مربوطة بهذا الملف الصحي.';
      default:
        label = 'اختاري مهتمة للمعرفة، أو منتسبة للمتابعة المرتبطة بالملف.';
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الدخول إلى الوحدة',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(label),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: () {
                    store.setString(BoxKeys.womenMembership, 'interested');
                    controller.saveActiveProfileChanges();
                  },
                  child: const Text('مهتمة'),
                ),
                FilledButton(
                  onPressed: () {
                    store.setString(BoxKeys.womenMembership, 'enrolled');
                    controller.saveActiveProfileChanges();
                  },
                  child: const Text('منتسبة'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExemptionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ActiveProfileController>().activeProfile;
    if (profile == null) return const SizedBox.shrink();
    final result = const BillingExemptionPolicy().evaluate(profile);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.verified_outlined),
        title: const Text('الإعفاء الإنساني'),
        subtitle: Text(
          result.isExempt
              ? 'هذا الملف معفى: بطاقة همم من بلد الحساب أو حالة مزمنة/مستعصية في الملف.'
              : 'إعفاء الهمم يحتاج بطاقة وطنية أو إعاقة أو مرض دائم من بلد صاحب الحساب. الحالة المزمنة النشطة في الملف تُعفي وحدها. التصريح لا يكفي.',
        ),
      ),
    );
  }
}
