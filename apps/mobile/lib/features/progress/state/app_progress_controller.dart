import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ProgressSyncState {
  localOnly,
  syncing,
  synced,
  failed,
}

class AppProgressController extends ChangeNotifier {
  AppProgressController({
    this.totalDays = 30,
    Iterable<int> completedDays = const <int>[],
    int currentStreakDays = 0,
    DateTime? lastCompletedAt,
    int xpPoints = 0,
    int dailyGoalMinutes = 10,
  })  : _completedDays = Set<int>.from(completedDays),
        _currentStreakDays = currentStreakDays,
        _lastCompletedAt = lastCompletedAt,
        _xpPoints = xpPoints,
        _dailyGoalMinutes = dailyGoalMinutes;

  static const _completedDaysKey = 'app_progress_completed_days';
  static const _currentStreakDaysKey = 'app_progress_current_streak_days';
  static const _lastCompletedAtKey = 'app_progress_last_completed_at';
  static const _xpPointsKey = 'app_progress_xp_points';
  static const _dailyGoalKey = 'app_progress_daily_goal';

  static Future<AppProgressController> load({int totalDays = 30}) async {
    final preferences = await SharedPreferences.getInstance();
    final storedDays =
        preferences.getStringList(_completedDaysKey) ?? const <String>[];

    final completedDays = storedDays
        .map(int.tryParse)
        .whereType<int>()
        .where((day) => day >= 1 && day <= totalDays)
        .toList()
      ..sort();
    final currentStreakDays = preferences.getInt(_currentStreakDaysKey) ?? 0;
    final lastCompletedAtRaw = preferences.getString(_lastCompletedAtKey);
    final lastCompletedAt = lastCompletedAtRaw == null
        ? null
        : DateTime.tryParse(lastCompletedAtRaw);
    final xpPoints = preferences.getInt(_xpPointsKey) ?? 0;
    final dailyGoalMinutes = preferences.getInt(_dailyGoalKey) ?? 10;

    return AppProgressController(
      totalDays: totalDays,
      completedDays: completedDays,
      currentStreakDays: currentStreakDays,
      lastCompletedAt: lastCompletedAt,
      xpPoints: xpPoints,
      dailyGoalMinutes: dailyGoalMinutes,
    );
  }

  final int totalDays;
  final Set<int> _completedDays;
  ProgressSyncState _syncState = ProgressSyncState.localOnly;
  DateTime? _lastServerSyncAt;
  int _currentStreakDays;
  DateTime? _lastCompletedAt;
  int _xpPoints;
  int _dailyGoalMinutes;

  int get completedDaysCount => _completedDays.length;
  ProgressSyncState get syncState => _syncState;
  DateTime? get lastServerSyncAt => _lastServerSyncAt;
  int get currentStreakDays => _currentStreakDays;
  DateTime? get lastCompletedAt => _lastCompletedAt;
  int get xpPoints => _xpPoints;
  int get dailyGoalMinutes => _dailyGoalMinutes;

  int get level => (_xpPoints / 100).floor() + 1;
  double get levelProgress => (_xpPoints % 100) / 100;

  int get currentDayNumber {
    for (var day = 1; day <= totalDays; day++) {
      if (!_completedDays.contains(day)) {
        return day;
      }
    }

    return totalDays;
  }

  bool isDayCompleted(int dayNumber) => _completedDays.contains(dayNumber);

  bool isDayUnlocked(int dayNumber) {
    return dayNumber <= currentDayNumber || isDayCompleted(dayNumber);
  }

  String statusForDay(int dayNumber) {
    if (isDayCompleted(dayNumber)) {
      return 'completed';
    }

    if (dayNumber == currentDayNumber) {
      return 'current';
    }

    return 'locked';
  }

  int progressPercentForDay(int dayNumber) {
    if (isDayCompleted(dayNumber)) {
      return 100;
    }

    if (dayNumber == currentDayNumber) {
      return 0;
    }

    return 0;
  }

