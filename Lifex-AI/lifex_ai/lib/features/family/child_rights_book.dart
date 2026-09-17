/// =============================================================
/// Lifex-AI — الأسرة والطفل
/// الملف: child_rights_book.dart
/// كتاب توعوي من التكوين إلى الشباب. ليس فتوى ولا قانون دولة ولا تشخيصاً.
/// =============================================================
library lifex_ai.features.family.child_rights_book;

class ChildRightsChapter {
  const ChildRightsChapter({
    required this.id,
    required this.kickerAr,
    required this.titleAr,
    required this.bodyAr,
    required this.bodyEn,
  });

  final String id;
  final String kickerAr;
  final String titleAr;
  final String bodyAr;
  final String bodyEn;

  String spoken({required bool english}) =>
      english ? '$titleAr. $bodyEn' : '$kickerAr. $titleAr. $bodyAr';
}

class ChildRightsRow {
  const ChildRightsRow({
    required this.kindAr,
    required this.examplesAr,
    required this.familyDutyAr,
  });

  final String kindAr;
  final String examplesAr;
  final String familyDutyAr;
}

class ChildRightsBook {
  const ChildRightsBook();

  static const disclaimerAr =
      'عمل توعوي داخل ليفكس. لا يحل محل طبيب أو مختص نفسي أو محامٍ أو فتوى. '
      'القانون يختلف بحسب الدولة.';

