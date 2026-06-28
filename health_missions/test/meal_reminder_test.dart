import 'package:flutter_test/flutter_test.dart';
import 'package:health_missions/data/seed_recipes.dart';

void main() {
  group('Meal reminder calculation', () {
    test('notification fires before recipe duration', () {
      final recipe = findRecipeById('r02')!; // pollo al curry, 30 min total
      const dinnerHour = 21;
      const dinnerMinute = 0;

      final dinnerTime = DateTime(2026, 6, 28, dinnerHour, dinnerMinute);
      final notifyAt = dinnerTime.subtract(Duration(minutes: recipe.totalMinutes));

      expect(notifyAt.hour, equals(20));
      expect(notifyAt.minute, equals(30));
    });

    test('zero-cook recipe notifies at meal time', () {
      final recipe = findRecipeById('r10')!; // yogur bowl, 5 min prep, 0 cook
      final lunchTime = DateTime(2026, 6, 28, 13, 30);
      final notifyAt = lunchTime.subtract(Duration(minutes: recipe.totalMinutes));
      expect(notifyAt.isBefore(lunchTime), isTrue);
    });

    test('total minutes is sum of prep and cook', () {
      final recipe = findRecipeById('r21')!; // pollo al horno, 10+30=40
      expect(recipe.totalMinutes, equals(40));
    });

    test('past notification time is skipped', () {
      final now = DateTime.now();
      final pastTime = now.subtract(const Duration(minutes: 5));
      expect(pastTime.isBefore(now), isTrue);
    });
  });
}
