/// =============================================================
/// Lifex-AI — الهوية الصحية
/// الملف: questionnaire_consistency.dart
/// تعارضات إدخال بسيطة. ليست تشخيصاً ولا تقريراً طبياً.
/// =============================================================
library lifex_ai.features.profile.questionnaire_consistency;

import 'health_profile.dart';

class QuestionnaireConsistency {
  QuestionnaireConsistency._();

  static List<String> notes(
    Map<String, dynamic> answers, {
    BiologicalSex? sex,
  }) {
    final out = <String>[];
    final smoking = answers['smoking'] == true;
    final smokingType = answers['smokingType']?.toString();
    if (smoking && smokingType == 'لا أدخن') {
      out.add('ذكرت تدخيناً واخترت «لا أدخن». صحّح أحد الحقلين.');
    }

    final male = sex == BiologicalSex.male || answers['surveySex'] == 'ذكر';
    final pregnancies = int.tryParse('${answers['pregnancyCount'] ?? 0}') ?? 0;
    final miscarriages = int.tryParse('${answers['miscarriageCount'] ?? 0}') ?? 0;
    if (male && (answers['isPregnant'] == true || pregnancies > 0 || miscarriages > 0)) {
      out.add('حقول الحمل مفعّلة بينما الجنس المذكور ذكر. راجع الجنس أو الحقول.');
    }

    final heart = '${answers['cardiovascularSymptoms'] ?? ''}'.toLowerCase();
    final implants = '${answers['implants'] ?? ''}${answers['pastSurgeries'] ?? ''}';
    if ((heart.contains('لا أعاني') || heart.contains('لا يوجد')) &&
        (implants.contains('قلب') ||
            implants.contains('دعامة') ||
            implants.contains('منظم'))) {
      out.add('وصفت القلب بأنه بلا شكوى مع ذكر جهاز أو عملية قلبية. وضّح النصّين للطبيب.');
    }

    if (answers['emergencyChestPain'] == true ||
        answers['emergencySevereBreathing'] == true ||
        answers['emergencyLossOfConsciousness'] == true ||
        answers['emergencySuddenParalysis'] == true ||
        answers['emergencyBleeding'] == true) {
      out.add('توجد إشارة طوارئ في الإجابات. الاستبيان لا يشخص. راجع قسماً للطوارئ أو طبيباً.');
    }
    return out;
  }

  static String summary(Map<String, dynamic> answers) {
    final name = answers['surveyName']?.toString().trim();
    final chronic = answers['chronicDiseaseList']?.toString().trim();
    final heart = answers['cardiovascularSymptoms']?.toString().trim();
    final mental = answers['mentalSymptoms']?.toString().trim();
    final buf = StringBuffer()
      ..writeln('ملخص إدخالك فقط، ليس تقريراً طبياً ولا تشخيصاً.')
      ..writeln(name == null || name.isEmpty ? 'الاسم في الاستبيان: غير مذكور.' : 'الاسم في الاستبيان: $name')
      ..writeln(chronic == null || chronic.isEmpty
          ? 'الأمراض المزمنة: لم تُذكر.'
          : 'الأمراض المزمنة كما كتبت: $chronic')
      ..writeln(heart == null || heart.isEmpty
          ? 'القلب: لم يُذكر نص.'
          : 'القلب كما كتبت: $heart')
      ..writeln(mental == null || mental.isEmpty
          ? 'الصحة النفسية: لم يُذكر نص.'
          : 'النفس كما كتبت: $mental')
      ..writeln('أكمل بالطبيب والفحوص. Lifex-AI ليس بديلاً عن الطبيب.');
    return buf.toString();
  }
}
