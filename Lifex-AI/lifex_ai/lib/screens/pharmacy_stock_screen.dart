/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: pharmacy_stock_screen.dart
/// مخزون محلي ثم أقرب صنف. لا بيع دم.
/// =============================================================
library lifex_ai.screens.pharmacy_stock_screen;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/doctors/pharmacy_locator.dart';
import '../features/network_box/profile_box_store.dart';
import '../features/profile/active_profile_controller.dart';
import '../widgets/honesty_banner.dart';

class PharmacyStockScreen extends StatefulWidget {
  const PharmacyStockScreen({super.key});

  @override
  State<PharmacyStockScreen> createState() => _PharmacyStockScreenState();
}

class _PharmacyStockScreenState extends State<PharmacyStockScreen> {
  final _query = TextEditingController();
  final _name = TextEditingController();
  final _barcode = TextEditingController();
  final _city = TextEditingController();
  final _km = TextEditingController(text: '1');
  final _qty = TextEditingController(text: '1');

  @override
  void dispose() {
    _query.dispose();
    _name.dispose();
    _barcode.dispose();
    _city.dispose();
    _km.dispose();
    _qty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveProfileController>(
      builder: (context, controller, _) {
        final profile = controller.activeProfile;
        if (profile == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('الصيدلية')),
            body: const Center(child: Text('لا يوجد ملف صحي نشط.')),
          );
        }
        final store = ProfileBoxStore(profile);
        final hits = PharmacyLocator().nearestWithDrug(
          stock: store.list(BoxKeys.pharmacyStock),
          query: _query.text,
          city: _city.text,
        );
        return Scaffold(
          appBar: AppBar(title: const Text('الصيدلية')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const HonestyBanner(
                messageAr:
                    'باركود المخزون ثم أقرب صنف في المدينة التي تدخلها. لا بيع دم. الربط مع صيدلية حقيقية يحتاج خادماً.',
              ),
              TextField(
                controller: _query,
                decoration:
                    const InputDecoration(labelText: 'اسم الدواء أو الباركود'),
                onChanged: (_) => setState(() {}),
              ),
              if (hits.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('لا مخزون مطابق بعد.'),
                )
              else
                for (final item in hits)
                  ListTile(
                    title: Text(item['title']?.toString() ?? ''),
                    subtitle: Text(
                      '${item['city']} · ${item['km']} كم · كمية ${item['quantity']} · ${item['barcode']}',
                    ),
                  ),
              const Divider(),
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'اسم الصنف'),
              ),
              TextField(
                controller: _barcode,
                decoration: const InputDecoration(labelText: 'الباركود'),
              ),
              TextField(
                controller: _city,
                decoration: const InputDecoration(labelText: 'المدينة'),
                onChanged: (_) => setState(() {}),
              ),
              TextField(
                controller: _km,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'المسافة كم (يدوياً)'),
              ),
              TextField(
                controller: _qty,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'الكمية'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {
                  if (_name.text.trim().isEmpty) return;
                  store.add(BoxKeys.pharmacyStock, {
                    'title': _name.text.trim(),
                    'barcode': _barcode.text.trim(),
                    'city': _city.text.trim(),
                    'km': _km.text.trim(),
                    'quantity': _qty.text.trim(),
                  });
                  controller.saveActiveProfileChanges();
                  _name.clear();
                  _barcode.clear();
                },
                child: const Text('إضافة مخزون محلي'),
              ),
            ],
          ),
        );
      },
    );
  }
}
