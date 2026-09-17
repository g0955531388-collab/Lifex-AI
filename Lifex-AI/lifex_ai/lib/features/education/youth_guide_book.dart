/// =============================================================
/// Lifex-AI — التأهيل
/// الملف: youth_guide_book.dart
/// دليل اليافعين بصياغة أصلية. توعوي، ليس علاجاً نفسياً ولا نسخ صفحة ويب.
/// =============================================================
library lifex_ai.features.education.youth_guide_book;

class YouthChapter {
  const YouthChapter({
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

class YouthSkillRow {
  const YouthSkillRow({
    required this.domainAr,
    required this.skillAr,
    required this.practiceAr,
  });

  final String domainAr;
  final String skillAr;
  final String practiceAr;
}

class YouthGuideBook {
  const YouthGuideBook();

  static const disclaimerAr =
      'دليل توعوي داخل رواق المعرفة. ليس علاجاً نفسياً ولا بديلاً عن مختص أو طبيب. '
      'القصص مركّبة بأسماء مستعارة، وليست ملفات مرضى.';

  List<YouthChapter> chapters() => const [
        YouthChapter(
          id: 'open',
          kickerAr: 'التقديم',
          titleAr: 'لماذا هذا الدليل',
          bodyAr:
              'اليافع ليس درساً يُلقى عليه، ولا بالغاً يُفترض أنه جاهز. '
              'هذا النص مرآة: هوية تتكون، انفعال أسرع من التخطيط، وشاشة تسحب الوقت. '
              'إشراف غازي سليم بكفلاوي وصياغة توعوية باسم أكاديمية الروح داخل ليفكس. '
              'لا أوامر جاهزة؛ فهم ثم اختيار.',
          bodyEn:
              'Adolescence is a workshop, not a lecture. This guide is a mirror: identity, emotion, and screens. Not therapy.',
        ),
        YouthChapter(
          id: 'method',
          kickerAr: 'المنهج',
          titleAr: 'كيف تقرأ الدليل',
          bodyAr:
              'عقلك في بناء كثيف. كل عادة اليوم تترك أثراً غداً. '
              'نمزج ملاحظة تنموية وخطوة عملية بلا إملاء. '
              'إن اشتد القلق أو الحزن أو الخطر فاطلب مختصاً أو بالغاً موثوقاً فوراً.',
          bodyEn:
              'Read as a young thinker. Practical steps, no commands. Persistent distress needs a real professional, not this screen.',
        ),
        YouthChapter(
          id: 'ch1',
          kickerAr: '01 الهوية',
          titleAr: 'من أنت دون قالب',
          bodyAr:
              'الهوية تُرسم بالتجربة والقيم لا بصورة الآخرين. '
              'استقلال فكري يعني سؤالاً قبل التقليد. '
              'يحق لك أن تغيّر رأيك حين تتعلم. لا تقارن بدايتك بنهايات الشاشات.',
          bodyEn:
              'Identity is built from values and experience, not from copying feeds. You may revise your views as you learn.',
        ),
        YouthChapter(
          id: 'ch2',
          kickerAr: '02 الانفعال',
          titleAr: 'قطار المشاعر',
          bodyAr:
              'شدة الانفعال في هذه المرحلة شائعة لأن مراكز العاطفة تسبق الضبط. '
              'الإدارة ليست كبتاً: تنفّس، انتظر لحظات، اكتب الشحنة، وأجّل القرار المصيري حتى تهدأ.',
          bodyEn:
              'Feelings run hot while control is still growing. Pause, breathe, write, and delay big decisions during peaks.',
        ),
        YouthChapter(
          id: 'ch3',
          kickerAr: '03 النمو',
          titleAr: 'القدرة تتدرّب',
          bodyAr:
              'العقلية الجامدة تقول: فشلت إذن أنا كذلك. عقلية النمو تقول: لست بارعاً بعد. '
              'الخطأ دليل محاولة لا دليل عجز.',
          bodyEn:
              'A growth stance treats skill as trainable. A mistake is practice, not a verdict on your worth.',
        ),
        YouthChapter(
          id: 'ch4',
          kickerAr: '04 القرار',
          titleAr: 'اختيار بخطوات',
          bodyAr:
              'سمّ المشكلة، اقترح أكثر من مخرج، زن العواقب القريبة والبعيدة، '
              'استشر من تثق بحكمته، ثم احمل النتيجة. الحظ ليس منهجاً.',
          bodyEn:
              'Name the problem, list exits, weigh near and far effects, consult a trusted adult, then own the outcome.',
        ),
        YouthChapter(
          id: 'ch5',
          kickerAr: '05 الصداقة',
          titleAr: 'قرب يحترم الحد',
          bodyAr:
              'الصديق يساند وينصح بلا إذلال. العلاقة السامة تبتز أو تسخر أو تجرّك إلى خطر لإثبات الانتماء. '
              'العدد أقل من الأمان.',
          bodyEn:
              'A real friend respects limits. Pressure, mockery, or danger-as-loyalty is not friendship.',
        ),
        YouthChapter(
          id: 'ch6',
          kickerAr: '06 الأمان',
          titleAr: 'التنمر والضغط',
          bodyAr:
              'التنمر عيب الفاعل لا الضحية. قول لا حق. إبلاغ بالغ موثوق شجاعة لا وشاية. '
              'احفظ دليلاً رقمياً إن وُجد، ولا تواجه المعتدي وحدك إن خفت.',
          bodyEn:
              'Bullying is the aggressor’s act. Saying no and telling a trusted adult is courage. Keep evidence. Do not face danger alone.',
        ),
        YouthChapter(
          id: 'ch7',
          kickerAr: '07 الرقمي',
          titleAr: 'ذكاء الشاشة',
          bodyAr:
              'لا تُرسل صوراً أو بيانات حسّاسة لغريب. كلمات سر مختلفة. '
              'عند ابتزاز: لا تدفع من الخوف، احفظ، وأخبر أهلاً أو جهة مختصة. '
              'أوقف الشاشة قبل النوم بوقت يكفي للجسم.',
          bodyEn:
              'Protect privacy, use strong separate passwords, report blackmail, and keep a sleep boundary with screens.',
        ),
        YouthChapter(
          id: 'ch8',
          kickerAr: '08 الذكاء الاصطناعي',
          titleAr: 'مساعد لا بديل عقل',
          bodyAr:
              'الأداة توسّع الفهم والتدرّب. إن كتبت عنك بالكامل ضاع تمرينك ونزاهتك. '
              'اسأل: ماذا فهمت أنا بعد الإجابة؟',
          bodyEn:
              'Use AI to learn, not to replace your thinking or honesty. After any answer, say what you understood yourself.',
        ),
        YouthChapter(
          id: 'ch9',
          kickerAr: '09 الوقت',
          titleAr: 'طاقة لا دقائق فقط',
          bodyAr:
              'ابدأ بالأهم فالصعب. قسّم العمل الكبير. استراحة قصيرة تجدد لا تسرق. '
              'الازدحام ليس إنجازاً.',
          bodyEn:
              'Manage energy and priority. Split large work. Short rest restores; busyness is not achievement.',
        ),
        YouthChapter(
          id: 'ch10',
          kickerAr: '10 المال',
          titleAr: 'حاجة ورغبة',
          bodyAr:
              'اقتطع ادخاراً صغيراً ثابتاً قبل الكماليات. اسأل: أعيش بهذا أم أشتهيه لأسبوع؟ '
              'ليس درساً استثمارياً ولا وعداً بالغنى.',
          bodyEn:
              'Save a small fixed share first. Separate need from want. This is not investment advice.',
        ),
        YouthChapter(
          id: 'ch11',
          kickerAr: '11 الجسد',
          titleAr: 'نوم وغذاء وحركة',
          bodyAr:
              'النوم المنتظم يغذي الدماغ. ماء وغذاء متوازن وحركة تفرّغ التوتر. '
              'أي ألم أو اضطراب مستمر يُعرض على طبيب، لا على هذا الفصل.',
          bodyEn:
              'Sleep, food, water and movement support mood and focus. Ongoing symptoms need a clinician.',
        ),
        YouthChapter(
          id: 'ch12',
          kickerAr: '12 النفس',
          titleAr: 'طلب المساعدة قوة',
          bodyAr:
              'الحزن العابر غير سيطرة الأفكار أو فقدان المتعة طويلاً. '
              'لا تبق وحدك. بالغ موثوق أو مختص. ليفكس لا يشخص ولا يعالج.',
          bodyEn:
              'Ask for help if distress lasts or dark thoughts take over. This app does not diagnose or treat.',
        ),
        YouthChapter(
          id: 'ch13',
          kickerAr: '13 النقد',
          titleAr: 'خبر قبل الغضب',
          bodyAr:
              'من كتب؟ لماذا؟ أين الدليل؟ لا تُعد نشر الإثارة قبل التثبت. '
              'عنوان صارخ ليس برهاناً.',
          bodyEn:
              'Check source, motive and evidence before sharing. Outrage is not proof.',
        ),
        YouthChapter(
          id: 'ch14',
          kickerAr: '14 المهارة',
          titleAr: 'الشغف بالتجربة',
          bodyAr:
              'الشغف يُكتشف بالمحاولة: لغة، حركة، صناعة، كتابة. '
              'مهارة اليوم رأس مال الغد في عالم تتبدل أدواته.',
          bodyEn:
              'Passion is found by trying. Skills you practice now travel with you as tools change.',
        ),
        YouthChapter(
          id: 'ch15',
          kickerAr: '15 الأسرة',
          titleAr: 'حوار الجيلين',
          bodyAr:
              'الأهل قد يقلقون من عالم لا يعرفونه. تكلم عن الحاجة بلا صراخ، واسمع الحرص خلف الأسلوب. '
              'الصمت الطويل يوسّع سوء الفهم.',
          bodyEn:
              'Speak needs calmly and hear care behind adult worry. Silence widens the gap.',
        ),
        YouthChapter(
          id: 'ch16',
          kickerAr: '16 الإخفاق',
          titleAr: 'درس لا نهاية',
          bodyAr:
              'رسوب أو خسارة بيانات للتحسين. الاستسلام هو التوقف. الخطأ حركة إن راجعته.',
          bodyEn:
              'A setback is information. Stopping is the only full stop.',
        ),
        YouthChapter(
          id: 'ch17',
          kickerAr: '17 البصمة',
          titleAr: 'أثر في المحيط',
          bodyAr:
              'مساعدة صغيرة، بيئة، تطوع مناسب للعمر: معنى خارج الشاشة. '
              'لا تُستغل باسم الخير؛ ابق مع جهة يعرفها أهلك.',
          bodyEn:
              'Small service gives meaning. Join only safe, family-known efforts. Do not be used in the name of good.',
        ),
        YouthChapter(
          id: 'ch18',
          kickerAr: '18 الغد',
          titleAr: 'خطوة رائد لا شعار',
          bodyAr:
              'المستقبل يُصنع بمهارة اليوم ونوم الليلة وخطة صغيرة ثابتة. '
              'احلم واعمل في نفس الأسبوع.',
          bodyEn:
              'The future is today’s skill plus rest plus one small kept plan.',
        ),
        YouthChapter(
          id: 's1',
          kickerAr: 'نافذة 1',
          titleAr: 'حين يتغيّر الصوت والجسد',
          bodyAr:
              'نبيل سمع صوته ينكسر في الصف فضحك ثم خاف. هدى لم تعد تشبه صورها القديمة. '
              'ليس عيباً أن يكبر الجسد قبل أن يلحق الفهم. القبول خطوة أولى لا تجاهل.',
          bodyEn:
              'Voice and body change before understanding catches up. Acceptance is a first step, not denial.',
        ),
        YouthChapter(
          id: 's2',
          kickerAr: 'نافذة 2',
          titleAr: 'المرآة والمقارنة',
          bodyAr:
              'آية قاست وجهها بوجوه لا تنام. كنان عدّ طوله بين الأصدقاء. '
              'المقارنة تسرق الثقة. الجسد ينضج وفقه لا وفق الخوارزمية.',
          bodyEn:
              'Comparing a living face to a feed steals confidence. Bodies mature on their own clock.',
        ),
        YouthChapter(
          id: 's3',
          kickerAr: 'نافذة 3',
          titleAr: 'صداقة وحدود',
          bodyAr:
              'مزاح يؤلم ليس مزاحاً إن تكرر بعد أن قلت توقف. '
              'الانسحاب من رفقة تجرّ إلى ما لا يشبه بيتك نجاة لا خسارة.',
          bodyEn:
              'Repeated hurt after you said stop is not a joke. Leaving a crowd that pulls you off your values is protection.',
        ),
        YouthChapter(
          id: 's4',
          kickerAr: 'نافذة 4',
          titleAr: 'الأهل بين الحب وسوء الفهم',
          bodyAr:
              'صرخة البيت قد تكون خوفاً لا رفضاً لك. اطلب مساحة للكلام في هدوء. '
              'إن كان عنف أو إذلال فالأولوية سلامتك عبر بالغ آخر موثوق.',
          bodyEn:
              'Family noise is often fear. Speak in a calm window. If there is violence, safety via another trusted adult comes first.',
        ),
        YouthChapter(
          id: 's5',
          kickerAr: 'نافذة 5',
          titleAr: 'المدرسة ليست رقمك',
          bodyAr:
              'العلامة ورقة. الخوف من الامتحان يُدار بالتحضير والتنفس لا بالهروب. '
              'معلّم كلمة طيبة قد يثبتك؛ اطلب الدعم الدراسي إن تعثرت.',
          bodyEn:
              'A mark is not a person. Exam fear needs preparation and breath. Ask for academic help when stuck.',
        ),
        YouthChapter(
          id: 's6',
          kickerAr: 'نافذة 6',
          titleAr: 'أنا على الشاشة',
          bodyAr:
              'حساب قوي وشخص خجول في الغرفة انقسام يُردم بالصدق مع النفس. '
              'تعليق جارح يُحظر ويُبلَّغ. خمس دقائق تصير ليلاً إن لم تضع حدّاً.',
          bodyEn:
              'A bold profile and a shy room need honesty. Block abuse. Time limits stop a five-minute scroll from eating the night.',
        ),
        YouthChapter(
          id: 's7',
          kickerAr: 'نافذة 7',
          titleAr: 'الإعجاب دون ضياع',
          bodyAr:
              'خفقان أول تجربة فهم لا عقد. من يضيع دراسته وراحته في اسم ليس حباً صحياً. '
              'لا تقايض صورتك أو سرك لإثبات المشاعر.',
          bodyEn:
              'First liking is learning, not a contract. Love that erases rest or privacy is not safe.',
        ),
        YouthChapter(
          id: 's8',
          kickerAr: 'نافذة 8',
          titleAr: 'قلق يطلب يداً',
          bodyAr:
              'قلب يركض وأنت واقف قد يكون قلقاً. حزن بلا سبب يستحق أن يُقال. '
              'كتابة رسالة ولو لم تُرسل تُفرّغ. طلب المساعدة من أم أو مرشد قوة. '
              'إن خطر على نفسك اطلب طوارئ حقيقية لا الشاشة.',
          bodyEn:
              'Name the feeling. Writing helps. Ask a trusted adult. If you are in danger, use real emergency services.',
        ),
        YouthChapter(
          id: 'pact',
          kickerAr: 'الميثاق',
          titleAr: 'عهد اليافع لنفسه',
          bodyAr:
              'أعاهد نفسي ألا أُسلّم وقتي للشاشات بلا حد، ولا عقلي للشائعة، ولا كرامتي للسخرية. '
              'أدرّب مهارة، أحمي نوماً، أطلب عوناً حين أثقل، وأصعد على الخطأ بدل أن أسكن فيه.',
          bodyEn:
              'I will bound screens, check claims, protect dignity, practice a skill, sleep, and ask for help when load is heavy.',
        ),
        YouthChapter(
          id: 'sources',
          kickerAr: 'التوثيق',
          titleAr: 'إطار عام لا بروتوكول',
          bodyAr:
              'صياغة ليفكس مستأنسة بإطار صحة المراهقين العام وبناء المهارات الحياتية. '
              'ليست نشرة منظمة ولا وصفة سريرية.',
          bodyEn:
              'Educational framing only. Not a clinical protocol and not an official agency circular.',
        ),
      ];

  List<YouthSkillRow> skillMap() => const [
        YouthSkillRow(
          domainAr: 'وعي',
          skillAr: 'قيم وهوية',
          practiceAr: 'اكتب ثلاث قيم لا تتنازل عنها هذا الأسبوع',
        ),
        YouthSkillRow(
          domainAr: 'انفعال',
          skillAr: 'وقف قبل الرد',
          practiceAr: 'خمس أنفاس قبل أي رد حاد',
        ),
        YouthSkillRow(
          domainAr: 'نقد',
          skillAr: 'فحص الخبر',
          practiceAr: 'لا تشارك قبل مصدر ودليل',
        ),
        YouthSkillRow(
          domainAr: 'رقمي',
          skillAr: 'خصوصية',
          practiceAr: 'لا صورة حسّاسة لغريب، حدّ ليلي للشاشة',
        ),
        YouthSkillRow(
          domainAr: 'موارد',
          skillAr: 'وقت ومال صغير',
          practiceAr: 'مهمة واحدة أولاً وادخار رمزي إن وُجد دخل',
        ),
        YouthSkillRow(
          domainAr: 'مرونة',
          skillAr: 'التعلم من الخطأ',
          practiceAr: 'سجّل درساً واحداً بعد كل تعثر',
        ),
      ];

  List<YouthChapter> search(String query) {
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
