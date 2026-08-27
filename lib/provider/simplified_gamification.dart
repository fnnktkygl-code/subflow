// lib/provider/simplified_gamification.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serene Japandi Financial Mindfulness & Habit System
/// Replaces arcade badges with calm, reflective milestones.
class SimplifiedGamification extends ChangeNotifier {
  int _xp = 0;
  int _streak = 0;
  DateTime _lastCheckIn = DateTime.fromMillisecondsSinceEpoch(0);
  bool _hasClaimedToday = false;

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
    if (lvl < 3) return 'Mindful Starter 🌱';
    if (lvl < 5) return 'Clarity Seeker 🌊';
    if (lvl < 8) return 'Financial Zen 🎋';
    if (lvl < 12) return 'Serene Master 🌸';
    return 'Zen Luminary ☀️';
  }

  // 3 Serene Mindfulness Milestones
  List<Achievement> get achievements => [
    Achievement(
      title: 'Mindful Foundations',
      description: 'Track 5 subscriptions with clarity',
      icon: Icons.spa_rounded,
      color: const Color(0xFF477A56),
      current: _xp ~/ 10,
      target: 5,
    ),
    Achievement(
      title: 'Consistency Flow',
      description: 'Maintain a 7-day clarity streak',
      icon: Icons.water_drop_rounded,
      color: const Color(0xFF3B6E8C),
      current: _streak,
      target: 7,
    ),
    Achievement(
      title: 'Spending Harmony',
      description: 'Reach Level 5 in financial awareness',
      icon: Icons.wb_sunny_rounded,
      color: const Color(0xFFC4823F),
      current: level,
      target: 5,
    ),
  ];

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

  void awardXP(int points, [String? reason]) {
    _xp += points;
    _saveState();
    notifyListeners();
  }

  void claimDailyReward() {
    if (_hasClaimedToday) return;

    const baseReward = 10;
    final streakBonus = (_streak / 7).floor() * 5;
    final totalReward = baseReward + streakBonus;

    awardXP(totalReward, 'Daily mindfulness reflection');
    _hasClaimedToday = true;
    _saveState();
  }

  void onSubscriptionAdded() => awardXP(10, 'Added subscription');
  void onSubscriptionDeleted(double monthlySaving) =>
      awardXP(25 + (monthlySaving * 2).toInt(), 'Mindful commitment trimmed');

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
