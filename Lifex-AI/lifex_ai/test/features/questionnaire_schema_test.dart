import 'package:flutter_test/flutter_test.dart';
import 'package:lifex_ai/core/license_manager.dart';
import 'package:lifex_ai/features/doctors/public_slot_policy.dart';
import 'package:lifex_ai/features/profile/health_profile.dart';
import 'package:lifex_ai/features/profile/health_questionnaire_schema.dart';
import 'package:lifex_ai/features/profile/html_survey_alias.dart';
import 'package:lifex_ai/features/profile/questionnaire_consistency.dart';

void main() {
  test('الاستبيان اثنا عشر قسماً بلا تكرار مفاتيح', () {
    expect(HealthQuestionnaireSchema.sections, hasLength(13));
    final keys = HealthQuestionnaireSchema.allKeys();
    expect(keys.toSet().length, keys.length);
    expect(keys, containsAll(['surveyName', 'surveyNationalId', 'photoTongue', 'familyMembers', 'implants', 'lastECG']));
  });

  test('تعارض الجنس والحمل ليس تشخيصاً', () {
    final notes = QuestionnaireConsistency.notes(
      {
        'surveySex': 'ذكر',
        'pregnancyCount': '2',
      },
      sex: BiologicalSex.male,
    );
    expect(notes.join(), contains('الحمل'));
    expect(QuestionnaireConsistency.summary({}).contains('ليس تقريراً طبياً'), isTrue);
  });

  test('الإسناد يُلحق بالنطق دون ادعاء معالجة سحابية', () {
    final stamped = LicenseManager.instance.appendAr('تم الحفظ على الجهاز.');
    expect(stamped, contains('تم الحفظ على الجهاز'));
    expect(stamped.toLowerCase(), isNot(contains('سحاب')));
  });

  test('مفاتيح HTML تُطوى إلى الاستبيان دون شاشة ثانية', () {
    final folded = HtmlSurveyAlias.foldIntoCanon({
      'name': 'صاحب الملف',
      'heart': 'لا يوجد',
      'extraNotes': 'ملاحظة',
    });
    expect(folded['surveyName'], 'صاحب الملف');
    expect(folded['cardiovascularSymptoms'], 'لا يوجد');
    expect(folded['generalNotes'], 'ملاحظة');
  });

  test('حصص الصفحة العامة صباح ومساء بلا مرضى وهميين', () {
    const policy = PublicSlotPolicy();
    final clocks = policy.clockLabels();
    expect(clocks.first, '09:00');
    expect(clocks, contains('11:30'));
    expect(clocks, contains('15:00'));
    expect(clocks.last, '18:30');
    expect(clocks, isNot(contains('12:00')));
    final soon = DateTime(2026, 9, 16, 22);
    expect(policy.canModify(soon.add(const Duration(hours: 2)), soon), isFalse);
    expect(policy.canModify(soon.add(const Duration(hours: 13)), soon), isTrue);
  });
}
