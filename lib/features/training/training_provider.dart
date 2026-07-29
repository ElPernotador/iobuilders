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
  DateTime _date = DateTime.now();

  List<Exercise> _customExercises = [];

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
  String get _dateStr => AppDateUtils.toDateString(_date);

  /// All exercises now live in the database and are editable.
  bool isCustomExercise(Exercise e) => e.id.startsWith('cx_');

  Future<void> load([DateTime? date]) async {
    _loading = true;
    _error = null;
    _date = date ?? DateTime.now();
    notifyListeners();

    try {
      _trainingType = AppDateUtils.trainingTypeForDay(_date);

      _check = await StorageService.getTodayCheck(_dateStr);
      _shoulderPain = _check!.shoulderPain ?? 0;
      _kneePain = _check!.kneePain ?? 0;
      _abdomenBloating = _check!.abdomenBloating ?? 0;

      _customExercises = _trainingType.startsWith('strength')
          ? await StorageService.getCustomExercises(_trainingType)
          : [];

      _refilter();

      _todayLog = await StorageService.getWorkoutLogForDate(_dateStr);
    } catch (e) {
      _error = 'No se pudo cargar el entrenamiento';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Every exercise is a database row (defaults are seeded), so the day's list
  /// is simply those rows with the pain filter applied.
  void _refilter() {
    _todayWorkout = getWorkoutForType(_trainingType);
    if (_todayWorkout == null) {
      _filteredExercises = [];
      _mergedCount = 0;
      return;
    }
    _mergedCount = _customExercises.length;
    _filteredExercises = filterExercisesForPain(
      exercises: _customExercises,
      shoulderPain: _shoulderPain,
      kneePain: _kneePain,
    );
  }

  int _mergedCount = 0;

  // --- Editing the routine ---
  Future<void> addExercise(String name, int sets, String reps) async {
    final n = name.trim();
    if (n.isEmpty || !_trainingType.startsWith('strength')) return;
    await StorageService.addCustomExercise(
      workoutType: _trainingType,
      name: n,
      sets: sets,
      reps: reps,
    );
    _customExercises = await StorageService.getCustomExercises(_trainingType);
    _refilter();
    notifyListeners();
  }

  Future<void> removeExercise(Exercise e) async {
    await StorageService.deleteCustomExercise(e.id);
    _customExercises = await StorageService.getCustomExercises(_trainingType);
    _refilter();
    notifyListeners();
  }

  /// Edits an exercise in place.
  Future<void> updateExercise(Exercise e, String name, int sets, String reps) async {
    final n = name.trim();
    if (n.isEmpty) return;
    await StorageService.updateCustomExercise(e.id,
        name: n, sets: sets, reps: reps.trim().isEmpty ? e.reps : reps.trim());
    _customExercises = await StorageService.getCustomExercises(_trainingType);
    _refilter();
    notifyListeners();
  }

  /// Re-adds built-in exercises for this day that were deleted.
  Future<int> restoreDefaultExercises() async {
    if (!_trainingType.startsWith('strength')) return 0;
    final added = await StorageService.restoreDefaultExercises(_trainingType);
    _customExercises = await StorageService.getCustomExercises(_trainingType);
    _refilter();
    notifyListeners();
    return added;
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
  int get hiddenByPain => _mergedCount - _filteredExercises.length;

  bool isExerciseCompleted(String exerciseId) {
    return _todayLog?.completedExerciseIds.contains(exerciseId) ?? false;
  }

  Future<void> toggleExercise(String exerciseId) async {
    final dateStr = _dateStr;
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
    final dateStr = _dateStr;
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
    final dateStr = _dateStr;
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