  List<ChildRightsChapter> chapters() => const [
        ChildRightsChapter(
          id: 'intro',
          kickerAr: 'الرؤية',
          titleAr: 'المقدمة والمنهج',
          bodyAr:
              'الطفل إنسان كامل الكرامة، لا ملك للأهل ولا مشروع لأمانيهم. '
              'تبدأ المسؤولية قبل الحمل، وتمتد إلى الشباب. '
              'نفرّق بين حق أخلاقي وحق قانوني ومعلومة طبية. '
              'مصلحة الطفل وسلامته معيار كل قرار يمسّه.',
          bodyEn:
              'A child is a person with dignity, not property. Family duty starts before pregnancy and continues into youth. Legal rights vary by country.',
        ),
        ChildRightsChapter(
          id: 'ch1',
          kickerAr: '01 الأسرة قبل الطفل',
          titleAr: 'مسؤولية اختيار الشريك',
          bodyAr:
              'السؤال ليس الحب وحده: هل البيت آمن؟ هل الحوار ممكن؟ هل يُحمَّل الطفل ثمن صراع الكبار؟ '
              'اتفاق التربية، خطة سكن وغذاء وصحة وتعليم، ورفض العنف.',
          bodyEn:
              'Choosing a partner includes safety, dialogue, non-violence and a realistic plan for care. A child is never a tool in adult conflict.',
        ),
        ChildRightsChapter(
          id: 'ch2',
          kickerAr: '02 البيت',
          titleAr: 'تأسيس المنزل الآمن',
          bodyAr:
              'الأمان جدران ولغة ونوم ونظافة. منع الحريق والسقوط والتسمم. '
              'لا ضرب ولا إذلال ولا جعل الطفل شاهداً دائماً على نزاع الكبار.',
          bodyEn:
              'A safe home is physical and emotional: hazards prevented, sleep and hygiene, no humiliation, limited exposure to adult conflict.',
        ),
        ChildRightsChapter(
          id: 'ch3',
          kickerAr: '03 ما قبل الحمل',
          titleAr: 'الصحة قبل الحمل',
          bodyAr:
              'استشارة طبية عند الحاجة، مراجعة أدوية، غذاء، إبعاد التدخين والمواد الضارة، '
              'واستعداد نفسي ومالي. ليس وصفة حمل عامة.',
          bodyEn:
              'Preconception care is individual: medical review, nutrition, avoiding harm, and realistic preparation. Not a universal prescription.',
        ),
        ChildRightsChapter(
          id: 'ch4',
          kickerAr: '04 الحمل',
          titleAr: 'رعاية الحمل والجنين',
          bodyAr:
              'متابعة حمل مناسبة وصحة الأم. الوضع القانوني للجنين يختلف بين الدول. '
              'لا حكم فقهي عالمي من هذه الشاشة.',
          bodyEn:
              'Antenatal care and maternal health matter. Fetal legal status varies. This screen is not a fatwa.',
        ),
        ChildRightsChapter(
          id: 'ch5',
          kickerAr: '05 الميلاد',
          titleAr: 'الولادة والتسجيل والهوية',
          bodyAr:
              'توثيق الميلاد وفق القانون المحلي، سجلات تطعيم وصحة، احترام الاسم، '
              'وحماية الوثائق. الفقر أو الخلاف لا يعطّل حاجة الطفل.',
          bodyEn:
              'Birth registration, health records and identity follow local law. Adult disputes must not block a child’s basic documents.',
        ),
        ChildRightsChapter(
          id: 'ch6',
          kickerAr: '06 النمو',
          titleAr: 'التغذية والرضاعة والنمو',
          bodyAr:
              'الغذاء حق مرتبط بالتعلم. قرارات الرضاعة وفق صحة الأم والطفل وطبيب عند المشكلة. '
              'ليس بروتوكول إرضاع إلزامياً من التطبيق.',
          bodyEn:
              'Nutrition supports growth and learning. Feeding choices depend on mother and child health and clinical advice when needed.',
        ),
        ChildRightsChapter(
          id: 'ch7',
          kickerAr: '07 الصحة',
          titleAr: 'الوقاية والعلاج',
          bodyAr:
              'تطعيم وطني، نمو، أسنان، نوم وحركة. عند المرض رعاية مناسبة لعمره. '
              'لا تجارب خطرة بدل الطبيب.',
          bodyEn:
              'Prevention and timely care. Unsafe experiments must not replace professional treatment.',
        ),
        ChildRightsChapter(
          id: 'ch8',
          kickerAr: '08 الحماية',
          titleAr: 'الأمان من العنف والإهمال',
          bodyAr:
              'الإيذاء داخل الأسرة ليس مقبولاً. حماية من الضرب والاستغلال الرقمي والجنسي والإهمال. '
              'التأديب حدود بلا تحطيم الكرامة.',
          bodyEn:
              'Family status does not excuse violence. Discipline is not injury or humiliation.',
        ),
        ChildRightsChapter(
          id: 'ch9',
          kickerAr: '09 النفس',
          titleAr: 'الحق النفسي والعاطفي',
          bodyAr:
              'يُسمع ويُسمّى شعوره. لا مقارنة مهينة. مساعدة مختص إن استمر القلق أو تغيّر السلوك.',
          bodyEn:
              'Listen first. Name feelings. Seek a specialist if distress persists.',
        ),
        ChildRightsChapter(
          id: 'ch10',
          kickerAr: '10 الكرامة',
          titleAr: 'الخصوصية والجسد',
          bodyAr:
              'لا سخرية ولا صور مهينة. حدود الجسد والمعلومات الصحية. '
              'إشراف الوالدين للحماية لا تجسس مهين.',
          bodyEn:
              'Dignity covers the body, health files and images. Oversight for safety, not humiliating surveillance.',
        ),
        ChildRightsChapter(
          id: 'ch11',
          kickerAr: '11 المعرفة',
          titleAr: 'التعليم والتفكير',
          bodyAr:
              'قراءة وعلوم ومهارات وحياة أخلاقية. السؤال مسموح. الإذلال ليس تعليماً.',
          bodyEn:
              'Education includes literacy, science, ethics and questions. Humiliation is not a method.',
        ),
        ChildRightsChapter(
          id: 'ch12',
          kickerAr: '12 المادة',
          titleAr: 'الاحتياجات المادية',
          bodyAr:
              'غذاء وكسوة ومسكن آمن وصحة وتعليم حسب القدرة والقانون. '
              'النفقة ليست منّة. تفاصيلها للدولة لا للتطبيق.',
          bodyEn:
              'Basic needs are not optional favors. Detailed support law belongs to the country, not this app.',
        ),
        ChildRightsChapter(
          id: 'ch13',
          kickerAr: '13 الروابط',
          titleAr: 'الأسرة والانفصال الآمن',
          bodyAr:
              'روابط مستقرة إن كانت آمنة. في الانفصال لا رسول ولا انتقام عبر الطفل. الحماية أولاً عند الخطر.',
          bodyEn:
              'Safe bonds matter. In separation the child is not a messenger. Protection first if there is abuse.',
        ),
        ChildRightsChapter(
          id: 'ch14',
          kickerAr: '14 الرقمي',
          titleAr: 'الإنترنت والذكاء الاصطناعي',
          bodyAr:
              'حماية بيانات ومنع ابتزاز وتنمر. أوقات شاشة. لا إدخال بيانات حسّاسة في أدوات غير موثوقة. '
              'إجابة الآلة ليست حقيقة تلقائياً.',
          bodyEn:
              'Digital safety, privacy and literacy. AI answers are not automatically true. Sensitive child data stays cautious.',
        ),
        ChildRightsChapter(
          id: 'ch15',
          kickerAr: '15 المساواة',
          titleAr: 'الإعاقة وعدم التمييز',
          bodyAr:
              'الكرامة لا تسقط بإعاقة أو فقر أو أصل. المساواة قد تحتاج تيسيرًا إضافياً لإزالة الحاجز.',
          bodyEn:
              'Disability or poverty does not cancel rights. Equality may need accommodations.',
        ),
        ChildRightsChapter(
          id: 'ch16',
          kickerAr: '16 المراهقة',
          titleAr: 'النمو بين 10 و19',
          bodyAr:
              'المراهقة نمو لا تهمة تمرد. حماية مع مساحة قرار متزايدة. ليست سيطرة مطلقة.',
          bodyEn:
              'Adolescence is development. Protect while teaching independent safe choices.',
        ),
        ChildRightsChapter(
          id: 'ch17',
          kickerAr: '17 الصوت',
          titleAr: 'المشاركة وإبداء الرأي',
          bodyAr:
              'يُسمع بما يناسب عمره. الاستماع ليس أن يملك كل قرار نهائي.',
          bodyEn:
              'Being heard is not making every final decision. It is not being voiceless.',
        ),
        ChildRightsChapter(
          id: 'ch18',
          kickerAr: '18 الشباب',
          titleAr: 'نحو الاستقلال المسؤول',
          bodyAr:
              'الغاية إنسان يدير مالاً ووقتاً وصحة وعلاقات، ويطلب مساعدة بلا وصمة. الطاعة الأبدية ليست نجاحاً.',
          bodyEn:
              'The aim is responsible adulthood, not lifelong obedience.',
        ),
        ChildRightsChapter(
          id: 'conclusion',
          kickerAr: 'الميثاق',
          titleAr: 'الميثاق الأسري',
          bodyAr:
              'لا نجعل الطفل ضحية خلافنا ولا أداة كرامة أمام الناس. '
              'نسمع ونحمي ونعلّم، ونصحّح بلا تحطيم. الحماية تنمو معه من الرعاية إلى الإرشاد ثم الاستقلال.',
          bodyEn:
              'We will not use the child in adult conflict. Care, protection, education and a voice. Protection evolves toward independence.',
        ),
        ChildRightsChapter(
          id: 'sources',
          kickerAr: 'التوثيق',
          titleAr: 'المراجع بحدودها',
          bodyAr:
              'إطار توعوي يستأنس بمنظمة الصحة واليونيسف. الآيات في سياق حماية الحياة لا كفتوى. '
              'للقرار القانوني: تشريع محلي ومختص.',
          bodyEn:
              'Educational framing inspired by public health child-rights principles. Not a fatwa. Legal decisions need local law.',
        ),
      ];

