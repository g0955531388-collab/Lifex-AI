import 'package:flutter_test/flutter_test.dart';
import 'package:lifex_ai/features/family/marriage_request_ledger.dart';
import 'package:lifex_ai/features/profile/health_profile.dart';
import 'package:lifex_ai/features/qiran/qiran_engine.dart';

HealthProfile _p(
  String id,
  String name, {
  BloodType blood = BloodType.oPositive,
  List<String>? family,
  List<ChronicConditionRecord>? chronic,
}) {
  return HealthProfile(
    profileId: id,
    fullName: name,
    dateOfBirth: DateTime(1995, 1, 1),
    bloodType: blood,
    linkedFamilyProfileIds: family,
    chronicConditions: chronic,
  );
}

void main() {
  const engine = QiranEngine();

  test('قبل موافقة الزواج لا نسبة ولا أمراض', () {
    final a = _p('a', 'أحمد');
    final b = _p('b', 'فاطمة');
    final request = MarriageRequestLedger().send(from: a, to: b);
    final verdict = engine.verdict(a: a, b: b, request: request);
    expect(verdict.ready, isFalse);
    expect(engine.sealedReasons(a: a, b: b, request: request), isEmpty);
  });

  test('بعد الموافقة: مناسب أو غير مناسب ونسبة فقط بلا أسماء أمراض', () {
    final a = _p(
      'a',
      'أحمد',
      family: ['b'],
      chronic: [
        ChronicConditionRecord(
          conditionName: 'السكري',
          diagnosedAt: DateTime(2010, 1, 1),
        ),
      ],
    );
    final b = _p(
      'b',
      'فاطمة',
      family: ['a'],
      chronic: [
        ChronicConditionRecord(
          conditionName: 'السكري',
          diagnosedAt: DateTime(2012, 1, 1),
        ),
      ],
    );
    final ledger = MarriageRequestLedger();
    final sent = ledger.send(from: a, to: b);
    final accepted = ledger.setStatus(
      from: a,
      to: b,
      requestId: sent.id,
      status: MarriageRequestStatus.accepted,
    )!;
    final verdict = engine.verdict(a: a, b: b, request: accepted);
    expect(verdict.ready, isTrue);
    expect(verdict.percent, inInclusiveRange(0, 100));
    expect(verdict.publicAr.contains('مناسب'), isTrue);
    expect(verdict.publicAr.contains('سكري'), isFalse);
    expect(engine.sealedReasons(a: a, b: b, request: accepted), isEmpty);
    expect(engine.canAskReason(verdict), isTrue);

    final asked = ledger.askReason(
      from: a,
      to: b,
      requestId: accepted.id,
      askerId: a.profileId,
    )!;
    expect(engine.sealedReasons(a: a, b: b, request: asked), isEmpty);

    final opened = ledger.answerReason(
      from: a,
      to: b,
      requestId: accepted.id,
      accept: true,
    )!;
    final reasons = engine.sealedReasons(a: a, b: b, request: opened);
    expect(reasons, isNotEmpty);
    expect(reasons.join().contains('سكري'), isFalse);
  });

  test('طلب الطرف الثاني يُعد موافقة معاكسة باتجاهين', () {
    final a = _p('a', 'أحمد');
    final b = _p('b', 'فاطمة');
    final ledger = MarriageRequestLedger();
    ledger.send(from: a, to: b);
    final accepted = ledger.send(from: b, to: a);
    expect(accepted.status, MarriageRequestStatus.accepted);
    expect(ledger.pairOf(a, b)?.status, MarriageRequestStatus.accepted);
  });
}
