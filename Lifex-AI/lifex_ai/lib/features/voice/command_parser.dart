/// =============================================================
/// Lifex-AI — وحدة الصوت والذكاء اللغوي
/// الملف: command_parser.dart
/// يفهم المعنى عبر مرادفات ويزيل كلمة التنبيه ليفكس/Lifex.
/// =============================================================

library lifex_ai.features.voice.command_parser;

import '../../core/network_canon.dart';
import 'spoken_blood_type.dart';
import 'wake_word_detector.dart';

enum VoiceCommandIntent {
  openHealthProfile,
  openMedications,
  confirmMedicationTaken,
  openAppointments,
  callEmergency,
  addSymptom,
  readLastLabResult,
  switchProfile,
  openProjectBox,
  openSearch,
  openPharmacy,
  openDoctors,
  openCamera,
  openAccessibility,
  openLiveSight,
  openLayeredLens,
  openThumbnail,
  openDoctorDiary,
  openEmpowermentLab,
  openChildRights,
  openChoiceMirror,
  openYouthGuide,
  openRoyalIntelligence,
  openKnowledgeArcade,
  openPersonalShelf,
  openClinicalWatch,
  openManualVitals,
  openOpticalRadar,
  openNetworkUnit,
  clarifyHealthAspect,
  unknown,
}

class ParsedVoiceCommand {
  final VoiceCommandIntent intent;
  final Map<String, String> parameters;
  final String originalText;

  const ParsedVoiceCommand({
    required this.intent,
    this.parameters = const {},
    required this.originalText,
  });
}

class _CommandRule {
  final VoiceCommandIntent intent;
  final List<String> keywords;

  const _CommandRule(this.intent, this.keywords);
}

class CommandParser {
  CommandParser({WakeWordDetector? wakeWordDetector})
      : _wake = wakeWordDetector ?? WakeWordDetector();

  final WakeWordDetector _wake;

