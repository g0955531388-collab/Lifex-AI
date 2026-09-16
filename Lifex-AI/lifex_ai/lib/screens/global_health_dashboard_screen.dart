/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: global_health_dashboard_screen.dart
/// المسار: lib/screens/global_health_dashboard_screen.dart
/// الوصف: المركز الموحد. كل مقعد يفتح مساحة عمل محلية صادقة.
/// =============================================================
library lifex_ai.screens.global_health_dashboard_screen;

import 'package:flutter/material.dart';

import '../features/network_box/box_unit_catalog.dart';
import 'accessibility_assistant_screen.dart';
import 'appointments_screen.dart';
import 'blood_request_screen.dart';
import 'booking_workspace_screen.dart';
import 'box_unit_screen.dart';
import 'emergency_contacts_screen.dart';
import 'health_chat_screen.dart';
import 'health_modules_screen.dart';
import 'identity_workspace_screen.dart';
import 'medications_screen.dart';
import 'medical_reference_screen.dart';
import 'project_box_hub_screen.dart';
import 'protection_workspace_screen.dart';
import 'smart_health_questionnaire_screen.dart';
import 'voice_control_screen.dart';
import 'world_workspace_screen.dart';

class GlobalHealthDashboardScreen extends StatelessWidget {
  const GlobalHealthDashboardScreen({super.key, required this.profileId});

  final String profileId;

