// =============================================================
// Lifex-AI — اختبارات الوحدة
// الملف: persistence_trial_test.dart
// المسار: test/features/persistence_trial_test.dart
// =============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:lifex_ai/core/app_constants.dart';
import 'package:lifex_ai/core/local_knowledge.dart';
import 'package:lifex_ai/core/trial_manager.dart';
import 'package:lifex_ai/features/doctors/pharmacy_locator.dart';
import 'package:lifex_ai/features/profile/health_profile.dart';
import 'package:lifex_ai/features/profile/multi_profile_engine.dart';
import 'package:lifex_ai/features/profile/profile_vault.dart';
import 'package:lifex_ai/features/voice/command_parser.dart';
import 'package:lifex_ai/features/women_health/female_cycle_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfileVault', () {
    test('يحفظ ويستعيد الملف النشط والاستبيان', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final vault = ProfileVault(prefs);
      final engine = MultiProfileEngine(maxProfiles: 4);
      final profile = HealthProfile(
        profileId: 'p-persist',
        fullName: 'غازي',
        dateOfBirth: DateTime(1990, 1, 1),
      );
      profile.questionnaireData['pharmacyStock'] = [
        {'title': 'باراسيتامول', 'quantity': '2'},
      ];
      engine.addProfile(profile, role: ProfileRole.primaryOwner);
      await vault.save(engine);

      final restored = MultiProfileEngine(maxProfiles: 4);
      await vault.loadInto(restored);
      expect(restored.activeProfileId, 'p-persist');
      expect(restored.activeProfile!.fullName, 'غازي');
      expect(
        restored.activeProfile!.questionnaireData['pharmacyStock'],
        isNotEmpty,
      );
    });
  });

  group('TrialManager و SessionAccessPolicy', () {
    test('التجربة مفتوحة قبل ثلاثين يوماً', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final trial = TrialManager(prefs);
      expect(trial.phase, TrialPhase.full);
      expect(trial.emergencyAndBloodOnly, isFalse);
    });

    test('بعد انتهاء التجربة تبقى الطوارئ والدم والمحفظة', () async {
      SharedPreferences.setMockInitialValues({
        'lifex_installed_at': DateTime.now()
            .subtract(const Duration(days: AppConstants.trialPeriodDays + 1))
            .toIso8601String(),
      });
      final prefs = await SharedPreferences.getInstance();
      final trial = TrialManager(prefs);
      expect(trial.emergencyAndBloodOnly, isTrue);
      const policy = SessionAccessPolicy();
      expect(
        policy.canOpenUnit('emergency', expired: true, feeExempt: false),
        isTrue,
      );
      expect(
        policy.canOpenUnit('blood', expired: true, feeExempt: false),
        isTrue,
      );
      expect(
        policy.canOpenUnit('wallet', expired: true, feeExempt: false),
        isTrue,
      );
      expect(
        policy.canOpenUnit('settings', expired: true, feeExempt: false),
        isTrue,
      );
      expect(
        policy.canOpenUnit('box', expired: true, feeExempt: false),
        isFalse,
      );
      expect(
        policy.canOpenUnit('box', expired: true, feeExempt: true),
        isTrue,
      );
    });
  });

  group('LocalKnowledge', () {
    test('يبحث في الأمراض والأدوية', () {
      final knowledge = LocalKnowledge(
        diseases: [
          {
            'nameAr': 'ارتفاع ضغط الدم الشرياني',
            'nameEn': 'hypertension',
            'generalInfoAr': 'مرجع توعية',
          },
        ],
        medications: [
          {'nameAr': 'باراسيتامول', 'nameEn': 'paracetamol'},
        ],
        symptoms: const [],
        tests: const [],
        disclaimerAr: 'مرجع توعية فقط. ليس تشخيصاً.',
      );
      final hits = knowledge.search('ضغط');
      expect(hits, isNotEmpty);
      expect(hits.first.titleAr, contains('ضغط'));
      expect(knowledge.search('باراسيتامول').first.kindAr, 'دواء');
    });
  });

  group('PharmacyLocator', () {
    test('يرجع الأقرب في نفس المدينة مع كمية موجبة', () {
      final hits = PharmacyLocator().nearestWithDrug(
        stock: [
          {
            'title': 'بعيد',
            'city': 'دمشق',
            'km': '9',
            'quantity': '4',
            'barcode': '1',
          },
          {
            'title': 'قريب',
            'city': 'دمشق',
            'km': '1',
            'quantity': '3',
            'barcode': '2',
          },
          {
            'title': 'نفد',
            'city': 'دمشق',
            'km': '0.5',
            'quantity': '0',
            'barcode': '3',
          },
        ],
        query: '',
        city: 'دمشق',
      );
      expect(hits.first['title'], 'قريب');
      expect(hits, hasLength(2));
    });
  });

  group('موعد الولادة من آخر دورة', () {
    test('يضيف 280 يوماً', () {
      final due = FemaleCycleTracker.estimatedDueFromLmp(DateTime(2026, 1, 1));
      expect(due, DateTime(2026, 10, 8));
    });
  });

  group('CommandParser', () {
    test('يفتح البحث والصيدلية', () {
      final parser = CommandParser();
      expect(parser.parse('ابحث عن دواء').intent, VoiceCommandIntent.openSearch);
      expect(parser.parse('افتح الصيدلية').intent, VoiceCommandIntent.openPharmacy);
    });
  });
}