  void completeDay(int dayNumber) {
    if (dayNumber < 1 || dayNumber > totalDays) {
      return;
    }

    if (!isDayUnlocked(dayNumber) || isDayCompleted(dayNumber)) {
      return;
    }

    _completedDays.add(dayNumber);
    final now = DateTime.now();
    final lastCompletionDate =
        _lastCompletedAt == null ? null : _dateOnly(_lastCompletedAt!);
    final today = _dateOnly(now);
    final yesterday = today.subtract(const Duration(days: 1));

    if (lastCompletionDate == today) {
      _currentStreakDays = _currentStreakDays == 0 ? 1 : _currentStreakDays;
    } else if (lastCompletionDate == yesterday) {
      _currentStreakDays += 1;
    } else {
      _currentStreakDays = 1;
    }

    _lastCompletedAt = now;
    _xpPoints += 50; // Give 50 XP for completing a day
    notifyListeners();
    _persistProgressSnapshot();
  }

  void addXp(int points) {
    _xpPoints += points;
    notifyListeners();
    _persistProgressSnapshot();
  }

  Future<void> setDailyGoal(int minutes) async {
    _dailyGoalMinutes = minutes;
    notifyListeners();
    await _persistProgressSnapshot();
  }

  Future<void> reset() async {
    _completedDays.clear();
    _currentStreakDays = 0;
    _lastCompletedAt = null;
    _xpPoints = 0;
    notifyListeners();
    await _persistProgressSnapshot();
  }

  Future<void> debugSetCurrentDay(int dayNumber) async {
    final targetDay = dayNumber.clamp(1, totalDays);
    _completedDays
      ..clear()
      ..addAll(List<int>.generate(targetDay - 1, (index) => index + 1));
    _currentStreakDays = 0;
    _lastCompletedAt = null;
    notifyListeners();
    await _persistProgressSnapshot();
  }

  Future<void> debugCompleteAllDays() async {
    _completedDays
      ..clear()
      ..addAll(List<int>.generate(totalDays, (index) => index + 1));
    _currentStreakDays = 0;
    _lastCompletedAt = null;
    notifyListeners();
    await _persistProgressSnapshot();
  }

  Future<void> syncCompletedDays(
    Iterable<int> completedDays, {
    bool replace = false,
  }) async {
    final normalizedDays =
        completedDays.where((day) => day >= 1 && day <= totalDays).toSet();

    if (replace) {
      _completedDays
        ..clear()
        ..addAll(normalizedDays);
    } else {
      _completedDays.addAll(normalizedDays);
    }

    notifyListeners();
    await _persistProgressSnapshot();
  }

  Future<void> syncFromSnapshot(
    Iterable<int> completedDays, {
    required int currentStreakDays,
    required DateTime? lastCompletedAt,
    bool replace = false,
  }) async {
    final normalizedDays =
        completedDays.where((day) => day >= 1 && day <= totalDays).toSet();

    if (replace) {
      _completedDays
        ..clear()
        ..addAll(normalizedDays);
    } else {
      _completedDays.addAll(normalizedDays);
    }

    _currentStreakDays = currentStreakDays;
    _lastCompletedAt = lastCompletedAt;
    notifyListeners();
    await _persistProgressSnapshot();
  }

  void markSyncing() {
    if (_syncState == ProgressSyncState.syncing) {
      return;
    }

    _syncState = ProgressSyncState.syncing;
    notifyListeners();
  }

  void markServerSynced({DateTime? syncedAt}) {
    _syncState = ProgressSyncState.synced;
    _lastServerSyncAt = syncedAt ?? DateTime.now();
    notifyListeners();
  }

  void markServerSyncFailed() {
    _syncState = ProgressSyncState.failed;
    notifyListeners();
  }

  Future<void> _persistProgressSnapshot() async {
    final preferences = await SharedPreferences.getInstance();
    final serializedDays = _completedDays.toList()..sort();
    await preferences.setStringList(
      _completedDaysKey,
      serializedDays.map((day) => day.toString()).toList(),
    );
    await preferences.setInt(_currentStreakDaysKey, _currentStreakDays);
    await preferences.setInt(_xpPointsKey, _xpPoints);
    await preferences.setInt(_dailyGoalKey, _dailyGoalMinutes);

    if (_lastCompletedAt == null) {
      await preferences.remove(_lastCompletedAtKey);
      return;
    }

    await preferences.setString(
      _lastCompletedAtKey,
      _lastCompletedAt!.toIso8601String(),
    );
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
