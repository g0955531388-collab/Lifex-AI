/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: home_screen.dart
/// المسار: lib/screens/home_screen.dart
/// الوصف: الشاشة الرئيسية — لوحة انطلاق نحو أهم وحدات التطبيق. تستخدم
/// AccessibleActionButton لكل عنصر تفاعلي لضمان توافق كامل مع قارئ
/// الشاشة (TalkBack/VoiceOver)، وليس فقط الشكل البصري.
/// =============================================================
library lifex_ai.screens.home_screen;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/trial_manager.dart';
import '../features/emergency/emergency_manager.dart';
import '../features/finance/billing_exemption_policy.dart';
import '../features/profile/active_profile_controller.dart';
import '../widgets/accessible_widgets.dart';
import 'accessibility_assistant_screen.dart';
import 'ai_agent_screen.dart';
import 'ai_hub_screen.dart';
import 'appointments_screen.dart';
import 'blood_request_screen.dart';
import 'camera_notes_screen.dart';
import 'doctor_directory_screen.dart';
import 'emergency_contacts_screen.dart';
import 'global_health_dashboard_screen.dart';
import 'health_chat_screen.dart';
import 'health_modules_screen.dart';
import 'health_profile_screen.dart';
import 'medications_screen.dart';
import 'pharmacy_stock_screen.dart';
import 'project_box_hub_screen.dart';
import 'settings_screen.dart';
import 'smart_health_questionnaire_screen.dart';
import 'system_search_screen.dart';
import 'voice_control_screen.dart';
import 'wallet_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  bool _allowed(BuildContext context, String unitId) {
    final trial = context.read<TrialManager>();
    final profile = context.read<ActiveProfileController>().activeProfile;
    final exempt = profile != null &&
        const BillingExemptionPolicy().evaluate(profile).isExempt;
    return const SessionAccessPolicy().canOpenUnit(
      unitId,
      expired: trial.emergencyAndBloodOnly,
      feeExempt: exempt,
    );
  }

  void _open(BuildContext context, String unitId, Widget page) {
    if (!_allowed(context, unitId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'انتهت التجربة. تبقى الطوارئ وشبكة الدم والمحفظة والإعدادات. '
            'ذوو الهمم وأصحاب الأمراض المزمنة معفيون.',
          ),
        ),
      );
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveProfileController>(
      builder: (context, profileController, _) {
        final activeProfileId = profileController.activeProfileId;
        final trial = context.watch<TrialManager>();
        final exempt = profileController.activeProfile != null &&
            const BillingExemptionPolicy()
                .evaluate(profileController.activeProfile!)
                .isExempt;
        final expiredLocked = trial.emergencyAndBloodOnly && !exempt;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Lifex-AI'),
            actions: [
              Semantics(
                button: true,
                label: 'بحث المنظومة',
                hint: 'يفتح البحث في الوحدات والمرجع المحلي',
                child: IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'بحث المنظومة',
                  onPressed: () => _open(
                    context,
                    'search',
                    const SystemSearchScreen(),
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: 'الإعدادات',
                hint: 'يفتح شاشة إعدادات التطبيق واللغة والخصوصية',
                child: IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'الإعدادات',
                  onPressed: () {
                    _open(context, 'settings', const SettingsScreen());
                  },
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (expiredLocked)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'انتهت فترة التجربة. تبقى الطوارئ وشبكة الدم والمحفظة '
                          'والإعدادات حتى تُفعَّل الفوترة أو يُسجَّل إعفاء إنساني.',
                        ),
                      ),
                    ),
                  if (expiredLocked) const SizedBox(height: 12),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        AccessibleActionButton(
                          icon: Icons.badge_outlined,
                          label: 'ملفي الصحي',
                          semanticHint: 'يفتح صفحة الملف الصحي الشخصي',
                          onTap: () {
                            _open(
                              context,
                              'profile',
                              HealthProfileScreen(
                                profile: profileController.activeProfile,
                              ),
                            );
                          },
                        ),
                        AccessibleActionButton(
                          icon: Icons.assignment_outlined,
                          label: 'الاستبيان الصحي',
                          semanticHint:
                              'يفتح الاستبيان الصحي الموسع لتسجيل بياناتك وحفظها في ملفك',
                          onTap: activeProfileId == null
                              ? null
                              : () {
                                  _open(
                                    context,
                                    'profile',
                                    const SmartHealthQuestionnaireScreen(),
                                  );
                                },
                        ),
                        AccessibleActionButton(
                          icon: Icons.medication_outlined,
                          label: 'أدويتي',
                          semanticHint: 'يفتح سجل الأدوية الشخصي والمرجع العام',
                          onTap: activeProfileId == null
                              ? null
                              : () {
                                  _open(
                                    context,
                                    'medications',
                                    MedicationsScreen(
                                      profileId: activeProfileId,
                                    ),
                                  );
                                },
                        ),
                        AccessibleActionButton(
                          icon: Icons.calendar_month_outlined,
                          label: 'مواعيدي',
                          semanticHint: 'يفتح قائمة المواعيد الطبية المحفوظة',
                          onTap: activeProfileId == null
                              ? null
                              : () {
                                  _open(
                                    context,
                                    'appointments',
                                    const AppointmentsScreen(),
                                  );
                                },
                        ),
                        AccessibleActionButton(
                          icon: Icons.mic_none_outlined,
                          label: 'التحكم الصوتي',
                          semanticHint:
                              'يستمع إلى أوامرك العربية ويفتح الوظيفة المطلوبة',
                          onTap: activeProfileId == null
                              ? null
                              : () {
                                  _open(
                                    context,
                                    'voice',
                                    const VoiceControlScreen(),
                                  );
                                },
                        ),
                        AccessibleActionButton(
                          icon: Icons.visibility_outlined,
                          label: 'المساعد البصري',
                          semanticHint:
                              'يفتح أدوات مساعدة المكفوفين وضعاف البصر',
                          onTap: activeProfileId == null
                              ? null
                              : () {
                                  _open(
                                    context,
                                    'accessibility',
                                    AccessibilityAssistantScreen(
                                      profileId: activeProfileId,
                                    ),
                                  );
                                },
                        ),
                        AccessibleActionButton(
                          icon: Icons.inventory_2_outlined,
                          label: 'صندوق المشروع',
                          semanticHint:
                              'يفتح الصندوق الكامل من التكوين حتى آخر يوم بما فيه المقاعد الفارغة',
                          onTap: activeProfileId == null
                              ? null
                              : () {
                                  _open(
                                    context,
                                    'box',
                                    const ProjectBoxHubScreen(),
                                  );
                                },
                        ),
                        AccessibleActionButton(
                          icon: Icons.public_outlined,
                          label: 'منظومة Lifex-AI',
                          semanticHint:
                              'يفتح المركز الموحد لجميع الوحدات الصحية',
                          onTap: activeProfileId == null
                              ? null
                              : () {
                                  _open(
                                    context,
                                    'box',
                                    GlobalHealthDashboardScreen(
                                      profileId: activeProfileId,
                                    ),
                                  );
                                },
                        ),
                        AccessibleActionButton(
                          icon: Icons.chat_bubble_outline,
                          label: 'المحادثة الصحية',
                          semanticHint:
                              'يفتح محادثة صحية تنظيمية ويقرأ الردود صوتيًا',
                          onTap: activeProfileId == null
                              ? null
                              : () {
                                  _open(
                                    context,
                                    'chat',
                                    const HealthChatScreen(),
                                  );
                                },
                        ),
                        AccessibleActionButton(
                          icon: Icons.hub_outlined,
                          label: 'الوحدات الصحية',
                          semanticHint:
                              'يفتح مركز المخابر والدم والتبرعات والمرأة والأسنان والتدريب',
                          onTap: activeProfileId == null
                              ? null
                              : () {
                                  _open(
                                    context,
                                    'modules',
                                    const HealthModulesScreen(),
                                  );
                                },
                        ),
                        AccessibleActionButton(
                          icon: Icons.bloodtype_outlined,
                          label: 'شبكة الدم',
                          semanticHint:
                              'يفتح طلبات الدم للموافقين على هذا الجهاز',
                          onTap: activeProfileId == null
                              ? null
                              : () {
                                  _open(
                                    context,
                                    'blood',
                                    const BloodRequestScreen(),
                                  );
                                },
                        ),
                        AccessibleActionButton(
                          icon: Icons.local_pharmacy_outlined,
                          label: 'الصيدلية',
                          semanticHint:
                              'يفتح المخزون المحلي وأقرب صنف في المدينة المدخلة',
                          onTap: activeProfileId == null
                              ? null
                              : () {
                                  _open(
                                    context,
                                    'pharmacy',
                                    const PharmacyStockScreen(),
                                  );
                                },
                        ),
                        AccessibleActionButton(
                          icon: Icons.medical_services_outlined,
                          label: 'الأطباء',
                          semanticHint:
                              'يفتح دليل الأطباء المحلي مرتباً حسب المسافة المدخلة',
                          onTap: activeProfileId == null
                              ? null
                              : () {
                                  _open(
                                    context,
                                    'doctors',
                                    const DoctorDirectoryScreen(),
                                  );
                                },
                        ),
                        AccessibleActionButton(
                          icon: Icons.camera_alt_outlined,
                          label: 'الكاميرا الذكية',
                          semanticHint:
                              'يلتقط أوراقاً بموافقة ظاهرة دون قراءة آلية مزيفة',
                          onTap: activeProfileId == null
                              ? null
                              : () {
                                  _open(
                                    context,
                                    'camera',
                                    const CameraNotesScreen(),
                                  );
                                },
                        ),
                        AccessibleActionButton(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'محفظتي',
                          semanticHint: 'يفتح المحفظة الرقمية وسجل المعاملات',
                          onTap: activeProfileId == null
                              ? null
                              : () {
                                  _open(
                                    context,
                                    'wallet',
                                    WalletScreen(profileId: activeProfileId),
                                  );
                                },
                        ),
                        AccessibleActionButton(
                          icon: Icons.smart_toy_outlined,
                          label: 'مركز الذكاء الاصطناعي',
                          semanticHint:
                              'يفتح إدارة حسابات محركات الذكاء الاصطناعي '
                              'المرتبطة مثل Gemini وChatGPT وClaude',
                          onTap: activeProfileId == null
                              ? null
                              : () {
                                  _open(
                                    context,
                                    'ai',
                                    AiHubScreen(profileId: activeProfileId),
                                  );
                                },
                        ),
                        AccessibleActionButton(
                          icon: Icons.psychology_outlined,
                          label: 'الوكيل الذكي',
                          semanticHint: 'يفتح وضع الوكيل متعدد الخطوات '
                              'والمحادثة المباشرة مع Lifex-AI',
                          onTap: activeProfileId == null
                              ? null
                              : () {
                                  _open(
                                    context,
                                    'ai',
                                    AiAgentScreen(profileId: activeProfileId),
                                  );
                                },
                        ),
                        AccessibleActionButton(
                          icon: Icons.emergency_outlined,
                          label: 'طوارئ',
                          semanticHint:
                              'يبدأ إجراء تنبيه طوارئ فوري لجهات الثقة، '
                              'اضغط ضغطاً مزدوجاً للتأكيد',
                          isUrgent: true,
                          onTap: () {
                            _showEmergencyConfirmationDialog(
                                context, activeProfileId);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEmergencyConfirmationDialog(
    BuildContext context,
    String? activeProfileId,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد حالة طوارئ'),
        content: const Text(
          'سيتم إبلاغ جهات الثقة المسجَّلة لديك فوراً. هل تريد المتابعة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const EmergencyContactsScreen()),
              );
            },
            child: const Text('جهات الثقة'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final emergencyManager =
                  Provider.of<EmergencyManager>(context, listen: false);

              emergencyManager.triggerEmergency(
                profileId: activeProfileId ?? 'unknown_profile',
                reasonAr: 'تفعيل يدوي من الشاشة الرئيسية بواسطة المستخدم.',
              );

              Navigator.of(dialogContext).pop();

              announceForScreenReader(
                context,
                'تم إرسال تنبيه الطوارئ لجهات الثقة.',
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إرسال تنبيه الطوارئ لجهات الثقة.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('تأكيد الطوارئ'),
          ),
        ],
      ),
    );
  }
}
