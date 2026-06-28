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

  List<BodyMetric> get metrics => _metrics;
  List<DailyCheck> get recentChecks => _recentChecks;
  bool get loading => _loading;

  BodyMetric? get latestMetric => _metrics.isNotEmpty ? _metrics.last : null;

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    _metrics = await StorageService.getMetrics();

    final now = DateTime.now();
    final from = AppDateUtils.toDateString(now.subtract(const Duration(days: 90)));
    final to = AppDateUtils.todayString();
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
    final cutoff = AppDateUtils.toDateString(DateTime.now().subtract(const Duration(days: 7)));
    return _workoutLogs
        .where((l) => l.date >= cutoff && l.workoutType.startsWith('strength') && l.completed)
        .length;
  }

  int get bicycleMinutesLast7Days {
    final cutoff = AppDateUtils.toDateString(DateTime.now().subtract(const Duration(days: 7)));
    return _workoutLogs
        .where((l) => l.date >= cutoff && l.workoutType == 'bicycle' && l.completed)
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
