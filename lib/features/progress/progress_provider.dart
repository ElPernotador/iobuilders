import 'package:flutter/material.dart';
import '../../core/date_utils.dart';
import '../../core/models/body_metric.dart';
import '../../core/models/daily_check.dart';
import '../../core/models/workout.dart';
import '../../core/storage_service.dart';

class ProgressProvider extends ChangeNotifier {
  List<BodyMetric> _metrics = [];
  List<DailyCheck> _recentChecks = [];
  List<WorkoutLog> _workoutLogs = [];
  bool _loading = true;

  DateTime _date = DateTime.now();

  List<BodyMetric> get metrics => _metrics;
  List<DailyCheck> get recentChecks => _recentChecks;
  bool get loading => _loading;
  DateTime get selectedDate => _date;
  String get selectedString => AppDateUtils.toDateString(_date);

  BodyMetric? get latestMetric => _metrics.isNotEmpty ? _metrics.last : null;

  /// Body metric registered exactly on the selected day, if any.
  BodyMetric? get metricForSelectedDay {
    for (final m in _metrics) {
      if (m.date == selectedString) return m;
    }
    return null;
  }

  Future<void> load([DateTime? date]) async {
    _loading = true;
    _date = date ?? DateTime.now();
    notifyListeners();

    _metrics = await StorageService.getMetrics();

    final from = AppDateUtils.toDateString(_date.subtract(const Duration(days: 90)));
    final to = selectedString;
    _recentChecks = await StorageService.getChecksRange(from, to);
    _workoutLogs = await StorageService.getWorkoutLogs(from, to);

    _loading = false;
    notifyListeners();
  }

  Future<void> addMetric(BodyMetric metric) async {
    await StorageService.saveMetric(metric);
    await load();
  }

  double? get weightTrend {
    final weights = _metrics.where((m) => m.weight != null).toList();
    if (weights.length < 2) return null;
    return weights.last.weight! - weights.first.weight!;
  }

  double? get waistTrend {
    final waists = _metrics.where((m) => m.waist != null).toList();
    if (waists.length < 2) return null;
    return waists.last.waist! - waists.first.waist!;
  }

  // Simple liver risk direction: if weight and waist both going down = improving
  String get liverRiskDirection {
    final wt = weightTrend;
    final wa = waistTrend;
    if (wt == null || wa == null) return 'Sin datos suficientes';
    if (wt < -1 && wa < -1) return 'Mejorando ↓';
    if (wt > 1 || wa > 1) return 'Empeorando ↑';
    return 'Estable →';
  }

  int get strengthSessionsLast7Days {
    final cutoff = AppDateUtils.toDateString(_date.subtract(const Duration(days: 7)));
    return _workoutLogs
        .where((l) => l.date.compareTo(cutoff) >= 0 && l.workoutType.startsWith('strength') && l.completed)
        .length;
  }

  int get bicycleMinutesLast7Days {
    final cutoff = AppDateUtils.toDateString(_date.subtract(const Duration(days: 7)));
    return _workoutLogs
        .where((l) => l.date.compareTo(cutoff) >= 0 && l.workoutType == 'bicycle' && l.completed)
        .fold(0, (sum, l) => sum + (l.durationMinutes ?? 0));
  }

  // Returns last 30 days as map date->score
  Map<String, int> get habitHeatmap {
    final result = <String, int>{};
    for (final check in _recentChecks) {
      result[check.date] = check.completionScore;
    }
    return result;
  }
}
