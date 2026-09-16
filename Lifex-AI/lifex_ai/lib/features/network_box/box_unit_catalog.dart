/// =============================================================
/// Lifex-AI — صندوق المشروع
/// الملف: box_unit_catalog.dart
/// فهرس كل مقاعد الصندوق بما فيها الفراغ المؤسسي.
/// =============================================================
library lifex_ai.features.network_box.box_unit_catalog;

import 'package:flutter/material.dart';

import 'profile_box_store.dart';

class BoxUnit {
  const BoxUnit({
    required this.id,
    required this.titleAr,
    required this.subtitleAr,
    required this.storageKey,
    required this.icon,
    required this.needsServer,
    this.primaryLabelAr = 'العنوان',
    this.detailLabelAr = 'التفاصيل',
  });

  final String id;
  final String titleAr;
  final String subtitleAr;
  final String storageKey;
  final IconData icon;
  final bool needsServer;
  final String primaryLabelAr;
  final String detailLabelAr;
}

class BoxUnitCatalog {
  BoxUnitCatalog._();

  static const doctors = BoxUnit(
    id: 'doctors',
    titleAr: 'الأطباء',
    subtitleAr: 'دليل محلي للأطباء المتابعين',
    storageKey: BoxKeys.doctors,
    icon: Icons.medical_information_outlined,
    needsServer: true,
    primaryLabelAr: 'اسم الطبيب أو الاختصاص',
    detailLabelAr: 'جهة أو رقم أو ملاحظة',
  );

  static const patients = BoxUnit(
    id: 'patients',
    titleAr: 'المرضى',
    subtitleAr: 'سجلات رعاية محلية دون كشف ملفات الآخرين',
    storageKey: BoxKeys.patients,
    icon: Icons.personal_injury_outlined,
    needsServer: true,
    primaryLabelAr: 'الاسم المستعار أو الدور',
    detailLabelAr: 'ملاحظة رعاية',
  );

  static const labs = BoxUnit(
    id: 'labs',
    titleAr: 'المخابر',
    subtitleAr: 'طلبات ونتائج يضيفها المستخدم',
    storageKey: BoxKeys.labs,
    icon: Icons.science_outlined,
    needsServer: true,
    primaryLabelAr: 'اسم التحليل',
    detailLabelAr: 'النتيجة أو المختبر',
  );

  static const radiology = BoxUnit(
    id: 'radiology',
    titleAr: 'الأشعة والتصوير',
    subtitleAr: 'أرشيف مواعيد وتقارير محلية',
    storageKey: BoxKeys.radiology,
    icon: Icons.image_search_outlined,
    needsServer: true,
    primaryLabelAr: 'نوع الفحص',
    detailLabelAr: 'المركز أو الملاحظة',
  );

  static const pharmacy = BoxUnit(
    id: 'pharmacy',
    titleAr: 'الصيدلية',
    subtitleAr: 'وصفات وصرف مرتبط بسجل أدويتك',
    storageKey: BoxKeys.pharmacy,
    icon: Icons.local_pharmacy_outlined,
    needsServer: true,
    primaryLabelAr: 'الدواء أو الوصفة',
    detailLabelAr: 'الصيدلية أو الحالة',
  );

  static const hospital = BoxUnit(
    id: 'hospital',
    titleAr: 'المستشفى',
    subtitleAr: 'دخول وتحويلات محلية',
    storageKey: BoxKeys.hospital,
    icon: Icons.local_hospital_outlined,
    needsServer: true,
    primaryLabelAr: 'اسم المستشفى أو القسم',
    detailLabelAr: 'سبب المراجعة',
  );

  static const dental = BoxUnit(
    id: 'dental',
    titleAr: 'طب الأسنان',
    subtitleAr: 'خطة علاج ومواعيد سنية',
    storageKey: BoxKeys.dental,
    icon: Icons.medical_services_outlined,
    needsServer: true,
    primaryLabelAr: 'الإجراء أو الطبيب',
    detailLabelAr: 'الخطة أو الموعد',
  );

  static const women = BoxUnit(
    id: 'women',
    titleAr: 'رعاية الإناث والحمل',
    subtitleAr: 'من التكوين حتى ما بعد الولادة',
    storageKey: BoxKeys.women,
    icon: Icons.pregnant_woman_outlined,
    needsServer: false,
    primaryLabelAr: 'المرحلة أو المتابعة',
    detailLabelAr: 'ملاحظة صحية',
  );

  static const donations = BoxUnit(
    id: 'donations',
    titleAr: 'التبرعات',
    subtitleAr: 'دعم مالي أو خدمي أو عيني',
    storageKey: BoxKeys.donations,
    icon: Icons.volunteer_activism_outlined,
    needsServer: true,
    primaryLabelAr: 'نوع التبرع',
    detailLabelAr: 'التفاصيل',
  );

  static const education = BoxUnit(
    id: 'education',
    titleAr: 'التأهيل والتدريب',
    subtitleAr: 'دورات وخطط تطوير شخصية',
    storageKey: BoxKeys.education,
    icon: Icons.school_outlined,
    needsServer: false,
    primaryLabelAr: 'الدورة أو الهدف',
    detailLabelAr: 'التقدم أو الموعد',
  );

  static const medicalDevices = BoxUnit(
    id: 'medicalDevices',
    titleAr: 'الأجهزة الطبية',
    subtitleAr: 'سجل أجهزة القياس دون اتصال مزيف',
    storageKey: BoxKeys.medicalDevices,
    icon: Icons.monitor_heart_outlined,
    needsServer: true,
    primaryLabelAr: 'نوع الجهاز',
    detailLabelAr: 'الشركة أو بروتوكول الاتصال',
  );

  static const biometrics = BoxUnit(
    id: 'biometrics',
    titleAr: 'القياسات الحيوية',
    subtitleAr: 'إدخال يدوي من جهازك أو طبيبك',
    storageKey: BoxKeys.biometrics,
    icon: Icons.favorite_outline,
    needsServer: false,
    primaryLabelAr: 'نوع القياس',
    detailLabelAr: 'القيمة والمصدر',
  );

  static const chronicPlans = BoxUnit(
    id: 'chronicPlans',
    titleAr: 'الرعاية المزمنة والهمم',
    subtitleAr: 'خطط طويلة الأمد وإعفاء الرسوم',
    storageKey: BoxKeys.chronicPlans,
    icon: Icons.accessibility_new_outlined,
    needsServer: false,
    primaryLabelAr: 'الحالة أو الخطة',
    detailLabelAr: 'التذكير أو المتابعة',
  );

  static const connectedDevices = BoxUnit(
    id: 'connectedDevices',
    titleAr: 'الأجهزة المرتبطة',
    subtitleAr: 'هواتف وأجهزة يصرّح بها المستخدم',
    storageKey: BoxKeys.connectedDevices,
    icon: Icons.devices_outlined,
    needsServer: true,
    primaryLabelAr: 'اسم الجهاز',
    detailLabelAr: 'النوع أو القناة',
  );

  static const List<BoxUnit> recordUnits = [
    doctors,
    patients,
    labs,
    radiology,
    pharmacy,
    hospital,
    dental,
    women,
    donations,
    education,
    medicalDevices,
    biometrics,
    chronicPlans,
    connectedDevices,
  ];

  static BoxUnit byId(String id) =>
      recordUnits.firstWhere((unit) => unit.id == id);
}
