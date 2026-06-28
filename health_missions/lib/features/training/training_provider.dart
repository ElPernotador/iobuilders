import 'package:flutter/material.dart';
import '../../core/date_utils.dart';
import '../../core/models/daily_check.dart';
import '../../core/models/workout.dart';
import '../../core/storage_service.dart';
import '../../data/seed_training_plan.dart';

class TrainingProvider extends ChangeNotifier {
  Workout? _todayWorkout;
  List<Exercise> _filteredExercises = [];
  WorkoutLog? _todayLog;
  DailyCheck? _check;
  bool _loading = true;
  String? _error;
  int _shoulderPain = 0;
  int _kneePain = 0;
  int _abdomenBloating = 0;
  String _trainingType = 'rest';

  Workout? get todayWorkout => _todayWorkout;
  List<Exercise> get exercises => _filteredExercises;
  WorkoutLog? get todayLog => _todayLog;
  bool get loading => _loading;
  String? get error => _error;
  String get trainingType => _trainingType;
  int get shoulderPain => _shoulderPain;
  int get kneePain => _kneePain;
  int get abdomenBloating => _abdomenBloating;
  bool get morningMissionDone => _check?.morningMissionDone ?? false;
  bool get mobilityDone => _check?.mobility ?? false;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final today = DateTime.now();
      final dateStr = AppDateUtils.todayString();
      _trainingType = AppDateUtils.trainingTypeForDay(today);

      _check = await StorageService.getTodayCheck(dateStr);
      _shoulderPain = _check!.shoulderPain ?? 0;
      _kneePain = _check!.kneePain ?? 0;
      _abdomenBloating = _check!.abdomenBloating ?? 0;

      _refilter();

      _todayLog = await StorageService.getWorkoutLogForDate(dateStr);
    } catch (e) {
      _error = 'No se pudo cargar el entrenamiento';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _refilter() {
    _todayWorkout = getWorkoutForType(_trainingType);
    if (_todayWorkout != null) {
      _filteredExercises = filterExercisesForPain(
        exercises: _todayWorkout!.exercises,
        shoulderPain: _shoulderPain,
        kneePain: _kneePain,
      );
    } else {
      _filteredExercises = [];
    }
  }

  /// Update today's pain levels (also re-adapts the exercise list).
  Future<void> updatePain(int shoulder, int knee, int abdomen) async {
    if (_check == null) return;
    _shoulderPain = shoulder;
    _kneePain = knee;
    _abdomenBloating = abdomen;
    _check = _check!.copyWith(
      shoulderPain: shoulder,
      kneePain: knee,
      abdomenBloating: abdomen,
    );
    _refilter();
    await StorageService.saveDailyCheck(_check!);
    notifyListeners();
  }

  Future<void> toggleMorningMission() async {
    if (_check == null) return;
    _check = _check!.copyWith(morningMissionDone: !_check!.morningMissionDone);
    await StorageService.saveDailyCheck(_check!);
    notifyListeners();
  }

  Future<void> toggleMobility() async {
    if (_check == null) return;
    _check = _check!.copyWith(mobility: !_check!.mobility);
    await StorageService.saveDailyCheck(_check!);
    notifyListeners();
  }

  /// How many exercises were hidden by the pain filter.
  int get hiddenByPain =>
      (_todayWorkout?.exercises.length ?? 0) - _filteredExercises.length;

  bool isExerciseCompleted(String exerciseId) {
    return _todayLog?.completedExerciseIds.contains(exerciseId) ?? false;
  }

  Future<void> toggleExercise(String exerciseId) async {
    final dateStr = AppDateUtils.todayString();
    final current = List<String>.from(_todayLog?.completedExerciseIds ?? []);
    if (current.contains(exerciseId)) {
      current.remove(exerciseId);
    } else {
      current.add(exerciseId);
    }
    final log = WorkoutLog(
      id: _todayLog?.id,
      date: dateStr,
      workoutId: _todayWorkout?.id ?? _trainingType,
      workoutType: _trainingType,
      completedExerciseIds: current,
      completed: _todayLog?.completed ?? false,
    );
    _todayLog = log;
    await StorageService.saveWorkoutLog(log);
    notifyListeners();
  }

  Future<void> markCompleted({int? durationMinutes, int? effort}) async {
    if (_todayWorkout == null && _trainingType != 'bicycle') return;
    final dateStr = AppDateUtils.todayString();
    final log = WorkoutLog(
      id: _todayLog?.id,
      date: dateStr,
      workoutId: _todayWorkout?.id ?? _trainingType,
      workoutType: _trainingType,
      completedExerciseIds: _filteredExercises.map((e) => e.id).toList(),
      completed: true,
      durationMinutes: durationMinutes,
      perceivedEffort: effort,
    );
    _todayLog = log;
    await StorageService.saveWorkoutLog(log);

    // Update daily check (kept in memory so the Hoy summary stays accurate).
    final check = _check ?? await StorageService.getTodayCheck(dateStr);
    if (_trainingType.startsWith('strength')) {
      _check = check.copyWith(strength: true, morningMissionDone: true);
    } else if (_trainingType == 'bicycle') {
      _check = check.copyWith(
        bicycle: true,
        bicycleMinutes: durationMinutes,
        bicycleIntensity: effort,
      );
    } else {
      _check = check;
    }
    await StorageService.saveDailyCheck(_check!);
    notifyListeners();
  }

  Future<void> reportTooMuchPain() async {
    final dateStr = AppDateUtils.todayString();
    final log = WorkoutLog(
      id: _todayLog?.id,
      date: dateStr,
      workoutId: 'skipped_pain',
      workoutType: _trainingType,
      completedExerciseIds: [],
      completed: false,
      notes: 'Omitido por dolor',
    );
    _todayLog = log;
    await StorageService.saveWorkoutLog(log);
    notifyListeners();
  }
}