  @override
  Widget build(BuildContext context) {
    final groups = [
      (
        'النواة والملف الصحي',
        Icons.person_outline,
        [
          _Module(
              'صندوق المشروع أ',
              'من التكوين حتى آخر يوم بكل المقاعد',
              Icons.inventory_2_outlined,
              const ProjectBoxHubScreen()),
          _Module(
              'الهوية من الصفر',
              'هوية حقيقية ومستعارة وملاحظات التكوين',
              Icons.badge_outlined,
              const IdentityWorkspaceScreen()),
          _Module(
              'الملف الصحي الحي',
              'الاستبيان والتاريخ والحساسية',
              Icons.assignment_outlined,
              const SmartHealthQuestionnaireScreen()),
          _Module('الأدوية', 'الجرعات والمواعيد وسجل الالتزام',
              Icons.medication_outlined, MedicationsScreen(profileId: profileId)),
          _Module('المواعيد', 'مواعيد شخصية على الجهاز',
              Icons.event_available_outlined, const AppointmentsScreen()),
        ]
      ),
      (
        'الوصول والصوت والرؤية',
        Icons.record_voice_over_outlined,
        [
          _Module('التحكم الصوتي', 'تنفيذ أوامر عربية والتنقل بالصوت',
              Icons.mic_none_outlined, const VoiceControlScreen()),
          _Module(
              'المساعد البصري',
              'الكاميرا وقراءة النصوص والنطق',
              Icons.visibility_outlined,
              AccessibilityAssistantScreen(profileId: profileId)),
          _Module('المحادثة الصحية', 'أسئلة تنظيمية مع قراءة الرد صوتيًا',
              Icons.chat_outlined, const HealthChatScreen()),
        ]
      ),
      (
        'الطوارئ والمجتمع',
        Icons.health_and_safety_outlined,
        [
          _Module('الطوارئ وجهات الثقة', 'إدارة جهات الثقة ومستويات الصلاحية',
              Icons.sos_outlined, const EmergencyContactsScreen()),
          _Module(
              'الوحدات الصحية',
              'المخبر والدم والتبرعات والمرأة والأسنان والتأهيل',
              Icons.hub_outlined,
              const HealthModulesScreen()),
          _Module(
              'مرجع العلامات البصرية',
              'معاني علامات الوجه والجلد من أرشيف الكاميرا الذكية',
              Icons.visibility_outlined,
              const MedicalReferenceScreen(
                  kind: MedicalReferenceKind.cameraSigns)),
          _Module(
              'موسوعة الحالات والأدوية',
              'بحث مرجعي في الحالات ومعايير النمو ودليل الأدوية',
              Icons.menu_book_outlined,
              const MedicalReferenceScreen(
                  kind: MedicalReferenceKind.conditions)),
        ]
      ),
      (
        'الخدمات الصحية المتخصصة',
        Icons.local_hospital_outlined,
        [
          _Module(
              'الأطباء',
              'دليل محلي بانتظار خادم الجهة',
              Icons.medical_information_outlined,
              const BoxUnitScreen(unit: BoxUnitCatalog.doctors)),
          _Module(
              'المرضى',
              'سجلات رعاية محلية',
              Icons.personal_injury_outlined,
              const BoxUnitScreen(unit: BoxUnitCatalog.patients)),
          _Module(
              'المستشفى',
              'دخول وتحويلات محلية',
              Icons.local_hospital_outlined,
              const BoxUnitScreen(unit: BoxUnitCatalog.hospital)),
          _Module(
              'المخابر والتحاليل',
              'طلبات ونتائج يضيفها المستخدم',
              Icons.science_outlined,
              const BoxUnitScreen(unit: BoxUnitCatalog.labs)),
          _Module(
              'الصيدليات والوصفات',
              'صرف مرتبط بسجل أدويتك',
              Icons.local_pharmacy_outlined,
              const BoxUnitScreen(unit: BoxUnitCatalog.pharmacy)),
          _Module(
              'التصوير والأشعة',
              'أرشيف مواعيد وتقارير محلية',
              Icons.image_search_outlined,
              const BoxUnitScreen(unit: BoxUnitCatalog.radiology)),
          _Module(
              'الأسنان',
              'خطة علاج سنية',
              Icons.medical_services_outlined,
              const BoxUnitScreen(unit: BoxUnitCatalog.dental)),
          _Module(
              'الحمل ورعاية الإناث',
              'من التكوين حتى ما بعد الولادة',
              Icons.pregnant_woman_outlined,
              const BoxUnitScreen(unit: BoxUnitCatalog.women)),
          _Module(
              'الحجز والأكواد',
              'مسودة حجز ورمز تحقق محلي',
              Icons.qr_code_2,
              const BookingWorkspaceScreen()),
        ]
      ),
      (
        'الربط والإنسانية',
        Icons.public_outlined,
        [
          _Module(
              'الحماية والمراقبة والأجهزة',
              'فقدان جهاز وطاقة وربط عائلي',
              Icons.shield_outlined,
              const ProtectionWorkspaceScreen()),
          _Module(
              'العالم: سحابة وإحصاء وشاشات وتراسل',
              'طابور محلي بلا نجاح وهمي',
              Icons.public_outlined,
              const WorldWorkspaceScreen()),
          _Module(
              'شبكة الدم',
              'طلبات للموافقين على هذا الجهاز',
              Icons.bloodtype_outlined,
              const BloodRequestScreen()),
          _Module(
              'التبرعات',
              'دعم مالي أو خدمي أو عيني',
              Icons.volunteer_activism_outlined,
              const BoxUnitScreen(unit: BoxUnitCatalog.donations)),
          _Module(
              'التأهيل والتعليم',
              'دورات وخطط تطوير',
              Icons.school_outlined,
              const BoxUnitScreen(unit: BoxUnitCatalog.education)),
          _Module(
              'الرعاية المزمنة والهمم',
              'خطط طويلة وإعفاء',
              Icons.accessibility_new_outlined,
              const BoxUnitScreen(unit: BoxUnitCatalog.chronicPlans)),
        ]
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('منظومة Lifex-AI')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('المركز الموحد',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text(
              'كل مقعد مفتوح. المحلية تُحفظ هنا. المؤسسية تبقى صادقة: تحتاج خادماً قبل أي ربط خارجي.'),
          const SizedBox(height: 16),
          for (final group in groups) ...[
            Row(children: [
              Icon(group.$2),
              const SizedBox(width: 8),
              Text(group.$1,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold))
            ]),
            const SizedBox(height: 8),
            ...group.$3.map((module) => Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(module.icon)),
                    title: Text(module.title),
                    subtitle: Text(module.description),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => module.screen)),
                  ),
                )),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _Module {
  const _Module(this.title, this.description, this.icon, this.screen);
  final String title;
  final String description;
  final IconData icon;
  final Widget screen;
}
