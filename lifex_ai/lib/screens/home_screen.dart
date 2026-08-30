/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: home_screen.dart
/// المسار: lib/screens/home_screen.dart
/// الوصف: الشاشة الرئيسية — لوحة انطلاق نحو أهم وحدات التطبيق. تستخدم
/// AccessibleActionButton لكل عنصر تفاعلي لضمان توافق كامل مع قارئ
/// الشاشة (TalkBack/VoiceOver)، وليس فقط الشكل البصري.
///
/// كل شاشة تتطلب معرّف ملف صحي حقيقي (المحفظة، مركز الذكاء الاصطناعي،
/// المساعد البصري) تحصل عليه من ActiveProfileController.activeProfileId
/// الحقيقي — وليس نصاً وهمياً ثابتاً كما كان الحال سابقاً.
/// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/emergency/emergency_manager.dart';
import '../features/profile/active_profile_controller.dart';
import '../widgets/accessible_widgets.dart';
import 'accessibility_assistant_screen.dart';
import 'ai_hub_screen.dart';
import 'health_profile_screen.dart';
import 'settings_screen.dart';
import 'wallet_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // الاستماع لتغيّرات الملف النشط (Consumer) بدلاً من قراءة لمرة واحدة،
    // حتى تُحدَّث الشاشة تلقائياً عند تبديل المستخدم بين أفراد العائلة.
    return Consumer<ActiveProfileController>(
      builder: (context, profileController, _) {
        final activeProfileId = profileController.activeProfileId;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Lifex-AI'),
            actions: [
              Semantics(
                button: true,
                label: 'الإعدادات',
                hint: 'يفتح شاشة إعدادات التطبيق واللغة والخصوصية',
                child: IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'الإعدادات',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => HealthProfileScreen(
                            profile: profileController.activeProfile,
                          ),
                        ),
                      );
                    },
                  ),
                  AccessibleActionButton(
                    icon: Icons.medication_outlined,
                    label: 'أدويتي',
                    // ملاحظة: onTap متروك فارغاً (null) عمداً لأن شاشة
                    // إدارة الأدوية لم تُبنَ بعد. AccessibleActionButton
                    // يعرض تلقائياً حالة معطَّلة (رمادية + Semantics.
                    // enabled=false) ويستبدل الوصف بـ"هذه الميزة غير
                    // متاحة بعد" بدلاً من وعد كاذب بفتح صفحة غير موجودة.
                    semanticHint: 'ميزة إدارة الأدوية قيد التطوير حالياً',
                  ),
                  AccessibleActionButton(
                    icon: Icons.calendar_month_outlined,
                    label: 'مواعيدي',
                    // نفس الملاحظة أعلاه: شاشة المواعيد لم تُبنَ بعد.
                    semanticHint: 'ميزة المواعيد الطبية قيد التطوير حالياً',
                  ),
                  AccessibleActionButton(
                    icon: Icons.visibility_outlined,
                    label: 'المساعد البصري',
                    semanticHint: 'يفتح أدوات مساعدة المكفوفين وضعاف البصر',
                    onTap: activeProfileId == null
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AccessibilityAssistantScreen(
                                  profileId: activeProfileId,
                                ),
                              ),
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
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    WalletScreen(profileId: activeProfileId),
                              ),
                            );
                          },
                  ),
                  AccessibleActionButton(
                    icon: Icons.smart_toy_outlined,
                    label: 'مركز الذكاء الاصطناعي',
                    semanticHint: 'يفتح إدارة حسابات محركات الذكاء الاصطناعي '
                        'المرتبطة مثل Gemini وChatGPT وClaude',
                    onTap: activeProfileId == null
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    AiHubScreen(profileId: activeProfileId),
                              ),
                            );
                          },
                  ),
                  AccessibleActionButton(
                    icon: Icons.emergency_outlined,
                    label: 'طوارئ',
                    semanticHint: 'يبدأ إجراء تنبيه طوارئ فوري لجهات الثقة، '
                        'اضغط ضغطاً مزدوجاً للتأكيد',
                    isUrgent: true,
                    onTap: () {
                      _showEmergencyConfirmationDialog(context, activeProfileId);
                    },
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
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final emergencyManager =
                  Provider.of<EmergencyManager>(context, listen: false);

              // معرّف الملف النشط الحقيقي من ActiveProfileController
              // (بدلاً من نص وهمي ثابت)؛ في الحالة النادرة التي لا يوجد
              // فيها أي ملف نشط بعد (خلل غير متوقع لأن شاشة الإعداد
              // الأولي تضمن وجود ملف قبل الوصول لهذه الشاشة أصلاً)،
              // نستخدم قيمة احتياطية واضحة بدل تعطّل الاستدعاء بالكامل.
              emergencyManager.triggerEmergency(
                profileId: activeProfileId ?? 'unknown_profile',
                reasonAr: 'تفعيل يدوي من الشاشة الرئيسية بواسطة المستخدم.',
              );

              Navigator.of(dialogContext).pop();

              // إعلان فوري لقارئ الشاشة، بالإضافة للـ SnackBar البصري،
              // حتى يسمع المستخدم الكفيف التأكيد دون الحاجة للبحث عنه
              // بإصبعه على الشاشة.
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
