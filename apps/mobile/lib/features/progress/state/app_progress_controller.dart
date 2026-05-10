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
  })  : _completedDays = Set<int>.from(completedDays),
        _currentStreakDays = currentStreakDays,
        _lastCompletedAt = lastCompletedAt;

  static const _completedDaysKey = 'app_progress_completed_days';
  static const _currentStreakDaysKey = 'app_progress_current_streak_days';
  static const _lastCompletedAtKey = 'app_progress_last_completed_at';

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

    return AppProgressController(
      totalDays: totalDays,
      completedDays: completedDays,
      currentStreakDays: currentStreakDays,
      lastCompletedAt: lastCompletedAt,
    );
  }

  final int totalDays;
  final Set<int> _completedDays;
  ProgressSyncState _syncState = ProgressSyncState.localOnly;
  DateTime? _lastServerSyncAt;
  int _currentStreakDays;
  DateTime? _lastCompletedAt;

  int get completedDaysCount => _completedDays.length;
  ProgressSyncState get syncState => _syncState;
  DateTime? get lastServerSyncAt => _lastServerSyncAt;
  int get currentStreakDays => _currentStreakDays;
  DateTime? get lastCompletedAt => _lastCompletedAt;

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
    notifyListeners();
    _persistProgressSnapshot();
  }

  Future<void> reset() async {
    _completedDays.clear();
    _currentStreakDays = 0;
    _lastCompletedAt = null;
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
