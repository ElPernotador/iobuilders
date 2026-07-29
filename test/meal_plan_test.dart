import 'package:flutter_test/flutter_test.dart';
import 'package:dieter/core/models/planned_meal.dart';

void main() {
  group('MealSlot', () {
    test('has the four plannable slots in eating order', () {
      expect(MealSlot.all,
          equals(['breakfast', 'lunch', 'dinner', 'snack']));
    });

    test('every slot has a Spanish label', () {
      for (final slot in MealSlot.all) {
        expect(MealSlot.label(slot), isNotEmpty);
        expect(MealSlot.label(slot), isNot(equals(slot)));
      }
    });

    test('only snack is free text', () {
      expect(MealSlot.isFreeText(MealSlot.snack), isTrue);
      for (final slot in [MealSlot.breakfast, MealSlot.lunch, MealSlot.dinner]) {
        expect(MealSlot.isFreeText(slot), isFalse);
      }
    });

    test('unknown slot label falls back to the raw value', () {
      expect(MealSlot.label('brunch'), equals('brunch'));
    });
  });

  group('PlannedMeal', () {
    test('round-trips through toMap/fromMap', () {
      const meal = PlannedMeal(
          date: '2026-07-29', mealType: MealSlot.lunch, recipeId: 'r05');
      final copy = PlannedMeal.fromMap(meal.toMap());
      expect(copy.date, equals('2026-07-29'));
      expect(copy.mealType, equals(MealSlot.lunch));
      expect(copy.recipeId, equals('r05'));
      expect(copy.note, isNull);
    });

    test('a row with neither recipe nor note counts as cleared', () {
      const cleared = PlannedMeal(date: '2026-07-29', mealType: MealSlot.dinner);
      expect(cleared.isEmpty, isTrue);
    });

    test('a note-only row is not empty', () {
      const snack =
          PlannedMeal(date: '2026-07-29', mealType: MealSlot.snack, note: 'Yogur');
      expect(snack.isEmpty, isFalse);
    });

    test('an empty-string note still counts as empty', () {
      const blank =
          PlannedMeal(date: '2026-07-29', mealType: MealSlot.snack, note: '');
      expect(blank.isEmpty, isTrue);
    });
  });
}