  final List<_CommandRule> _rules = const [
    _CommandRule(VoiceCommandIntent.openHealthProfile, [
      'ملفي الصحي',
      'الملف الصحي',
      'صحتي',
      'وضعي الصحي',
      'كيف صحتي',
      'العلامات الحيوية',
      'health profile',
      'my health',
      'how is my health',
      'profil santé',
      'mi salud',
      'gesundheitsprofil',
      'sağlık dosyam',
    ]),
    _CommandRule(VoiceCommandIntent.confirmMedicationTaken, [
      'لقد تناولت الدواء',
      'تناولت الدواء',
      'أخذت الدواء',
      'أخذت الجرعة',
      'تم الدواء',
      'i took the medicine',
      'dose taken',
    ]),
    _CommandRule(VoiceCommandIntent.openMedications, [
      'أدويتي',
      'الأدوية',
      'دوائي',
      'دوائي القادم',
      'ذكرني بالدواء',
      'لا تنسيني الحبة',
      'موعد الجرعة',
      'الحبة',
      'medications',
      'medicine',
      'my meds',
      'next dose',
      'remind me the pill',
      'médicaments',
      'medicamentos',
      'medikamente',
      'ilaçlarım',
    ]),
    _CommandRule(VoiceCommandIntent.openAppointments, [
      'مواعيدي',
      'المواعيد',
      'حجز موعد',
      'appointments',
      'my appointments',
      'rendez-vous',
      'citas',
      'termine',
      'randevularım',
    ]),
    _CommandRule(VoiceCommandIntent.callEmergency, [
      'طوارئ',
      'إسعاف',
      'ساعدوني',
      'نجدة',
      'لا أستطيع التنفس',
      'ما أقدر أتنفس',
      'اختناق',
      'emergency',
      'help me',
      'ambulance',
      "can't breathe",
      'cannot breathe',
      'urgence',
      'emergencia',
      'notfall',
      'acil',
      'yardım',
    ]),
    _CommandRule(VoiceCommandIntent.addSymptom, [
      'سجل عرض',
      'أضف عرض',
      'عندي عرض',
      'تعبان',
      'أنا تعبان',
      'tired',
      "i'm tired",
      'الاستبيان',
      'استبيان',
      'symptom',
      'questionnaire',
      'cuestionario',
    ]),
    _CommandRule(VoiceCommandIntent.readLastLabResult, [
      'نتيجة التحليل',
      'آخر تحليل',
      'اقرأ نتيجتي',
      'lab result',
      'last test',
      'résultat',
      'resultado',
    ]),
    _CommandRule(VoiceCommandIntent.switchProfile, [
      'بدّل الملف',
      'غيّر الحساب',
      'ملف آخر',
      'switch profile',
      'change account',
      'changer de profil',
    ]),
    _CommandRule(VoiceCommandIntent.openProjectBox, [
      'صندوق المشروع',
      'الصندوق',
      'الحجز',
      'المنظومة',
      'project box',
      'open box',
    ]),
    _CommandRule(VoiceCommandIntent.openSearch, [
      'بحث',
      'ابحث',
      'search',
      'find',
      'chercher',
      'buscar',
      'suche',
      'ara',
    ]),
    _CommandRule(VoiceCommandIntent.openPharmacy, [
      'صيدلية',
      'الصيدلية',
      'pharmacy',
      'pharmacie',
      'farmacia',
      'apotheke',
      'eczane',
    ]),
    _CommandRule(VoiceCommandIntent.openDoctors, [
      'الأطباء',
      'طبيب قريب',
      'doctor',
      'doctors',
      'médecin',
      'médico',
      'arzt',
      'doktor',
    ]),
    _CommandRule(VoiceCommandIntent.openLayeredLens, [
      'عدسة الشرائح',
      'الشرائح المتراكبة',
      'كاميرا ثلاثية',
      'تصوير الجلد',
      'تكبير الجلد',
      'كاميرتين',
      'عدستان',
      'التحكم بالكاميرا',
      'الزوم الكبير',
      'استوديو الشرائح',
      'x200',
      'layered lens',
      'skin zoom',
      '3d camera',
    ]),
    _CommandRule(VoiceCommandIntent.openLiveSight, [
      'ما الموجود أمامي',
      'ماذا أمامي',
      'صف باستمرار',
      'الكاميرا الحية',
      'البث الحي',
      'افتح العدسة',
      'live camera',
      'what is in front',
      'what is ahead',
    ]),
    _CommandRule(VoiceCommandIntent.openCamera, [
      'الكاميرا',
      'صورة ورقة',
      'camera',
      'caméra',
      'cámara',
      'kamera',
    ]),
    _CommandRule(VoiceCommandIntent.openThumbnail, [
      'الصورة المصغرة',
      'الصورة المصغّرة',
      'manage the thumbnail',
      'thumbnail',
      'الختم الرسمي',
    ]),
    _CommandRule(VoiceCommandIntent.openDoctorDiary, [
      'يوميات الطبيب',
      'لوحة الطبيب',
      'جدول الحصص',
      'doctor diary',
      'doctor dashboard',
    ]),
    _CommandRule(VoiceCommandIntent.openEmpowermentLab, [
      'موسوعة التمكين',
      'ميثاق الثراء',
      'أكاديمية الروح',
      'empowerment',
      'ghaaziby',
    ]),
    _CommandRule(VoiceCommandIntent.openChildRights, [
      'حقوق الطفل',
      'كتاب حقوق الطفل',
      'child rights',
    ]),
    _CommandRule(VoiceCommandIntent.openChoiceMirror, [
      'مرآة الاختيار',
      'مَرآةُ الاختيار',
      'كتاب المرآة',
      'نضج العلاقات',
      'choice mirror',
    ]),
    _CommandRule(VoiceCommandIntent.openYouthGuide, [
      'دليل اليافعين',
      'مكتبة اليافعين',
      'اليافعين',
      'youth guide',
    ]),
    _CommandRule(VoiceCommandIntent.openRoyalIntelligence, [
      'الذكاء الملكي',
      'المنصة الملكية',
      'اختبار ملكي',
      'royal intelligence',
    ]),
    _CommandRule(VoiceCommandIntent.openKnowledgeArcade, [
      'رواق المعرفة',
      'مكتبة ليفكس',
      'المكتبات',
      'knowledge arcade',
    ]),
    _CommandRule(VoiceCommandIntent.openPersonalShelf, [
      'رف التحميل',
      'رفّ التحميل',
      'تنزيل كتاب',
      'personal shelf',
    ]),
    _CommandRule(VoiceCommandIntent.openClinicalWatch, [
      'المراقبة السريرية',
      'مراقبة سريرية',
      'إشعار المراقبة',
      'clinical watch',
      'bedside monitor',
    ]),
    _CommandRule(VoiceCommandIntent.openManualVitals, [
      'القياسات اليدوية',
      'لوحة القياسات',
      'ملاحظة لون البول',
      'لون البول',
      'نغمة النبض',
      'فحص شامل',
      'الفحص الطبي',
      'manual vitals',
    ]),
    _CommandRule(VoiceCommandIntent.openOpticalRadar, [
      'الرادار الضوئي',
      'وميض المسافة',
      'تقدير المسافة',
      'gfrs',
    ]),
    _CommandRule(VoiceCommandIntent.openAccessibility, [
      'صف المشهد',
      'المساعد البصري',
      'صورة واحدة',
      'describe the scene',
    ]),
    _CommandRule(VoiceCommandIntent.clarifyHealthAspect, [
      'كيف وضعي',
      'وضعي',
      'how am i',
      'how am I',
      "how's my status",
    ]),
  ];

