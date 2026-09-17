/// =============================================================
/// Lifex-AI — الهوية الصحية
/// الملف: html_survey_alias.dart
/// مفاتيح صفحات HTML القديمة تُطوى إلى مفاتيح الاستبيان الحالية.
/// لا شاشة ثانية ولا نسخ الواجهة.
/// =============================================================
library lifex_ai.features.profile.html_survey_alias;

class HtmlSurveyAlias {
  HtmlSurveyAlias._();

  static const htmlToCanon = <String, String>{
    'name': 'surveyName',
    'age': 'surveyAge',
    'gender': 'surveySex',
    'height': 'heightCm',
    'weight': 'weightKg',
    'bloodType': 'surveyBloodType',
    'phone': 'surveyPhone',
    'jobStatus': 'jobStatus',
    'workType': 'workTypeDetail',
    'residence': 'residence',
    'economicStatus': 'economicStatus',
    'familyMembers': 'familyMembers',
    'familyDiseases': 'familyNotes',
    'maritalStatus': 'socialStatus',
    'children': 'childrenCount',
    'socialStress': 'socialStress',
    'currentDiseases': 'currentDiseases',
    'chronicDiseases': 'chronicDiseaseList',
    'recurrentDiseases': 'recurringInfections',
    'currentMedications': 'medicationList',
    'pastMedications': 'pastMedications',
    'otherTreatments': 'alternativeTreatments',
    'surgeries': 'pastSurgeries',
    'fractures': 'fractures',
    'procedures': 'procedures',
    'organTransplants': 'organTransplants',
    'implants': 'implants',
    'periodStatus': 'periodRegularity',
    'periodProblems': 'periodProblems',
    'pregnancies': 'pregnancyCount',
    'births': 'birthCount',
    'miscarriages': 'miscarriageCount',
    'falsePregnancy': 'ectopicOrFalsePregnancy',
    'abnormalHair': 'abnormalHair',
    'breastIssues': 'breastChanges',
    'tumors': 'tumorsOrLumps',
    'lymphNodes': 'lymphNodes',
    'pigmentations': 'pigmentations',
    'neuro': 'nervousSymptoms',
    'eyes': 'eyeSymptoms',
    'ears': 'earSymptoms',
    'nose': 'noseSymptoms',
    'mouth': 'mouthDentalSymptoms',
    'heart': 'cardiovascularSymptoms',
    'respiratory': 'respiratorySymptoms',
    'digestive': 'digestiveSymptoms',
    'liver': 'liverSymptoms',
    'renal': 'renalSymptoms',
    'genital': 'genitalSymptoms',
    'bones': 'musculoskeletalSymptoms',
    'muscles': 'muscleSymptoms',
    'skinHair': 'skinHairSymptoms',
    'endocrine': 'endocrineSymptoms',
    'mental': 'mentalSymptoms',
    'sleep': 'lifestyleNotes',
    'nutrition': 'dietType',
    'activity': 'physicalActivity',
    'smoking': 'smokingType',
    'alcohol': 'alcoholNotes',
    'environment': 'environment',
    'bloodTests': 'lastBloodTest',
    'chestXray': 'lastChestXray',
    'ecg': 'lastECG',
    'hormones': 'lastHormoneTest',
    'vitamins': 'lastVitaminTest',
    'renalLiverTests': 'lastRenalLiverTest',
    'lipids': 'lastLipidTest',
    'glucose': 'lastSugarTest',
    'extraNotes': 'generalNotes',
  };

  static Map<String, dynamic> foldIntoCanon(Map<String, dynamic> raw) {
    final out = Map<String, dynamic>.from(raw);
    for (final entry in htmlToCanon.entries) {
      if (!raw.containsKey(entry.key)) continue;
      final value = raw[entry.key];
      if (value == null || value.toString().trim().isEmpty) continue;
      out.putIfAbsent(entry.value, () => value);
    }
    return out;
  }
}
