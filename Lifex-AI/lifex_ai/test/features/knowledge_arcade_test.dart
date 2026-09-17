import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lifex_ai/features/education/choice_mirror_book.dart';
import 'package:lifex_ai/features/education/knowledge_arcade.dart';
import 'package:lifex_ai/features/education/personal_shelf.dart';
import 'package:lifex_ai/features/education/royal_intelligence.dart';
import 'package:lifex_ai/features/education/youth_guide_book.dart';
import 'package:lifex_ai/features/family/child_rights_book.dart';
import 'package:lifex_ai/features/profile/health_profile.dart';
import 'package:lifex_ai/features/voice/command_parser.dart';

void main() {
  test('رواق المعرفة يسمي خمس مكتبات وفيها كتب مقروءة ورف تنزيل', () {
    const arcade = KnowledgeArcade();
    expect(arcade.libraries(), hasLength(5));
    expect(arcade.libraries().map((l) => l.titleAr).toSet(), containsAll([
      'مكتبة الأسرة',
      'مكتبة اليافعين',
      'منصة الذكاء الملكي',
      'موسوعة التمكين',
      'رفّ التحميل الشخصي',
    ]));
    expect(arcade.bundledReadableCount(), greaterThanOrEqualTo(4));
    expect(
      arcade.libraries().last.volumes.single.kind,
      ArcadeVolumeKind.downloadShelf,
    );
  });

  test('دليل اليافعين يبحث وليس علاجاً', () {
    const book = YouthGuideBook();
    expect(book.chapters().length, greaterThanOrEqualTo(18));
    expect(book.search('هوية'), isNotEmpty);
    expect(YouthGuideBook.disclaimerAr, contains('ليس علاجاً'));
  });

  test('حقوق الطفل ما زالت تُبحث', () {
    expect(const ChildRightsBook().search('حمل'), isNotEmpty);
  });

  test('التمرين الملكي خمسون سؤالاً ويحسب الدرجة بلا ادعاء طبي', () {
    final session = RoyalIntelligenceSession.start(
      childMode: false,
      shuffle: false,
      useTimer: false,
      now: DateTime(2026, 9, 16, 21),
    );
    expect(session.items, hasLength(50));
    session.pick(0, session.items[0].correctIndex);
    final score = session.grade();
    expect(score.correct, 1);
    expect(score.total, 50);
    expect(RoyalIntelligenceBank.disclaimerAr, contains('ليس اختبار ذكاء'));
  });

  test('سياسة الرف ترفض غير https وتقبل غوتنبرغ', () {
    const policy = ShelfDownloadPolicy();
    expect(
      policy.rejectUri(Uri.parse('http://example.com/book.txt')),
      isNotNull,
    );
    expect(
      policy.rejectUri(Uri.parse(ShelfDownloadPolicy.hints.first.url)),
      isNull,
    );
    expect(policy.peelMarkup('<p>مرحبا</p>'), 'مرحبا');
  });

  test('حفظ كتاب منزّل ثم حذفه من الجهاز', () async {
    final profile = HealthProfile(
      profileId: 'p-shelf',
      fullName: 'اختبار',
      dateOfBirth: DateTime(1990, 1, 1),
    );
    final dir = await Directory.systemTemp.createTemp('lifex_shelf_');
    final store = PersonalShelfStore(profile, documentsOverride: dir);
    final kept = await store.keep(
      sourceUrl: 'https://example.com/a.txt',
      titleAr: 'نص تجريبي',
      body: 'جسم الكتاب المحلي',
      bytes: 20,
    );
    expect(store.kept(), hasLength(1));
    expect(await store.readBody(kept), 'جسم الكتاب المحلي');
    await store.drop(kept.id);
    expect(store.kept(), isEmpty);
    await dir.delete(recursive: true);
  });

  test('الأوامر تفتح الرواق والكتب والرف', () {
    final parser = CommandParser();
    expect(
      parser.parse('ليفكس رواق المعرفة').intent,
      VoiceCommandIntent.openKnowledgeArcade,
    );
    expect(
      parser.parse('دليل اليافعين').intent,
      VoiceCommandIntent.openYouthGuide,
    );
    expect(
      parser.parse('حقوق الطفل').intent,
      VoiceCommandIntent.openChildRights,
    );
    expect(
      parser.parse('الذكاء الملكي').intent,
      VoiceCommandIntent.openRoyalIntelligence,
    );
    expect(
      parser.parse('تنزيل كتاب').intent,
      VoiceCommandIntent.openPersonalShelf,
    );
    expect(
      parser.parse('مرآة الاختيار').intent,
      VoiceCommandIntent.openChoiceMirror,
    );
  });

  test('مرآة الاختيار تتبع الإنجليزية عند لغة الجهاز أو التطبيق', () {
    const book = ChoiceMirrorBook();
    expect(book.chapters(), hasLength(5));
    expect(book.search('حدس'), isNotEmpty);
    expect(
      ChoiceMirrorBook.usesEnglish(
        appLanguageCode: 'ar',
        deviceLanguageCode: 'en',
      ),
      isTrue,
    );
    expect(
      ChoiceMirrorBook.usesEnglish(
        appLanguageCode: 'ar',
        deviceLanguageCode: 'ar',
      ),
      isFalse,
    );
    expect(
      book.chapters().first.prompts.first.shown(english: true),
      contains('values'),
    );
    expect(ChoiceMirrorBook.disclaimerAr, contains('ليس علاجاً'));
  });
}
