import 'package:flutter/material.dart';
import '../../core/date_utils.dart';
import '../../core/models/body_metric.dart';
import '../../core/models/custom_item.dart';
import '../../core/models/daily_check.dart';
import '../../core/models/workout.dart';
import '../../core/storage_service.dart';

class TodayProvider extends ChangeNotifier {
  DailyCheck? _check;
  bool _loading = true;
  List<CustomItem> _customItems = [];
  Set<int> _customChecked = {};
  DateTime _date = DateTime.now();

  // Dashboard summary state.
  List<BodyMetric> _metrics = [];
  List<WorkoutLog> _recentLogs = [];
  int _streak = 0;

  DailyCheck? get check => _check;
  bool get loading => _loading;
  DateTime get date => _date;
  String get _dateStr => AppDateUtils.toDateString(_date);

  List<CustomItem> customItemsFor(String section) =>
      _customItems.where((i) => i.section == section).toList();
  bool isCustomChecked(int id) => _customChecked.contains(id);

  /// Daily completion: every tracked item plus the training-linked checks
  /// (logged from the Entrenamiento tab).
  int get completedCount => _customChecked.length + (_check?.trainingScore ?? 0);
  int get totalCount => _customItems.length + DailyCheck.trainingScoreMax;

  // --- Dashboard summary getters ---
  double? get latestWeight {
    final w = _metrics.where((m) => m.weight != null).toList();
    return w.isEmpty ? null : w.last.weight;
  }

  double? get weightTrend {
    final w = _metrics.where((m) => m.weight != null).toList();
    if (w.length < 2) return null;
    return w.last.weight! - w.first.weight!;
  }

  int get strengthSessions7d => _recentLogs
      .where((l) => l.workoutType.startsWith('strength') && l.completed)
      .length;

  int get bicycleMinutes7d => _recentLogs
      .where((l) => l.workoutType == 'bicycle' && l.completed)
      .fold(0, (s, l) => s + (l.durationMinutes ?? 0));

  int get streak => _streak;

  Future<void> loadToday([DateTime? date]) async {
    _loading = true;
    _date = date ?? DateTime.now();
    notifyListeners();
    final ds = _dateStr;
    _check = await StorageService.getTodayCheck(ds);
    _customItems = await StorageService.getCustomItems();
    _customChecked = await StorageService.getCustomChecks(ds);

    // Summary: metrics (all), workout logs in the 7 days up to selected date,
    // and a consecutive-day habit streak ending at the selected date.
    _metrics = await StorageService.getMetrics();
    final from7 = AppDateUtils.toDateString(_date.subtract(const Duration(days: 7)));
    _recentLogs = await StorageService.getWorkoutLogs(from7, ds);
    _streak = await _computeStreak();

    _loading = false;
    notifyListeners();
  }

  /// Consecutive days (ending at the selected date) with at least one habit
  /// checked.
  Future<int> _computeStreak() async {
    final from = AppDateUtils.toDateString(_date.subtract(const Duration(days: 60)));
    final checks = await StorageService.getChecksRange(from, _dateStr);
    final itemCounts = await StorageService.getCustomCheckCounts(from, _dateStr);
    final byDate = <String, int>{...itemCounts};
    for (final c in checks) {
      byDate[c.date] = (byDate[c.date] ?? 0) + c.trainingScore;
    }
    var streak = 0;
    var cursor = _date;
    while (true) {
      final score = byDate[AppDateUtils.toDateString(cursor)] ?? 0;
      if (score <= 0) break;
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Future<void> addCustomItem(String name, String section) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final item = await StorageService.addCustomItem(trimmed, section);
    _customItems = [..._customItems, item];
    notifyListeners();
  }

  Future<void> renameCustomItem(CustomItem item, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    item.name = trimmed;
    await StorageService.updateCustomItem(item);
    notifyListeners();
  }

  Future<void> deleteCustomItem(int id) async {
    await StorageService.deleteCustomItem(id);
    _customItems = _customItems.where((i) => i.id != id).toList();
    _customChecked = {..._customChecked}..remove(id);
    notifyListeners();
  }

  /// Moves an item up/down within its section and persists the new order.
  Future<void> moveCustomItem(CustomItem item, int delta) async {
    final section = customItemsFor(item.section);
    final from = section.indexWhere((i) => i.id == item.id);
    final to = from + delta;
    if (from < 0 || to < 0 || to >= section.length) return;
    final reordered = [...section];
    reordered.removeAt(from);
    reordered.insert(to, item);
    await StorageService.setCustomItemOrder(reordered);
    _customItems = await StorageService.getCustomItems();
    notifyListeners();
  }

  /// Re-adds any missing default trackable; returns how many were restored.
  Future<int> restoreDefaultItems() async {
    final added = await StorageService.restoreDefaultItems();
    _customItems = await StorageService.getCustomItems();
    notifyListeners();
    return added;
  }

  Future<void> toggleCustomItem(int id) async {
    final next = !_customChecked.contains(id);
    _customChecked = {..._customChecked};
    if (next) {
      _customChecked.add(id);
    } else {
      _customChecked.remove(id);
    }
    await StorageService.setCustomCheck(_dateStr, id, next);
    notifyListeners();
  }

  Future<void> toggle(String field) async {
    if (_check == null) return;
    DailyCheck updated;
    switch (field) {
      case 'strength': updated = _check!.copyWith(strength: !_check!.strength); break;
      case 'bicycle': updated = _check!.copyWith(bicycle: !_check!.bicycle); break;
      case 'mobility': updated = _check!.copyWith(mobility: !_check!.mobility); break;
      case 'morningMission': updated = _check!.copyWith(morningMissionDone: !_check!.morningMissionDone); break;
      default: return;
    }
    _check = updated;
    await StorageService.saveDailyCheck(updated);
    notifyListeners();
  }

  /// Training-linked reminders first, then whatever tracked items are still
  /// unchecked (so the list adapts to whatever the user chose to track).
  List<String> get priorityMissions {
    if (_check == null) return [];
    final dayType = AppDateUtils.trainingTypeForDay(_date);
    final shoulder = _check!.shoulderPain ?? 0;
    final knee = _check!.kneePain ?? 0;

    final missions = <_MissionPriority>[];

    if (!_check!.morningMissionDone) {
      missions.add(_MissionPriority('Misión mañana: 15 min fuerza', 100));
    }
    if (dayType.startsWith('strength') && !_check!.strength) {
      missions.add(_MissionPriority('Sesión de fuerza de hoy', 90));
    }
    if (dayType == 'bicycle' && !_check!.bicycle && knee < 6) {
      missions.add(_MissionPriority('Sesión de bicicleta', 85));
    }
    if ((shoulder >= 4 || knee >= 4) && !_check!.mobility) {
      missions.add(_MissionPriority('Movilidad (dolor activo)', 80));
    }

    // Pending trackables, in the user's own ordering.
    var weight = 60;
    for (final item in _customItems) {
      if (_customChecked.contains(item.id)) continue;
      missions.add(_MissionPriority(item.name, weight--));
    }

    missions.sort((a, b) => b.priority.compareTo(a.priority));
    return missions.take(5).map((m) => m.label).toList();
  }
}

class _MissionPriority {
  final String label;
  final int priority;
  _MissionPriority(this.label, this.priority);
}
