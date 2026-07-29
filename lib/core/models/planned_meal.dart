/// The four plannable slots in a day, in the order they are eaten.
class MealSlot {
  static const breakfast = 'breakfast';
  static const lunch = 'lunch';
  static const dinner = 'dinner';
  static const snack = 'snack';

  static const all = [breakfast, lunch, dinner, snack];

  static const labels = {
    breakfast: 'Desayuno',
    lunch: 'Almuerzo',
    dinner: 'Cena',
    snack: 'Snack',
  };

  static String label(String slot) => labels[slot] ?? slot;

  /// Snack is free text rather than a recipe reference.
  static bool isFreeText(String slot) => slot == snack;
}

/// A meal the user assigned to a specific date and slot. Either a [recipeId]
/// (breakfast / lunch / dinner) or a free-text [note] (snack).
class PlannedMeal {
  final String date; // yyyy-MM-dd
  final String mealType;
  final String? recipeId;
  final String? note;

  const PlannedMeal({
    required this.date,
    required this.mealType,
    this.recipeId,
    this.note,
  });

  bool get isEmpty => recipeId == null && (note == null || note!.isEmpty);

  Map<String, dynamic> toMap() => {
        'date': date,
        'mealType': mealType,
        'recipeId': recipeId,
        'note': note,
      };

  factory PlannedMeal.fromMap(Map<String, dynamic> m) => PlannedMeal(
        date: m['date'] as String,
        mealType: m['mealType'] as String,
        recipeId: m['recipeId'] as String?,
        note: m['note'] as String?,
      );
}
