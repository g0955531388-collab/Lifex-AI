/// =============================================================
/// Lifex-AI — السي في الصحي
/// الملف: cv_report_engine.dart
/// يقرأ الاستبيان والصور والمرجع المحلي، ي ختم Lifex-AI، ويقترح اختصاصاً.
/// تقدير تقريبي من كلمات المستخدم، ليس تعرّفاً تاماً على الصورة.
/// =============================================================
library lifex_ai.features.profile.cv_report_engine;

import '../../core/app_constants.dart';
import '../../core/local_knowledge.dart';
import '../doctors/doctor_directory.dart';
import '../reports/stamped_report.dart';
import 'health_profile.dart';
import 'health_questionnaire_schema.dart';

class CvReportBundle {
  const CvReportBundle({
    required this.report,
    required this.specialtyAr,
    required this.clueHits,
    required this.shareHintAr,
  });

  final StampedReport report;
  final String specialtyAr;
  final List<KnowledgeHit> clueHits;
  final String shareHintAr;
}

class CvReportEngine {
  const CvReportEngine();

  static const _specialtyHints = <String, String>{
    'قلب': 'قلب',
    'صدر': 'قلب',
    'شرايين': 'قلب',
    'vessel': 'قلب',
    'ecg': 'قلب',
    'تخطيط': 'قلب',
    'جلد': 'جلدية',
    'شعر': 'جلدية',
    'قرحة': 'جلدية',
    'فراش': 'جلدية',
    'bedsore': 'جلدية',
    'لسان': 'باطنة',
    'tongue': 'باطنة',
    'حمل': 'نساء وتوليد',
    'دورة': 'نساء وتوليد',
    'نفس': 'نفسية',
    'عظم': 'عظام',
    'كسر': 'عظام',
    'طفل': 'أطفال',
    'سن': 'أسنان',
    'عين': 'عيون',
    'أذن': 'أذن أنف حنجرة',
    'طوارئ': 'طوارئ',
  };

  CvReportBundle compile({
    required HealthProfile profile,
    required LocalKnowledge knowledge,
    List<Map<String, dynamic>> cameraNotes = const [],
    List<Map<String, dynamic>> vault = const [],
  }) {
    final answers = profile.questionnaireData;
    final clues = <String>[];
    final body = StringBuffer();
    body.writeln('سي في صاحب الحساب — تعبئة صوت أو كتابة بلغته.');
    body.writeln('الختم: ${AppConstants.appName} | ${AppConstants.studioBannerCredit}');
    body.writeln();
    for (final section in HealthQuestionnaireSchema.sections) {
      var any = false;
      final chunk = StringBuffer();
      for (final field in section.fields) {
        final value = answers[field.key];
        if (value == null || value.toString().trim().isEmpty || value == false) {
          continue;
        }
        if (value == true) {
          chunk.writeln('${field.label}: نعم');
        } else {
          chunk.writeln('${field.label}: $value');
        }
        clues.add(value.toString());
        any = true;
      }
      if (any) {
        body.writeln(section.title);
        body.write(chunk);
        body.writeln();
      }
    }
    if (cameraNotes.isNotEmpty) {
      body.writeln('أوراق الكاميرا الذكية (مسارات محلية):');
      for (final note in cameraNotes) {
        body.writeln('- ${note['title']}: ${note['detail'] ?? note['path']}');
        clues.add('${note['title']} ${note['detail']}');
      }
      body.writeln();
    }
    if (vault.isNotEmpty) {
      body.writeln('وثائق السي في المغلفة محلياً: ${vault.length} (بلا رفع تلقائي).');
    }
    final photoHints = [
      answers['photoNotes'],
      answers['photoBedsore'],
      answers['photoTongue'],
      answers['photoSkin'],
      answers['photoHair'],
      answers['photoVessel'],
    ].where((item) => item != null).map((item) => item.toString());
    clues.addAll(photoHints);

    final hits = knowledge.rankByEnteredClues(
      symptoms: clues.take(24).toList(),
      cameraHint: answers['photoNotes']?.toString(),
    );
    if (hits.isNotEmpty) {
      body.writeln('تقدير تقريبي من المرجع الداخلي (ليس تعرّفاً تاماً على البكسل):');
      for (final hit in hits.take(5)) {
        body.writeln('- ${hit.titleAr}: ${hit.detailAr}');
      }
    } else {
      body.writeln('لا مطابقة مرجعية كافية. لا اختراع حالة من الصورة.');
    }

    final specialty = _specialtyFrom(clues.join(' '));
    body.writeln();
    body.writeln('الاختصاص المقترح للمشاركة إن كان طبيباً: $specialty');
    body.writeln(
      'المشاركة: نسخ أو ورقة النظام إلى شخص أو طبيب أو طابعة. '
      'السحابة (درايف وغيرها) يختارها صاحب الحساب من تطبيقات جهازه.',
    );

    return CvReportBundle(
      report: StampedReport(profile: profile, bodyAr: body.toString()),
      specialtyAr: specialty,
      clueHits: hits,
      shareHintAr:
          'اقترح إرساله لمن تختاره: قريب، طبيب من ملفك، طابعة، أو سحابة حسابك. '
          'إن كان طبيباً فنفس الاختصاص ومن الأقرب فالأبعد حسب المسافة المسجّلة. '
          'GPS أولوية عند الإذن، بلا نقطة مختلقة.',
    );
  }

  List<Map<String, dynamic>> doctorsForSpecialty({
    required List<Map<String, dynamic>> doctors,
    required String specialtyAr,
  }) {
    return DoctorDirectory().nearestFirst(doctors, specialty: specialtyAr);
  }

  String _specialtyFrom(String blob) {
    final folded = blob.toLowerCase();
    for (final entry in _specialtyHints.entries) {
      if (folded.contains(entry.key.toLowerCase())) return entry.value;
    }
    return 'طب أسرة';
  }
}
