/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: care_order_screen.dart
/// طلب مخبر أو أشعة ثم نتيجة للطبيب. ليست قراءة آلية.
/// =============================================================
library lifex_ai.screens.care_order_screen;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/health_event_manager.dart';
import '../features/network_box/profile_box_store.dart';
import '../features/profile/active_profile_controller.dart';
import '../widgets/honesty_banner.dart';

class CareOrderScreen extends StatefulWidget {
  const CareOrderScreen({
    super.key,
    required this.titleAr,
    required this.unitType,
    required this.introAr,
    required this.event,
  });

  final String titleAr;
  final String unitType;
  final String introAr;
  final HealthEventType event;

  factory CareOrderScreen.lab() => const CareOrderScreen(
        titleAr: 'المخابر',
        unitType: 'lab',
        introAr:
            'طلب إلكتروني من الطبيب إلى المخبر ثم النتيجة تعود للطبيب. المريض يحضر مرة واحدة.',
        event: HealthEventType.labResultReceived,
      );

  factory CareOrderScreen.imaging() => const CareOrderScreen(
        titleAr: 'الأشعة',
        unitType: 'imaging',
        introAr:
            'أرشيف المريض على نفس الخيط. ليست قراءة إشعاعية من Lifex. التفسير للطبيب.',
        event: HealthEventType.imagingResultReceived,
      );

  @override
  State<CareOrderScreen> createState() => _CareOrderScreenState();
}

class _CareOrderScreenState extends State<CareOrderScreen> {
  final _summary = TextEditingController();
  final _result = TextEditingController();

  @override
  void dispose() {
    _summary.dispose();
    _result.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveProfileController>(
      builder: (context, controller, _) {
        final profile = controller.activeProfile;
        if (profile == null) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.titleAr)),
            body: const Center(child: Text('لا يوجد ملف صحي نشط.')),
          );
        }
        final store = ProfileBoxStore(profile);
        final orders = store
            .list(BoxKeys.careOrders)
            .where((item) => item['unitType'] == widget.unitType)
            .toList();
        return Scaffold(
          appBar: AppBar(title: Text(widget.titleAr)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              HonestyBanner(messageAr: widget.introAr),
              TextField(
                controller: _summary,
                decoration:
                    const InputDecoration(labelText: 'نص الطلب من الطبيب'),
              ),
              FilledButton(
                onPressed: () {
                  if (_summary.text.trim().isEmpty) return;
                  store.add(BoxKeys.careOrders, {
                    'title': _summary.text.trim(),
                    'detail': 'requested',
                    'unitType': widget.unitType,
                    'status': 'requested',
                    'resultAr': '',
                  });
                  controller.saveActiveProfileChanges();
                  _summary.clear();
                },
                child: const Text('إنشاء طلب'),
              ),
              for (var i = 0; i < orders.length; i++)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(orders[i]['title']?.toString() ?? ''),
                        Text('الحالة: ${orders[i]['status']}'),
                        if ((orders[i]['resultAr'] as String?)?.isNotEmpty ==
                            true)
                          Text(orders[i]['resultAr'].toString()),
                        if (orders[i]['status'] != 'ready') ...[
                          TextField(
                            controller: _result,
                            decoration: const InputDecoration(
                                labelText: 'النتيجة للطبيب'),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              final all = store.list(BoxKeys.careOrders);
                              final index = all.indexWhere((item) =>
                                  item['id'] == orders[i]['id']);
                              if (index < 0) return;
                              all[index]['status'] = 'ready';
                              all[index]['resultAr'] = _result.text.trim();
                              all[index]['detail'] = _result.text.trim();
                              store.setList(BoxKeys.careOrders, all);
                              controller.saveActiveProfileChanges();
                              HealthEventManager.instance.emitQuick(
                                widget.event,
                                sourceModule: 'care_order_screen',
                                profileId: profile.profileId,
                              );
                              _result.clear();
                            },
                            child: const Text('حفظ النتيجة'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
