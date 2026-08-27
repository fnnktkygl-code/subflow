import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subflow_app/provider/simplified_gamification.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Simplified Gamification Engine Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initializes with default starting metrics', () {
      final gamification = SimplifiedGamification();
      expect(gamification.xp, equals(0));
      expect(gamification.level, equals(1));
      expect(gamification.streak, equals(0));
      expect(gamification.levelTitle, contains('Mindful Starter'));
      expect(gamification.xpToNextLevel, equals(100));
      expect(gamification.hasClaimedToday, isFalse);
    });

    test('calculates level progression and titles correctly based on XP', () {
      final gamification = SimplifiedGamification();

      // 0-99 XP = Level 1 (Starter)
      gamification.awardXP(50);
      expect(gamification.level, equals(1));
      expect(gamification.levelTitle, contains('Mindful Starter'));
      expect(gamification.xpToNextLevel, equals(50));

      // 100-199 XP = Level 2 (Starter)
      gamification.awardXP(50);
      expect(gamification.level, equals(2));
      expect(gamification.xpToNextLevel, equals(100));

      // 300 XP = Level 4 (Clarity Seeker)
      gamification.awardXP(200);
      expect(gamification.level, equals(4));
      expect(gamification.levelTitle, contains('Clarity Seeker'));

      // 500 XP = Level 6 (Financial Zen)
      gamification.awardXP(200);
      expect(gamification.level, equals(6));
      expect(gamification.levelTitle, contains('Financial Zen'));

      // 800 XP = Level 9 (Serene Master)
      gamification.awardXP(300);
      expect(gamification.level, equals(9));
      expect(gamification.levelTitle, contains('Serene Master'));

      // 1200 XP = Level 13 (Zen Luminary)
      gamification.awardXP(400);
      expect(gamification.level, equals(13));
      expect(gamification.levelTitle, contains('Zen Luminary'));
    });

    test('awards daily reward and blocks duplicate claims on same day', () {
      final gamification = SimplifiedGamification();

      gamification.claimDailyReward();
      expect(gamification.hasClaimedToday, isTrue);
      final xpAfterFirstClaim = gamification.xp;
      expect(xpAfterFirstClaim, greaterThan(0));

      // Second claim attempt should do nothing
      gamification.claimDailyReward();
      expect(gamification.xp, equals(xpAfterFirstClaim));
    });

    test('awards bonus XP on subscription events', () {
      final gamification = SimplifiedGamification();

      gamification.onSubscriptionAdded();
      expect(gamification.xp, equals(10));

      // Deleting a 15€/month sub awards 25 + (15 * 2) = 55 XP
      gamification.onSubscriptionDeleted(15.0);
      expect(gamification.xp, equals(65));
    });

    test('evaluates achievements progress and unlock status', () {
      final gamification = SimplifiedGamification();
      final achievements = gamification.achievements;

      expect(achievements.length, equals(3));
      final mindfulFoundations = achievements.firstWhere((a) => a.title == 'Mindful Foundations');
      final consistencyFlow = achievements.firstWhere((a) => a.title == 'Consistency Flow');
      final spendingHarmony = achievements.firstWhere((a) => a.title == 'Spending Harmony');

      expect(mindfulFoundations.isUnlocked, isFalse);
      expect(mindfulFoundations.progress, closeTo(0.0, 0.01));
      expect(consistencyFlow.isUnlocked, isFalse);
      expect(spendingHarmony.isUnlocked, isFalse);

      // Award 500 XP (Level 6) -> Unlocks Mindful Foundations & Spending Harmony
      gamification.awardXP(500);
      final updatedAchievements = gamification.achievements;
      final updatedMindfulFoundations = updatedAchievements.firstWhere((a) => a.title == 'Mindful Foundations');
      final updatedSpendingHarmony = updatedAchievements.firstWhere((a) => a.title == 'Spending Harmony');

      expect(updatedMindfulFoundations.isUnlocked, isTrue);
      expect(updatedSpendingHarmony.isUnlocked, isTrue);
      expect(updatedSpendingHarmony.progress, equals(1.0));
    });
  });
}
