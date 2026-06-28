class Recipe {
  final String id;
  final String title;
  final String category;
  final int prepMinutes;
  final int cookMinutes;
  final int servings;
  final List<String> ingredients;
  final List<String> steps;
  final String proteinLevel; // high/medium/low
  final String carbLevel;    // high/medium/low
  final String gutNote;
  final String liverNote;
  final String oilLimitNote;
  final List<String> tags;

  const Recipe({
    required this.id,
    required this.title,
    required this.category,
    required this.prepMinutes,
    required this.cookMinutes,
    required this.servings,
    required this.ingredients,
    required this.steps,
    required this.proteinLevel,
    required this.carbLevel,
    required this.gutNote,
    required this.liverNote,
    required this.oilLimitNote,
    required this.tags,
  });

  int get totalMinutes => prepMinutes + cookMinutes;
}

class MealPlanDay {
  final int weekNumber;  // 1-26
  final int dayOfWeek;   // 1=Mon, 7=Sun
  final String? lunchRecipeId;
  final String? dinnerRecipeId;
  final String? snackSuggestion;

  const MealPlanDay({
    required this.weekNumber,
    required this.dayOfWeek,
    this.lunchRecipeId,
    this.dinnerRecipeId,
    this.snackSuggestion,
  });
}

class ShoppingItem {
  int? id;
  String weekKey; // e.g. "2024-W01"
  String name;
  String category;
  bool checked;
  bool isCustom;

  ShoppingItem({
    this.id,
    required this.weekKey,
    required this.name,
    required this.category,
    this.checked = false,
    this.isCustom = false,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'weekKey': weekKey,
        'name': name,
        'category': category,
        'checked': checked ? 1 : 0,
        'isCustom': isCustom ? 1 : 0,
      };

  factory ShoppingItem.fromMap(Map<String, dynamic> m) => ShoppingItem(
        id: m['id'],
        weekKey: m['weekKey'],
        name: m['name'],
        category: m['category'],
        checked: (m['checked'] ?? 0) == 1,
        isCustom: (m['isCustom'] ?? 0) == 1,
      );
}
