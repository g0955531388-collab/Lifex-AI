/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: smart_health_questionnaire_screen.dart
/// المسار: lib/screens/smart_health_questionnaire_screen.dart
/// الوصف: الاستبيان الصحي الشامل. الإجابات تُحفظ في
/// HealthProfile.questionnaireData وتُزامن الطول/الوزن مع الملف.
/// =============================================================
library lifex_ai.screens.smart_health_questionnaire_screen;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/profile/active_profile_controller.dart';
import '../features/profile/health_profile.dart';

class SmartHealthQuestionnaireScreen extends StatefulWidget {
  const SmartHealthQuestionnaireScreen({super.key});

  @override
  State<SmartHealthQuestionnaireScreen> createState() =>
      _SmartHealthQuestionnaireScreenState();
}

class _SmartHealthQuestionnaireScreenState
    extends State<SmartHealthQuestionnaireScreen> {
  final Map<String, dynamic> _answers = <String, dynamic>{};
  final Map<String, TextEditingController> _textControllers = {};
  int _section = 0;

  static const _sections = <_QuestionSection>[
    _QuestionSection('هوية المريض', [
      _Question('weightKg', 'الوزن بالكيلوغرام', _QuestionType.number),
      _Question('heightCm', 'الطول بالسنتيمتر', _QuestionType.number),
      _Question('skinColor', 'لون البشرة', _QuestionType.choice,
          options: ['فاتح', 'قمحي', 'أسمر', 'داكن']),
      _Question('eyeColor', 'لون العينين', _QuestionType.choice,
          options: ['بني', 'أسود', 'أزرق', 'أخضر', 'رمادي']),
      _Question('socialStatus', 'الحالة الاجتماعية', _QuestionType.choice,
          options: ['أعزب', 'متزوج', 'مطلق', 'أرمل']),
      _Question('jobNature', 'طبيعة العمل', _QuestionType.choice,
          options: ['مكتبي', 'ميداني', 'منزلي', 'مختلط', 'لا يعمل']),
      _Question('childrenCount', 'عدد الأبناء', _QuestionType.number),
      _Question('identityNotes', 'ملاحظات الهوية', _QuestionType.text),
    ]),
    _QuestionSection('التاريخ المرضي العائلي', [
      _Question('familyDiabetes', 'سكري في العائلة', _QuestionType.yesNo),
      _Question('familyHypertension', 'ضغط دم في العائلة', _QuestionType.yesNo),
      _Question(
          'familyHeartDisease', 'أمراض قلب في العائلة', _QuestionType.yesNo),
      _Question('familyCancer', 'سرطان في العائلة', _QuestionType.yesNo),
      _Question('familyGeneticDisease', 'أمراض وراثية في العائلة',
          _QuestionType.yesNo),
      _Question('familyNotes', 'صلة القرابة والملاحظات', _QuestionType.text),
    ]),
    _QuestionSection('التاريخ المرضي الشخصي', [
      _Question(
          'hasChronicDisease', 'هل تعاني من مرض مزمن؟', _QuestionType.yesNo),
      _Question(
          'chronicDiseaseList', 'اذكر الأمراض المزمنة', _QuestionType.text),
      _Question('previousHospitalization', 'هل دخلت المستشفى سابقاً؟',
          _QuestionType.yesNo),
      _Question(
          'previousSurgery', 'هل أجريت عملية جراحية؟', _QuestionType.yesNo),
      _Question('pastSurgeries', 'نوع العملية وتاريخها', _QuestionType.text),
      _Question('implants', 'زراعة أو دعامات أو منظم ضربات', _QuestionType.text),
      _Question(
          'tumorsOrLumps', 'كتل أو أورام أو تصبغات ومكانها', _QuestionType.text),
      _Question('recurringInfections', 'أمراض أو التهابات متكررة',
          _QuestionType.text),
      _Question('medicalHistoryNotes', 'تفاصيل وملاحظات', _QuestionType.text),
    ]),
    _QuestionSection('الأدوية والحساسية', [
      _Question('usesRegularMedication', 'هل تستخدم أدوية بشكل دائم؟',
          _QuestionType.yesNo),
      _Question('medicationList', 'أسماء الأدوية والجرعات', _QuestionType.text),
      _Question('alternativeTreatments', 'أعشاب أو مكملات أو علاج طبيعي',
          _QuestionType.text),
      _Question('hasAllergy', 'هل لديك حساسية؟', _QuestionType.yesNo),
      _Question('allergyList', 'المواد التي تسبب الحساسية ورد الفعل',
          _QuestionType.text),
    ]),
    _QuestionSection('المؤشرات الحيوية', [
      _Question('bloodPressureStatus', 'حالة ضغط الدم', _QuestionType.choice,
          options: ['طبيعي', 'مرتفع', 'منخفض', 'غير معروف']),
      _Question('pulseStatus', 'حالة النبض', _QuestionType.choice,
          options: ['طبيعي', 'سريع', 'بطيء', 'غير معروف']),
      _Question('bloodSugarStatus', 'حالة سكر الدم', _QuestionType.choice,
          options: ['طبيعي', 'مرتفع', 'منخفض', 'غير معروف']),
      _Question('oxygenStatus', 'نسبة الأكسجين', _QuestionType.choice,
          options: ['طبيعية', 'منخفضة', 'غير معروفة']),
      _Question('vitalNotes', 'ملاحظات المؤشرات الحيوية', _QuestionType.text),
    ]),
    _QuestionSection('نمط الحياة', [
      _Question('physicalActivity', 'النشاط البدني', _QuestionType.choice,
          options: ['منخفض', 'متوسط', 'مرتفع']),
      _Question('sleepHours', 'النوم', _QuestionType.choice,
          options: ['أقل من 5 ساعات', '5 إلى 7 ساعات', 'أكثر من 7 ساعات']),
      _Question('sleepQuality', 'جودة النوم', _QuestionType.choice,
          options: ['جيدة', 'متقطعة', 'سيئة', 'غير معروفة']),
      _Question('dietType', 'نمط الغذاء', _QuestionType.choice,
          options: ['متوازن', 'غني بالسكر', 'غني بالدهون', 'نباتي', 'غير منتظم']),
      _Question('smoking', 'هل تدخن؟', _QuestionType.yesNo),
      _Question('smokingType', 'نوع التدخين', _QuestionType.choice,
          options: ['لا أدخن', 'سجائر', 'نرجيلة', 'إلكتروني', 'أكثر من نوع']),
      _Question('dailyCigarettes', 'عدد السجائر يومياً', _QuestionType.number),
      _Question('environment', 'بيئة المعيشة', _QuestionType.choice,
          options: ['مدينة', 'ريف', 'رطبة', 'ملوثة', 'مختلطة']),
      _Question('lifestyleNotes', 'ملاحظات نمط الحياة', _QuestionType.text),
    ]),
    _QuestionSection('مراجعة أجهزة الجسم', [
      _Question('nervousSymptoms', 'الجهاز العصبي: صداع، دوار، تنميل',
          _QuestionType.text),
      _Question('cardiovascularSymptoms', 'القلب: خفقان أو ألم صدر',
          _QuestionType.text),
      _Question('respiratorySymptoms', 'التنفس: سعال أو ضيق نفس',
          _QuestionType.text),
      _Question(
          'digestiveSymptoms', 'الهضم: غثيان أو إمساك', _QuestionType.text),
      _Question('musculoskeletalSymptoms', 'العظام والمفاصل', _QuestionType.text),
    ]),
    _QuestionSection('آخر الفحوصات', [
      _Question('lastBloodTest', 'آخر تحليل دم', _QuestionType.text),
      _Question('lastECG', 'آخر تخطيط قلب', _QuestionType.text),
      _Question('lastSugarTest', 'آخر فحص سكر', _QuestionType.text),
      _Question('lastHormoneTest', 'آخر فحص هرمونات', _QuestionType.text),
    ]),
    _QuestionSection('الأعراض العامة الحالية', [
      _Question('currentHeadache', 'صداع', _QuestionType.yesNo),
      _Question('currentDizziness', 'دوخة', _QuestionType.yesNo),
      _Question('currentFatigue', 'تعب عام', _QuestionType.yesNo),
      _Question('currentFever', 'حمى', _QuestionType.yesNo),
      _Question('symptomSeverity', 'شدة الأعراض', _QuestionType.choice,
          options: ['خفيفة', 'متوسطة', 'شديدة', 'لا توجد']),
      _Question('symptomNotes', 'مدة الأعراض والملاحظات', _QuestionType.text),
    ]),
    _QuestionSection('مؤشرات الطوارئ', [
      _Question('emergencyChestPain', 'ألم صدر حاد', _QuestionType.yesNo),
      _Question(
          'emergencyLossOfConsciousness', 'فقدان وعي', _QuestionType.yesNo),
      _Question('emergencySuddenParalysis', 'شلل مفاجئ', _QuestionType.yesNo),
      _Question(
          'emergencySevereBreathing', 'صعوبة تنفس شديدة', _QuestionType.yesNo),
      _Question('emergencyBleeding', 'نزيف', _QuestionType.yesNo),
      _Question('emergencyNotes', 'تعليمات الطوارئ الخاصة', _QuestionType.text),
    ]),
    _QuestionSection('الصحة النفسية والمرأة', [
      _Question('anxiety', 'قلق أو توتر', _QuestionType.yesNo),
      _Question('depression', 'مزاج منخفض أو اكتئاب', _QuestionType.yesNo),
      _Question('insomnia', 'أرق', _QuestionType.yesNo),
      _Question('isPregnant', 'حمل حالي (اختياري)', _QuestionType.yesNo),
      _Question('periodRegularity', 'انتظام الدورة (اختياري)', _QuestionType.choice,
          options: ['منتظمة', 'غير منتظمة', 'انقطاع', 'لا ينطبق']),
      _Question('pregnancyCount', 'عدد مرات الحمل (اختياري)', _QuestionType.number),
      _Question('breastChanges', 'تغيرات في الثدي (اختياري)', _QuestionType.text),
      _Question('womenHealthNotes', 'ملاحظات صحية خاصة', _QuestionType.text),
    ]),
    _QuestionSection('ملاحظات عامة وصلاحية المشاركة', [
      _Question('generalNotes', 'ملاحظات عامة', _QuestionType.text),
      _Question('shareWithDoctor', 'السماح للطبيب المعتمد برؤية هذه البيانات',
          _QuestionType.yesNo),
      _Question('shareWithEmergency', 'السماح للطوارئ برؤية الضروري منها',
          _QuestionType.yesNo),
    ]),
  ];

  @override
  void initState() {
    super.initState();
    final existing = context
        .read<ActiveProfileController>()
        .activeProfile
        ?.questionnaireData;
    if (existing != null) _answers.addAll(existing);
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(_Question question) {
    return _textControllers.putIfAbsent(
      question.key,
      () => TextEditingController(
          text: (_answers[question.key] ?? '').toString()),
    );
  }

  void _save() {
    final profile = context.read<ActiveProfileController>().activeProfile;
    if (profile == null) return;
    for (final entry in _textControllers.entries) {
      final value = entry.value.text.trim();
      if (value.isEmpty) {
        _answers.remove(entry.key);
      } else {
        _answers[entry.key] = value;
      }
    }
    _applyCoreFields(profile);
    profile.questionnaireData = Map<String, dynamic>.from(_answers);
    profile.lastUpdatedAt = DateTime.now();
    context.read<ActiveProfileController>().saveActiveProfileChanges();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الاستبيان الصحي في ملفك.')),
    );
  }

  void _applyCoreFields(HealthProfile profile) {
    final weight = double.tryParse(_answers['weightKg']?.toString() ?? '');
    final height = double.tryParse(_answers['heightCm']?.toString() ?? '');
    if (weight != null && weight > 0) profile.weightKg = weight;
    if (height != null && height > 0) profile.heightCm = height;

    final allergyText = _answers['allergyList']?.toString().trim() ?? '';
    if (allergyText.isNotEmpty) {
      for (final token in allergyText.split(RegExp(r'[،,]+'))) {
        final substance = token.trim();
        if (substance.isEmpty || profile.hasAllergyTo(substance)) continue;
        profile.addAllergy(
          AllergyRecord(substance: substance, severity: 'medium'),
        );
      }
    }

    final medicationText = _answers['medicationList']?.toString().trim() ?? '';
    if (medicationText.isNotEmpty) {
      for (final token in medicationText.split(RegExp(r'[،,\n]+'))) {
        final name = token.trim();
        if (name.isEmpty || profile.currentMedicationNames.contains(name)) {
          continue;
        }
        profile.currentMedicationNames.add(name);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _sections[_section];
    final progress = (_section + 1) / _sections.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('الاستبيان الصحي الشامل'),
        actions: [
          IconButton(
            tooltip: 'حفظ الاستبيان',
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: progress),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('القسم ${_section + 1} من ${_sections.length}',
                    style: Theme.of(context).textTheme.labelLarge),
                Flexible(
                  child: Text(
                    current.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'هذه بيانات تنظيمية لملفك الصحي وليست تشخيصاً ولا بديلاً عن الطبيب.',
              style: TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: current.questions.map(_buildQuestion).toList(),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (_section > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _section--),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('السابق'),
                      ),
                    ),
                  if (_section > 0) const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _section == _sections.length - 1
                          ? _save
                          : () => setState(() => _section++),
                      icon: Icon(_section == _sections.length - 1
                          ? Icons.check
                          : Icons.arrow_forward),
                      label: Text(_section == _sections.length - 1
                          ? 'حفظ وإنهاء'
                          : 'التالي'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(_Question question) {
    switch (question.type) {
      case _QuestionType.yesNo:
        return Card(
          child: SwitchListTile(
            title: Text(question.label),
            value: _answers[question.key] == true,
            onChanged: (value) =>
                setState(() => _answers[question.key] = value),
          ),
        );
      case _QuestionType.choice:
        final current = _answers[question.key] as String?;
        final safeValue =
            question.options!.contains(current) ? current : null;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String>(
            value: safeValue,
            decoration: InputDecoration(labelText: question.label),
            items: question.options!
                .map((option) =>
                    DropdownMenuItem(value: option, child: Text(option)))
                .toList(),
            onChanged: (value) =>
                setState(() => _answers[question.key] = value),
          ),
        );
      case _QuestionType.number:
      case _QuestionType.text:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            controller: _controllerFor(question),
            keyboardType: question.type == _QuestionType.number
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.multiline,
            maxLines: question.type == _QuestionType.number ? 1 : 3,
            decoration: InputDecoration(
              labelText: question.label,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) => _answers[question.key] = value,
          ),
        );
    }
  }
}

class _QuestionSection {
  const _QuestionSection(this.title, this.questions);
  final String title;
  final List<_Question> questions;
}

class _Question {
  const _Question(this.key, this.label, this.type, {this.options});
  final String key;
  final String label;
  final _QuestionType type;
  final List<String>? options;
}

enum _QuestionType { text, number, choice, yesNo }
