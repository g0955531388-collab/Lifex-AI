/// =============================================================
/// Lifex-AI — التأهيل
/// الملف: empowerment_chapters.dart
/// فصول تمكين محلية. ليست استشارة مالية وليست نسخاً من صفحة ويب.
/// =============================================================
library lifex_ai.features.education.empowerment_chapters;

class EmpowermentChapter {
  const EmpowermentChapter({
    required this.id,
    required this.titleAr,
    required this.bodyAr,
  });

  final String id;
  final String titleAr;
  final String bodyAr;

  String spokenAr() => '$titleAr. $bodyAr';
}

class EmpowermentLibrary {
  const EmpowermentLibrary();

  List<EmpowermentChapter> chapters() => const [
        EmpowermentChapter(
          id: 'c1',
          titleAr: 'الفصل الأول: استحقاق القيمة لا الندرة',
          bodyAr:
              'في ليفكس نربط العمل الصحي بالقيمة التي تقدّمها، لا بالخوف من النقص. '
              'المال أداة تمكين إن استُخدم بصدق، وليس مقياساً للكرامة. '
              'ركّز على مهارة نافعة وعلى فرص حقيقية في جهازك، بلا وعود ثراء سريعة.',
        ),
        EmpowermentChapter(
          id: 'c2',
          titleAr: 'الفصل الثاني: الجوال كمختبر عمل',
          bodyAr:
              'الهاتف يستهلك الوقت أو يصنع أثراً. حدّد مهارة واحدة يحتاجها الناس، '
              'وابنِ سجلك داخل ليفكس بدل الاعتماد على منصة لا تملكها. '
              'الأتمتة هنا أوامر صوتية وسجلات محلية، وليست دخلاً مضموناً.',
        ),
        EmpowermentChapter(
          id: 'c3',
          titleAr: 'الفصل الثالث: الجسد وقوة القرار',
          bodyAr:
              'بلا نوم وغذاء ومتابعة صحية يضعف الحكم. ليفكس يجمع الملف الصحي '
              'مع خطة التعلّم حتى لا يُفصل الجسد عن العمل. الثراء بلا عافية فقر مؤجَّل. '
              'هذا تعليم تمكين، ليس وصفة استثمار ولا تشخيصاً.',
        ),
      ];
}