  ParsedVoiceCommand parse(String rawText) {
    final stripped = _wake.strip(rawText);
    final normalized = stripped.trim();
    final folded = normalized.toLowerCase();

    bool matches(_CommandRule rule) => rule.keywords.any((keyword) {
          final key = keyword.toLowerCase();
          return normalized.contains(keyword) || folded.contains(key);
        });

    final emergencyRule = _rules.firstWhere(
      (r) => r.intent == VoiceCommandIntent.callEmergency,
    );
    if (matches(emergencyRule)) {
      return ParsedVoiceCommand(
        intent: VoiceCommandIntent.callEmergency,
        originalText: rawText,
      );
    }

    _CommandRule? chosen;
    var strength = -1;
    for (final rule in _rules) {
      if (rule.intent == VoiceCommandIntent.callEmergency) continue;
      for (final keyword in rule.keywords) {
        final key = keyword.toLowerCase();
        if (!normalized.contains(keyword) && !folded.contains(key)) continue;
        if (keyword.length <= strength) continue;
        chosen = rule;
        strength = keyword.length;
      }
    }

    if (const SpokenBloodType().looksLikeBloodRequest(normalized) &&
        (chosen == null ||
            chosen.intent == VoiceCommandIntent.openSearch ||
            chosen.intent == VoiceCommandIntent.openProjectBox)) {
      final type = const SpokenBloodType().match(normalized);
      return ParsedVoiceCommand(
        intent: VoiceCommandIntent.openNetworkUnit,
        parameters: {
          'unitId': 'blood',
          if (type != null) 'bloodType': type.name,
        },
        originalText: rawText,
      );
    }

    if (chosen != null) {
      return ParsedVoiceCommand(
        intent: chosen.intent,
        originalText: rawText,
      );
    }

    final seat = NetworkCanon.match(normalized);
    if (seat != null) {
      return ParsedVoiceCommand(
        intent: VoiceCommandIntent.openNetworkUnit,
        parameters: {
          'unitId': seat.id,
          'boxUnitId': seat.unitId,
        },
        originalText: rawText,
      );
    }

    return ParsedVoiceCommand(
      intent: VoiceCommandIntent.unknown,
      originalText: rawText,
    );
  }
}
