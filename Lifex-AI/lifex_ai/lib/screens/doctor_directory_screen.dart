/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: doctor_directory_screen.dart
/// اختصاص ثم الأقرب فالأبعد بمسافة يدخلها المستخدم.
/// =============================================================
library lifex_ai.screens.doctor_directory_screen;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/doctors/doctor_directory.dart';
import '../features/network_box/profile_box_store.dart';
import '../features/profile/active_profile_controller.dart';
import '../widgets/honesty_banner.dart';

class DoctorDirectoryScreen extends StatefulWidget {
  const DoctorDirectoryScreen({super.key});

  @override
  State<DoctorDirectoryScreen> createState() => _DoctorDirectoryScreenState();
}

class _DoctorDirectoryScreenState extends State<DoctorDirectoryScreen> {
  String? _filter;
  String _specialty = DoctorDirectory.specialtiesAr.first;
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _km = TextEditingController(text: '1');

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _km.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveProfileController>(
      builder: (context, controller, _) {
        final profile = controller.activeProfile;
        if (profile == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('الأطباء')),
            body: const Center(child: Text('لا يوجد ملف صحي نشط.')),
          );
        }
        final store = ProfileBoxStore(profile);
        final doctors = DoctorDirectory().nearestFirst(
          store.list(BoxKeys.doctors),
          specialty: _filter,
        );
        return Scaffold(
          appBar: AppBar(title: const Text('الأطباء')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const HonestyBanner(
                messageAr:
                    'الصفحة العامة: اسم واختصاص وتواصل. بلا أسماء مرضى. الموقع الآلي يحتاج إذناً وخادماً؛ المسافة هنا يدوية.',
              ),
              DropdownButtonFormField<String>(
                value: _filter ?? '__all__',
                items: [
                  const DropdownMenuItem(value: '__all__', child: Text('الكل')),
                  ...DoctorDirectory.specialtiesAr.map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  ),
                ],
                onChanged: (value) => setState(
                  () => _filter = value == '__all__' ? null : value,
                ),
                decoration:
                    const InputDecoration(labelText: 'كل الاختصاصات'),
              ),
              for (final doctor in doctors)
                ListTile(
                  title: Text(doctor['title']?.toString() ?? ''),
                  subtitle: Text(
                    '${doctor['detail']} · ${doctor['km'] ?? '—'} كم',
                  ),
                ),
              const Divider(),
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'اسم الطبيب'),
              ),
              DropdownButtonFormField<String>(
                value: _specialty,
                items: DoctorDirectory.specialtiesAr
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _specialty = value);
                },
                decoration: const InputDecoration(labelText: 'الاختصاص'),
              ),
              TextField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'هاتف أو عنوان'),
              ),
              TextField(
                controller: _km,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'المسافة كم'),
              ),
              FilledButton(
                onPressed: () {
                  if (_name.text.trim().isEmpty) return;
                  store.add(BoxKeys.doctors, {
                    'title': _name.text.trim(),
                    'detail': '$_specialty — ${_phone.text.trim()}',
                    'km': _km.text.trim(),
                  });
                  controller.saveActiveProfileChanges();
                  _name.clear();
                  _phone.clear();
                },
                child: const Text('حفظ طبيب محلي'),
              ),
            ],
          ),
        );
      },
    );
  }
}