  List<ChildRightsRow> matrix() => const [
        ChildRightsRow(
          kindAr: 'نفسية',
          examplesAr: 'أمان، استماع، بلا إذلال',
          familyDutyAr: 'بيئة مستقرة ومساعدة عند الحاجة',
        ),
        ChildRightsRow(
          kindAr: 'جسدية',
          examplesAr: 'غذاء ونوم وصحة وحماية من العنف',
          familyDutyAr: 'وقاية واستجابة للخطر',
        ),
        ChildRightsRow(
          kindAr: 'مادية',
          examplesAr: 'سكن وكسوة وتعليم وعلاج',
          familyDutyAr: 'أساسيات حسب القدرة والقانون',
        ),
        ChildRightsRow(
          kindAr: 'معنوية',
          examplesAr: 'اسم وهوية وسمعة',
          familyDutyAr: 'منع التشهير والتحقير',
        ),
        ChildRightsRow(
          kindAr: 'تعليمية',
          examplesAr: 'تعلم وسؤال ومهارات',
          familyDutyAr: 'بيئة تعلم بلا إذلال',
        ),
        ChildRightsRow(
          kindAr: 'اجتماعية',
          examplesAr: 'لعب وعلاقات آمنة',
          familyDutyAr: 'توجيه بلا عزل ضار',
        ),
        ChildRightsRow(
          kindAr: 'رقمية',
          examplesAr: 'خصوصية وأمان رقمي',
          familyDutyAr: 'إشراف متدرج لا تجسس مهين',
        ),
        ChildRightsRow(
          kindAr: 'مشاركة',
          examplesAr: 'إبداء رأي',
          familyDutyAr: 'إشراك وفق العمر',
        ),
      ];

  List<ChildRightsChapter> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return chapters();
    return chapters()
        .where(
          (c) =>
              c.titleAr.contains(query) ||
              c.bodyAr.contains(query) ||
              c.bodyEn.toLowerCase().contains(q) ||
              c.kickerAr.contains(query),
        )
        .toList();
  }
}
