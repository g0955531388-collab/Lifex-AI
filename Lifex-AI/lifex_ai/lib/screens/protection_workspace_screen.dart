/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: protection_workspace_screen.dart
/// فقدان الجهاز، الطاقة، المراقبة، الأجهزة.
/// =============================================================
library lifex_ai.screens.protection_workspace_screen;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/device_guardian/account_recovery_manager.dart';
import '../features/device_guardian/device_guardian_manager.dart';
import '../features/device_guardian/lost_phone_policy.dart';
import '../features/device_guardian/trusted_devices_manager.dart';
import '../features/energy/energy_manager.dart';
import '../features/energy/survival_energy_mode.dart';
import '../features/network_box/box_unit_catalog.dart';
import '../features/network_box/profile_box_store.dart';
import '../features/profile/active_profile_controller.dart';
import '../widgets/honesty_banner.dart';
import 'box_unit_screen.dart';
import 'permission_transparency_screen.dart';

class ProtectionWorkspaceScreen extends StatelessWidget {
  const ProtectionWorkspaceScreen({super.key});

  String get _thisDeviceId => 'this-device';

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveProfileController>(
      builder: (context, controller, _) {
        final profile = controller.activeProfile;
        final energy = context.watch<EnergyManager>();
        if (profile == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('الحماية حتى آخر يوم')),
            body: const Center(child: Text('لا يوجد ملف صحي نشط.')),
          );
        }
        final store = ProfileBoxStore(profile);
        final guardian = store.map(BoxKeys.guardian);
        final links = store.list(BoxKeys.remoteLinks);
        final battery = energy.batteryMonitor.lastKnownStatus;
        final hasReader = energy.batteryMonitor.reader != null;
        return Scaffold(
          appBar: AppBar(title: const Text('الحماية حتى آخر يوم')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const HonestyBanner(
                messageAr:
                    'حماية الجهاز محلية على هذا الهاتف. المسح عن بعد وقفل الأجهزة الأخرى يحتاج خادماً. بلا Device Admin.',
              ),
              const SizedBox(height: 12),
              Text('حارس الجهاز',
                  style: Theme.of(context).textTheme.titleMedium),
              ListTile(
                title: const Text('هذا الجهاز'),
                subtitle: Text(
                  guardian['registered'] == true
                      ? 'مسجَّل محلياً'
                      : 'غير مسجَّل بعد',
                ),
                trailing: FilledButton.tonal(
                  onPressed: () {
                    store.setMap(BoxKeys.guardian, {
                      ...guardian,
                      'registered': true,
                      'deviceId': _thisDeviceId,
                      'registeredAt': DateTime.now().toIso8601String(),
                    });
                    controller.saveActiveProfileChanges();
                  },
                  child: const Text('تسجيل'),
                ),
              ),
              ListTile(
                title: const Text('الإبلاغ عن فقدان'),
                subtitle: Text(guardian['lost'] == true
                    ? 'مُبلَّغ محلياً — بانتظار خادم للقفل البعيد'
                    : 'لم يُبلَّغ'),
                trailing: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    final trusted = TrustedDevicesManager()
                      ..registerDevice(TrustedDevice(
                        deviceId: _thisDeviceId,
                        deviceLabel: 'هذا الجهاز',
                      ));
                    DeviceGuardianManager(
                      recoveryManager: AccountRecoveryManager(),
                      trustedDevicesManager: trusted,
                    ).reportDeviceLostOrStolen(
                      deviceId: _thisDeviceId,
                      wasStolen: false,
                    );
                    store.setMap(BoxKeys.guardian, {
                      ...store.map(BoxKeys.guardian),
                      'lost': true,
                      'lostAt': DateTime.now().toIso8601String(),
                    });
                    controller.saveActiveProfileChanges();
                  },
                  child: const Text('فقدان'),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('سياسة أين جوالي',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Text(const LostPhonePolicy().nearbyActionAr()),
                      const SizedBox(height: 6),
                      Text(const LostPhonePolicy().farSmsTemplate()),
                      const SizedBox(height: 6),
                      Text(const LostPhonePolicy().simChangeWithoutPinAr()),
                      const SizedBox(height: 8),
                      Text(
                        (guardian['pin']?.toString().isNotEmpty == true)
                            ? 'رمز الاستعادة محفوظ محلياً على هذا الجهاز.'
                            : 'لم يُحفظ رمز بعد. الرسالة البعيدة تحتاج الرمز.',
                      ),
                      TextField(
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'رمز أين جوالي (محلي)',
                        ),
                        onSubmitted: (value) {
                          final pin = value.trim();
                          if (pin.isEmpty) return;
                          store.setMap(BoxKeys.guardian, {
                            ...store.map(BoxKeys.guardian),
                            'pin': pin,
                          });
                          controller.saveActiveProfileChanges();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('الطاقة', style: Theme.of(context).textTheme.titleMedium),
              ListTile(
                title: const Text('قراءة البطارية'),
                subtitle: Text(
                  hasReader
                      ? 'المستوى ${battery.level}% — ${battery.isCharging ? 'يشحن' : 'لا يشحن'}'
                      : 'لا توجد قراءة من النظام حتى يُربط قارئ بطارية حقيقي',
                ),
              ),
              ListTile(
                title: const Text('وضع البقاء'),
                subtitle: Text(
                  energy.survivalMode.isActive
                      ? 'مفعّل — الطوارئ تبقى والتنبيهات تبقى'
                      : 'غير مفعّل. يُفعَّل تحت ${energy.survivalMode.activationThresholdPercent}% عند توفر قراءة',
                ),
              ),
              Text(
                'يبقى يعمل: ${alwaysActiveFeatures.join('، ')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Text('المراقبة عن بعد',
                  style: Theme.of(context).textTheme.titleMedium),
              const HonestyBanner(
                messageAr:
                    'الربط العائلي محلي بأربعة مستويات. الكاميرا الحية والمستوى 3 و4 يحتاجان إذناً ثلاثياً وخادماً.',
              ),
              for (final member in controller.allProfiles)
                if (member.profileId != profile.profileId)
                  Card(
                    child: ListTile(
                      title: Text(member.fullName),
                      subtitle: Text(_linkLabel(links, member.profileId)),
                      trailing: PopupMenuButton<int>(
                        onSelected: (level) {
                          final next = store.list(BoxKeys.remoteLinks)
                            ..removeWhere(
                                (item) => item['targetId'] == member.profileId);
                          next.add({
                            'targetId': member.profileId,
                            'level': level,
                            'approved': level <= 2,
                          });
                          store.setList(BoxKeys.remoteLinks, next);
                          controller.saveActiveProfileChanges();
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 1, child: Text('1 إشعارات')),
                          PopupMenuItem(value: 2, child: Text('2 متابعة')),
                          PopupMenuItem(value: 3, child: Text('3 مراقبة حية')),
                          PopupMenuItem(value: 4, child: Text('4 طوارئ')),
                        ],
                      ),
                    ),
                  ),
              if (controller.allProfiles.length <= 1)
                const Text('أضف فرد عائلة من الإعدادات لربط مراقب.'),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.security_outlined),
                title: const Text('شفافية الصلاحيات'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PermissionTransparencyScreen(),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.devices_outlined),
                title: const Text('سجل الأجهزة المرتبطة'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BoxUnitScreen(
                      unit: BoxUnitCatalog.connectedDevices,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.monitor_heart_outlined),
                title: const Text('الأجهزة الطبية والقياسات'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BoxUnitScreen(
                      unit: BoxUnitCatalog.medicalDevices,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.favorite_outline),
                title: const Text('قياسات يدوية'),
                subtitle: const Text('ليست من الكاميرا وليست تشخيصاً'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BoxUnitScreen(
                      unit: BoxUnitCatalog.biometrics,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _linkLabel(List<Map<String, dynamic>> links, String profileId) {
    final match = links.where((item) => item['targetId'] == profileId);
    if (match.isEmpty) return 'بلا ربط';
    final level = match.first['level'];
    return 'مستوى $level${level is int && level >= 3 ? ' — ينتظر خادماً' : ''}';
  }
}
