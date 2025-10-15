import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SIMPLIFIED GAMIFICATION
// - Only essential features: XP, Level, Streak
// - 3 core achievements (not 10+)
// - Simple daily rewards (no complex quests)

class SimplifiedGamification extends ChangeNotifier {
  int _xp = 0;
  int _streak = 0;
  DateTime _lastCheckIn = DateTime.fromMillisecondsSinceEpoch(0);
  bool _hasClaimedToday = false;

  // Getters
  int get xp => _xp;
  int get level => (_xp / 100).floor() + 1;
  int get streak => _streak;
  String get levelTitle => _getLevelTitle(level);
  bool get hasClaimedToday => _hasClaimedToday;
  int get xpToNextLevel => ((level * 100) - _xp).clamp(0, 100);

  SimplifiedGamification() {
    _loadState();
  }

  String _getLevelTitle(int lvl) {
    if (lvl < 3) return 'Starter 🌱';
    if (lvl < 5) return 'Tracker 📊';
    if (lvl < 8) return 'Saver 💰';
    if (lvl < 12) return 'Master 👑';
    return 'Legend ⭐';
  }

  // SIMPLIFIED: Only 3 core achievements
  List<Achievement> get achievements => [
    Achievement(
      title: 'First Steps',
      description: 'Track 5 subscriptions',
      icon: Icons.looks_one,
      color: Colors.blue,
      current: _xp ~/ 10, // Simplified tracking
      target: 5,
    ),
    Achievement(
      title: 'Week Warrior',
      description: 'Maintain 7-day streak',
      icon: Icons.local_fire_department,
      color: Colors.orange,
      current: _streak,
      target: 7,
    ),
    Achievement(
      title: 'Budget Boss',
      description: 'Reach Level 5',
      icon: Icons.star,
      color: Colors.amber,
      current: level,
      target: 5,
    ),
  ];

  // Check daily activity (simplified)
  void checkDailyActivity() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(_lastCheckIn.year, _lastCheckIn.month, _lastCheckIn.day);

    if (today.isAfter(lastDay)) {
      if (today.difference(lastDay).inDays == 1) {
        _streak++;
      } else {
        _streak = 1;
      }
      _lastCheckIn = now;
      _hasClaimedToday = false;
      _saveState();
      notifyListeners();
    }
  }

  // Award XP (simplified)
  void awardXP(int points, [String? reason]) {
    _xp += points;
    _saveState();
    notifyListeners();
  }

  // Claim daily reward
  void claimDailyReward() {
    if (_hasClaimedToday) return;

    final baseReward = 10;
    final streakBonus = (_streak / 7).floor() * 5;
    final totalReward = baseReward + streakBonus;

    awardXP(totalReward, 'Daily check-in');
    _hasClaimedToday = true;
    _saveState();
  }

  // Track events (simplified)
  void onSubscriptionAdded() => awardXP(10, 'Added subscription');
  void onSubscriptionDeleted(double monthlySaving) => awardXP(25 + (monthlySaving * 2).toInt(), 'Saved money');

  // Persistence
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('xp', _xp);
    await prefs.setInt('streak', _streak);
    await prefs.setInt('lastCheckIn', _lastCheckIn.millisecondsSinceEpoch);
    await prefs.setBool('claimedToday', _hasClaimedToday);
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _xp = prefs.getInt('xp') ?? 0;
    _streak = prefs.getInt('streak') ?? 0;
    _lastCheckIn = DateTime.fromMillisecondsSinceEpoch(prefs.getInt('lastCheckIn') ?? 0);
    _hasClaimedToday = prefs.getBool('claimedToday') ?? false;
    notifyListeners();
  }
}

// Simple Achievement Model
class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int current;
  final int target;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.current,
    required this.target,
  });

  bool get isUnlocked => current >= target;
  double get progress => (current / target).clamp(0.0, 1.0);
}