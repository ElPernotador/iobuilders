import 'package:flutter/material.dart';
import '../../core/date_utils.dart';
import '../../core/models/workout.dart';
import '../../core/storage_service.dart';
import '../../data/seed_training_plan.dart';

class TrainingProvider extends ChangeNotifier {
  Workout? _todayWorkout;
  List<Exercise> _filteredExercises = [];
  WorkoutLog? _todayLog;
  bool _loading = true;
  String? _error;
  int _shoulderPain = 0;
  int _kneePain = 0;
  String _trainingType = 'rest';

  Workout? get todayWorkout => _todayWorkout;
  List<Exercise> get exercises => _filteredExercises;
  WorkoutLog? get todayLog => _todayLog;
  bool get loading => _loading;
  String? get error => _error;
  String get trainingType => _trainingType;
  int get shoulderPain => _shoulderPain;
  int get kneePain => _kneePain;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final today = DateTime.now();
      final dateStr = AppDateUtils.todayString();
      _trainingType = AppDateUtils.trainingTypeForDay(today);

      final todayCheck = await StorageService.getTodayCheck(dateStr);
      _shoulderPain = todayCheck.shoulderPain ?? 0;
      _kneePain = todayCheck.kneePain ?? 0;

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

      _todayLog = await StorageService.getWorkoutLogForDate(dateStr);
    } catch (e) {
      _error = 'No se pudo cargar el entrenamiento';
    } finally {
      _loading = false;
      notifyListeners();
    }
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

    // Update daily check
    final check = await StorageService.getTodayCheck(dateStr);
    if (_trainingType.startsWith('strength')) {
      await StorageService.saveDailyCheck(check.copyWith(strength: true, morningMissionDone: true));
    } else if (_trainingType == 'bicycle') {
      await StorageService.saveDailyCheck(check.copyWith(bicycle: true, bicycleMinutes: durationMinutes));
    }
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
