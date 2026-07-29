class Exercise {
  final String id;
  final String name;
  final int sets;
  final String reps;
  final int restSeconds;
  final String instructions;
  final String safetyNote;
  final String easierVariant;
  final String harderVariant;
  final List<String> tags; // 'shoulder_safe', 'knee_safe', 'core', 'push', 'pull'

  const Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.instructions,
    required this.safetyNote,
    required this.easierVariant,
    required this.harderVariant,
    required this.tags,
  });
}

class Workout {
  final String id;
  final String name;
  final String type; // 'strength_a', 'strength_b', 'strength_c', 'bicycle', 'mobility'
  final List<Exercise> exercises;
  final int estimatedMinutes;

  const Workout({
    required this.id,
    required this.name,
    required this.type,
    required this.exercises,
    required this.estimatedMinutes,
  });
}

class WorkoutLog {
  int? id;
  String date;
  String workoutId;
  String workoutType;
  List<String> completedExerciseIds;
  bool completed;
  int? durationMinutes;
  int? perceivedEffort;
  String? notes;

  WorkoutLog({
    this.id,
    required this.date,
    required this.workoutId,
    required this.workoutType,
    required this.completedExerciseIds,
    this.completed = false,
    this.durationMinutes,
    this.perceivedEffort,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'date': date,
        'workoutId': workoutId,
        'workoutType': workoutType,
        'completedExerciseIds': completedExerciseIds.join(','),
        'completed': completed ? 1 : 0,
        'durationMinutes': durationMinutes,
        'perceivedEffort': perceivedEffort,
        'notes': notes,
      };

  factory WorkoutLog.fromMap(Map<String, dynamic> m) => WorkoutLog(
        id: m['id'],
        date: m['date'],
        workoutId: m['workoutId'],
        workoutType: m['workoutType'],
        completedExerciseIds: (m['completedExerciseIds'] as String? ?? '')
            .split(',')
            .where((s) => s.isNotEmpty)
            .toList(),
        completed: (m['completed'] ?? 0) == 1,
        durationMinutes: m['durationMinutes'],
        perceivedEffort: m['perceivedEffort'],
        notes: m['notes'],
      );
}
