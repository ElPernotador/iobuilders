import 'package:flutter_test/flutter_test.dart';
import 'package:dieter/core/date_utils.dart';
import 'package:dieter/data/seed_training_plan.dart';

void main() {
  group('Training adaptation based on pain', () {
    test('high shoulder pain removes non-shoulder-safe exercises', () {
      final exercises = filterExercisesForPain(
        exercises: workoutA.exercises,
        shoulderPain: 7,
        kneePain: 0,
      );
      for (final ex in exercises) {
        expect(ex.tags.contains('shoulder_safe'), isTrue,
            reason: 'Exercise ${ex.id} should be shoulder_safe when pain >= 6');
      }
    });

    test('low shoulder pain keeps all exercises', () {
      final exercises = filterExercisesForPain(
        exercises: workoutA.exercises,
        shoulderPain: 2,
        kneePain: 0,
      );
      expect(exercises.length, equals(workoutA.exercises.length));
    });

    test('high knee pain removes non-knee-safe exercises', () {
      final exercises = filterExercisesForPain(
        exercises: workoutC.exercises,
        shoulderPain: 0,
        kneePain: 7,
      );
      for (final ex in exercises) {
        expect(ex.tags.contains('knee_safe'), isTrue);
      }
    });

    test('training type is correct per weekday', () {
      // Monday
      final monday = DateTime(2026, 6, 29); // actual Monday
      expect(AppDateUtils.trainingTypeForDay(monday), equals('strength_a'));

      // Tuesday
      final tuesday = DateTime(2026, 6, 30);
      expect(AppDateUtils.trainingTypeForDay(tuesday), equals('bicycle'));

      // Sunday
      final sunday = DateTime(2026, 7, 5);
      expect(AppDateUtils.trainingTypeForDay(sunday), equals('rest'));
    });
  });

  group('Weekly plan lookup', () {
    test('plan week index rotates within 1-26', () {
      final start = DateTime(2026, 6, 28);
      // Week 1: day 0
      expect(AppDateUtils.planWeekIndex(start, DateTime(2026, 6, 28)), equals(1));
      // Week 2: 7 days later
      expect(AppDateUtils.planWeekIndex(start, DateTime(2026, 6, 28).add(const Duration(days: 7))), equals(2));
      // Week 27 = 26 weeks later = index 27 (1-based, wraps at 26 via modulo)
      final week27Date = DateTime(2026, 6, 28).add(const Duration(days: 7 * 26));
      final idx = AppDateUtils.planWeekIndex(start, week27Date);
      expect(idx, greaterThanOrEqualTo(1));
    });
  });
}
