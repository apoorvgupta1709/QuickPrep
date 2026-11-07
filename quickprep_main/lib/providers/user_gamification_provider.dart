import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class UserGamificationProvider extends ChangeNotifier {
  int _currentStreak = 1;
  int _streakFreezeCount = 1;
  int _xpScore = 0;
  bool _isPro = false;
  DateTime? _lastActiveDate;

  int get currentStreak => _currentStreak;
  int get streakFreezeCount => _streakFreezeCount;
  int get xpScore => _xpScore;
  bool get isPro => _isPro;
  DateTime? get lastActiveDate => _lastActiveDate;

  UserGamificationProvider() {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _currentStreak = prefs.getInt('quickprep_streak') ?? 1;
    _streakFreezeCount = prefs.getInt('quickprep_freeze_count') ?? 1;
    _xpScore = prefs.getInt('quickprep_xp') ?? 0;
    _isPro = prefs.getBool('quickprep_is_pro') ?? false;

    final lastActiveStr = prefs.getString('quickprep_last_active');
    if (lastActiveStr != null) {
      _lastActiveDate = DateTime.tryParse(lastActiveStr);
    }

    _evaluateDailyStreak();
    notifyListeners();
  }

  void _evaluateDailyStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastActiveDate == null) {
      _lastActiveDate = today;
      _saveState();
      return;
    }

    final lastDate = DateTime(
      _lastActiveDate!.year,
      _lastActiveDate!.month,
      _lastActiveDate!.day,
    );

    final differenceInDays = today.difference(lastDate).inDays;

    if (differenceInDays == 0) {
      // Already active today, streak intact
      return;
    } else if (differenceInDays == 1) {
      // Consecutive day! Advance streak
      _currentStreak++;
      _lastActiveDate = today;
      addXp(AppConstants.xpDailyStreakBonus);
    } else if (differenceInDays > 1) {
      // Missed one or more days
      if (_streakFreezeCount > 0) {
        // Automatically consume a streak freeze to protect streak!
        _streakFreezeCount--;
        _lastActiveDate = today;
      } else {
        // Reset streak to 1
        _currentStreak = 1;
        _lastActiveDate = today;
      }
    }

    _saveState();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quickprep_streak', _currentStreak);
    await prefs.setInt('quickprep_freeze_count', _streakFreezeCount);
    await prefs.setInt('quickprep_xp', _xpScore);
    await prefs.setBool('quickprep_is_pro', _isPro);
    if (_lastActiveDate != null) {
      await prefs.setString(
          'quickprep_last_active', _lastActiveDate!.toIso8601String());
    }
  }

  void addXp(int points) {
    _xpScore += points;
    _saveState();
    notifyListeners();
  }

  void addStreakFreeze([int count = 1]) {
    _streakFreezeCount += count;
    _saveState();
    notifyListeners();
  }

  bool restoreStreakWithFreeze() {
    if (_streakFreezeCount > 0) {
      _streakFreezeCount--;
      _currentStreak++;
      _saveState();
      notifyListeners();
      return true;
    }
    return false;
  }

  void setProStatus(bool pro) {
    _isPro = pro;
    _saveState();
    notifyListeners();
  }
}
