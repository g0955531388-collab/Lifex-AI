/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: blood_request_screen.dart
/// المسار: lib/screens/blood_request_screen.dart
/// الوصف: طلب دم محلي. التنبيه الفلاش يصل فقط للمتبرعين الموافقين في
/// ملفاتهم على هذا الجهاز. الإرسال الشبكي يحتاج خادماً لاحقاً.
/// =============================================================
library lifex_ai.screens.blood_request_screen;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/blood_network/blood_request_engine.dart';
import '../features/blood_network/donor_eligibility_filter.dart';
import '../features/blood_network/donor_history_registry.dart';
import '../features/blood_network/flash_alert_notifier.dart';
import '../features/blood_network/geo_expansion_dispatcher.dart';
import '../features/blood_network/profile_donor_directory.dart';
import '../features/hospital/hospital_blood_bank.dart';
import '../features/profile/active_profile_controller.dart';
import '../features/voice/voice_engine.dart';

class BloodRequestScreen extends StatefulWidget {
  const BloodRequestScreen({super.key, this.preferType});

  /// فصيلة من أمر صوتي أو بحث، إن وُجدت. لا تُرسل الطلب تلقائياً.
  final BloodTypeSimple? preferType;

  @override
  State<BloodRequestScreen> createState() => _BloodRequestScreenState();
}

class _BloodRequestScreenState extends State<BloodRequestScreen> {
  late BloodTypeSimple _type = widget.preferType ?? BloodTypeSimple.oPositive;
  BloodRequestUrgency _urgency = BloodRequestUrgency.urgent;
  String _statusAr = 'لم يُرسل أي طلب بعد.';

  Future<void> _send() async {
    final profiles = context.read<ActiveProfileController>();
    final engine = BloodRequestEngine(
      eligibilityFilter: DonorEligibilityFilter(
        historyRegistry: DonorHistoryRegistry(),
        donorDirectory: () =>
            ProfileDonorDirectory.fromProfiles(profiles.allProfiles),
      ),
      geoExpansionDispatcher: GeoExpansionDispatcher(),
      alertNotifier: FlashAlertNotifier(
        sendFunction: (lifexId, message) async {
          await VoiceEngine.instance.speak(message);
          return true;
        },
      ),
    );

    final request = engine.createRequest(
      bloodType: _type,
      unitsNeeded: 1,
      urgency: _urgency,
      latitude: 0,
      longitude: 0,
    );

    final eligible = engine.eligibilityFilter.findEligibleDonors(
      bloodType: _type,
      centerLatitude: 0,
      centerLongitude: 0,
      radiusKm: 50,
      ignoreDistance: true,
    );

    setState(() {
      _statusAr = eligible.isEmpty
          ? 'لا يوجد على هذا الجهاز متبرع موافق وفصيلته مطابقة. '
              'لن يُرسل فلاش عام. الربط مع متبرعين خارجيين يحتاج خادماً.'
          : 'طُلب ${request.requestId}. وصل التنبيه إلى ${eligible.length} '
              'متبرع موافق فقط. من أوقف الاستقبال في ملفه لم يُنبَّه.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلب دم')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'التنبيه الفلاش يصل فقط إلى من يقبل استقبال طلبات التبرع '
            'في ملفه الصحي. التبرع مجاني، وهذا ليس تشخيصاً.',
            style: TextStyle(color: Colors.orange),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<BloodTypeSimple>(
            value: _type,
            decoration: const InputDecoration(labelText: 'الفصيلة المطلوبة'),
            items: BloodTypeSimple.values
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.name),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _type = value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<BloodRequestUrgency>(
            value: _urgency,
            decoration: const InputDecoration(labelText: 'درجة الإلحاح'),
            items: const [
              DropdownMenuItem(
                  value: BloodRequestUrgency.routine, child: Text('عادي')),
              DropdownMenuItem(
                  value: BloodRequestUrgency.urgent, child: Text('عاجل')),
              DropdownMenuItem(
                  value: BloodRequestUrgency.critical, child: Text('حرج')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _urgency = value);
            },
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _send,
            icon: const Icon(Icons.bloodtype_outlined),
            label: const Text('إرسال تنبيه للمتبرعين الموافقين'),
          ),
          const SizedBox(height: 16),
          Text(_statusAr),
        ],
      ),
    );
  }
}
