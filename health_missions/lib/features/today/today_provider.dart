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

  /// Daily completion across built-in habits + custom items.
  int get completedCount =>
      (_check?.completionScore ?? 0) + _customChecked.length;
  int get totalCount => 15 + _customItems.length;

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
    final byDate = {for (final c in checks) c.date: c.completionScore};
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
      case 'whey': updated = _check!.copyWith(whey: !_check!.whey); break;
      case 'creatine': updated = _check!.copyWith(creatine: !_check!.creatine); break;
      case 'msm': updated = _check!.copyWith(msm: !_check!.msm); break;
      case 'choline': updated = _check!.copyWith(choline: !_check!.choline); break;
      case 'fenugreek': updated = _check!.copyWith(fenugreek: !_check!.fenugreek); break;
      case 'probiotic': updated = _check!.copyWith(probiotic: !_check!.probiotic); break;
      case 'vitaminD': updated = _check!.copyWith(vitaminD: !_check!.vitaminD); break;
      case 'omega3': updated = _check!.copyWith(omega3: !_check!.omega3); break;
      case 'fruit': updated = _check!.copyWith(fruit: !_check!.fruit); break;
      case 'water2L': updated = _check!.copyWith(water2L: !_check!.water2L); break;
      case 'strength': updated = _check!.copyWith(strength: !_check!.strength); break;
      case 'bicycle': updated = _check!.copyWith(bicycle: !_check!.bicycle); break;
      case 'mobility': updated = _check!.copyWith(mobility: !_check!.mobility); break;
      case 'noBun': updated = _check!.copyWith(noBun: !_check!.noBun); break;
      case 'noUltraProcessed': updated = _check!.copyWith(noUltraProcessed: !_check!.noUltraProcessed); break;
      case 'proteinTarget': updated = _check!.copyWith(proteinTarget: !_check!.proteinTarget); break;
      case 'morningMission': updated = _check!.copyWith(morningMissionDone: !_check!.morningMissionDone); break;
      default: return;
    }
    _check = updated;
    await StorageService.saveDailyCheck(updated);
    notifyListeners();
  }

  Future<void> updatePain(int shoulder, int knee, int abdomen) async {
    if (_check == null) return;
    final updated = _check!.copyWith(
      shoulderPain: shoulder,
      kneePain: knee,
      abdomenBloating: abdomen,
    );
    _check = updated;
    await StorageService.saveDailyCheck(updated);
    notifyListeners();
  }

  Future<void> updateBicycle(int minutes, int intensity) async {
    if (_check == null) return;
    final updated = _check!.copyWith(
      bicycleMinutes: minutes,
      bicycleIntensity: intensity,
      bicycle: true,
    );
    _check = updated;
    await StorageService.saveDailyCheck(updated);
    notifyListeners();
  }

  List<String> get priorityMissions {
    if (_check == null) return [];
    final dayType = AppDateUtils.trainingTypeForDay(_date);
    final shoulder = _check!.shoulderPain ?? 0;
    final knee = _check!.kneePain ?? 0;

    final missions = <_MissionPriority>[];

    if (!_check!.morningMissionDone) {
      missions.add(_MissionPriority('Misión mañana: 15 min fuerza', 100));
    }
    if (!_check!.proteinTarget) {
      missions.add(_MissionPriority('Alcanzar objetivo proteína', 90));
    }
    if (dayType.startsWith('strength') && !_check!.strength) {
      missions.add(_MissionPriority('Sesión de fuerza de hoy', 85));
    }
    if (dayType == 'bicycle' && !_check!.bicycle && knee < 6) {
      missions.add(_MissionPriority('Sesión de bicicleta', 80));
    }
    if ((shoulder >= 4 || knee >= 4) && !_check!.mobility) {
      missions.add(_MissionPriority('Movilidad (dolor activo)', 75));
    }
    if (!_check!.water2L) {
      missions.add(_MissionPriority('Beber 2 litros de agua', 60));
    }
    if (!_check!.whey) {
      missions.add(_MissionPriority('Tomar whey', 55));
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
