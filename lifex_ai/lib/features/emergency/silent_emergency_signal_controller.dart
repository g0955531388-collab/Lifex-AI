/// =============================================================
/// Lifex-AI — الطوارئ
/// الملف: silent_emergency_signal_controller.dart
/// المسار: lib/features/emergency/silent_emergency_signal_controller.dart
/// الوصف: طبقة قرار توضع أمام MultiSensoryAlertManager الحالي (الذي
/// يبقى دون تغيير ويُستخدم كما هو لتنبيهات إمكانية الوصول العادية
/// للصم/ضعاف السمع). هذا الملف يضيف سلوكاً مختلفاً تماماً ومطلوباً
/// صراحة لحالات الطوارئ تحديداً: بعد إرسال تنبيه الموقع لجهات الثقة،
/// يتحول الجهاز لوضع "صامت بصري فقط" (ومضة الفلاش الخلفي دون أي صوت أو
/// اهتزاز) — لأن الصوت والاهتزاز قد يفضحان وجود استغاثة نشطة في مواقف
/// خطرة (اعتداء، اختطاف، تهديد مباشر). الاستثناء الوحيد: مكالمة واردة
/// فعلية من رقم ضمن EmergencyPhoneContactsRegistry تُعيد التنبيه الطبيعي فوراً.
/// =============================================================
library lifex_ai.features.emergency.silent_emergency_signal_controller;

import '../accessibility/multi_sensory_alert_manager.dart';
import 'emergency_phone_contacts_registry.dart';

/// عقد بسيط يحدد ما إذا كان "الوضع الصامت" مفعَّلاً على مستوى النظام
/// حالياً — التنفيذ الفعلي مرتبط بمفتاح الحدث الدقيق
/// 'emergency_silent_light_mode_enabled' في GlobalAdminManager
/// (core/admin/admin_manager.dart)، لكن هذا الملف لا يستورد وحدة الأدمن
/// مباشرة لتفادي ربط دائري بين core وfeatures؛ بدلاً من ذلك يستقبل
/// دالة فحص بسيطة يمررها main.dart عند التهيئة.
typedef SilentModeEnabledCheck = bool Function();

/// متحكم إشارة الطوارئ — يقرر: صوت واهتزاز طبيعيان، أم ضوء فقط؟
class SilentEmergencySignalController {
  SilentEmergencySignalController({
    required this.multiSensoryAlertManager,
    required this.emergencyContactsRegistry,
    required this.isSilentModeEnabledSystemWide,
  });

  final MultiSensoryAlertManager multiSensoryAlertManager;
  final EmergencyPhoneContactsRegistry emergencyContactsRegistry;
  final SilentModeEnabledCheck isSilentModeEnabledSystemWide;

  /// معرّفات الملفات التي وصلتها مكالمة موثوقة مؤخراً، فيُسمح لها بتنبيه
  /// طبيعي (صوت + اهتزاز) بدل الوضع الصامت حتى تنتهي حالة الطوارئ.
  final Set<String> _profilesWithRecentTrustedCall = {};

  /// يُستدعى من طبقة ربط الاتصالات الحقيقية عند أي مكالمة واردة —
  /// إن كانت من رقم موثوق لهذا المستخدم، يُلغى الوضع الصامت فوراً له.
  void notifyIncomingCall({
    required String profileId,
    required String callerPhoneNumber,
  }) {
    if (emergencyContactsRegistry.isTrustedNumber(profileId, callerPhoneNumber)) {
      _profilesWithRecentTrustedCall.add(profileId);
    }
  }

  /// إعادة الحالة لوضعها الطبيعي عند إغلاق حالة الطوارئ (يُستدعى من
  /// EmergencyManager.resolveEmergency).
  void clearTrustedCallOverride(String profileId) {
    _profilesWithRecentTrustedCall.remove(profileId);
  }

  /// نقطة الدخول الوحيدة لإطلاق إشارة طوارئ حسية — تُستدعى من
  /// EmergencyManager بدلاً من استدعاء MultiSensoryAlertManager مباشرة.
  Future<void> signalEmergency({
    required String profileId,
    required AlertSeverityForSenses severity,
  }) async {
    final shouldStaySilent = isSilentModeEnabledSystemWide() &&
        !_profilesWithRecentTrustedCall.contains(profileId);

    if (!shouldStaySilent) {
      // لا وضع صامت مفعَّل، أو ورد اتصال موثوق بالفعل: السلوك الطبيعي
      // الكامل (صوت + اهتزاز + ومضة) كما هو الحال في كل تنبيهات النظام.
      await multiSensoryAlertManager.triggerAlert(severity);
      return;
    }

    // الوضع الصامت: ومضة الفلاش الخلفي فقط، بلا أي صوت أو اهتزاز، حتى لا
    // تكشف حالة الطوارئ عن نفسها لمن قد يشكّل خطراً على المستخدم.
    final repeatCount = severity == AlertSeverityForSenses.critical ? 8 : 4;
    await multiSensoryAlertManager.visualFlashExecutor
        .flashCameraLight(repeatCount: repeatCount);
  }
}
