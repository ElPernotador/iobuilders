import 'package:flutter/material.dart';
import '../../core/date_utils.dart';
import '../../core/ingredient_aggregator.dart';
import '../../core/models/app_settings.dart';
import '../../core/models/planned_meal.dart';
import '../../core/models/recipe.dart';
import '../../core/notification_service.dart';
import '../../core/storage_service.dart';
import '../../data/seed_meal_plan.dart';
import '../../data/seed_recipes.dart';

class MealsProvider extends ChangeNotifier {
  static final DateTime _appStart = DateTime(2026, 6, 28);

  Recipe? _todayBreakfast;
  Recipe? _todayLunch;
  Recipe? _todayDinner;
  String? _todaySnack;
  bool _loading = true;
  String? _error;
  AppSettings? _settings;
  List<Recipe> _customRecipes = [];

  /// date → slot → planned meal, for the week currently shown in the planner.
  Map<String, Map<String, PlannedMeal>> _plan = {};
  int _weekOffset = 0;

  Recipe? get todayBreakfast => _todayBreakfast;
  Recipe? get todayLunch => _todayLunch;
  Recipe? get todayDinner => _todayDinner;
  String? get todaySnack => _todaySnack;
  bool get loading => _loading;
  String? get error => _error;
  List<Recipe> get customRecipes => _customRecipes;

  /// Every recipe now lives in the database (the built-ins are seeded there),
  /// so all of them can be edited and deleted.
  bool isCustom(Recipe r) => true;

  /// True for recipes the user created/imported rather than the built-ins
  /// (which are seeded with ids like `r01`).
  static final _seedIdPattern = RegExp(r'^r\d+$');
  bool isUserCreated(Recipe r) => !_seedIdPattern.hasMatch(r.id);

  Recipe? _findById(String id) {
    for (final r in _customRecipes) {
      if (r.id == id) return r;
    }
    return findRecipeById(id);
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _settings = await StorageService.getSettings();
      _customRecipes = await StorageService.getCustomRecipes();

      // The user's own plan for the visible week (empty slots fall back to the
      // built-in 26-week suggestion).
      final start = weekStart;
      _plan = await StorageService.getPlannedMeals(
        AppDateUtils.toDateString(start),
        AppDateUtils.toDateString(start.add(const Duration(days: 6))),
      );

      // Today's cards read from the same map, so keep today loaded even when the
      // planner is browsing another week.
      final today = DateTime.now();
      final todayStr = AppDateUtils.todayString();
      if (!_plan.containsKey(todayStr)) {
        _plan.addAll(await StorageService.getPlannedMeals(todayStr, todayStr));
      }

      _todayLunch = recipeFor(today, MealSlot.lunch);
      _todayDinner = recipeFor(today, MealSlot.dinner);
      _todayBreakfast = recipeFor(today, MealSlot.breakfast);
      _todaySnack = noteFor(today, MealSlot.snack);
    } catch (e) {
      _error = 'No se pudieron cargar las comidas';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────── Week plan ───────────────────────────

  /// Monday of the week currently shown in the planner.
  DateTime get weekStart {
    final base = DateTime.now().add(Duration(days: 7 * _weekOffset));
    final monday = base.subtract(Duration(days: base.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  List<DateTime> get weekDays =>
      List.generate(7, (i) => weekStart.add(Duration(days: i)));

  int get weekOffset => _weekOffset;
  bool get isCurrentWeek => _weekOffset == 0;

  Future<void> shiftWeek(int delta) async {
    _weekOffset += delta;
    await load();
  }

  Future<void> resetWeek() async {
    if (_weekOffset == 0) return;
    _weekOffset = 0;
    await load();
  }

  /// The built-in suggestion for a date, if any.
  MealPlanDay? _suggestionFor(DateTime date) =>
      getMealPlanDay(AppDateUtils.planWeekIndex(_appStart, date), date.weekday);

  /// True when the slot was set by the user (rather than merely suggested).
  bool isPlanned(DateTime date, String slot) {
    final entry = _plan[AppDateUtils.toDateString(date)]?[slot];
    return entry != null && !entry.isEmpty;
  }

  /// Resolved recipe for a slot: the user's plan first, else the suggestion.
  Recipe? recipeFor(DateTime date, String slot) {
    final entry = _plan[AppDateUtils.toDateString(date)]?[slot];
    if (entry?.recipeId != null) return _findById(entry!.recipeId!);
    if (entry != null) return null; // explicitly cleared by the user

    // Fall back to the built-in plan (which only covers lunch/dinner).
    final s = _suggestionFor(date);
    if (s == null) return null;
    final id = slot == MealSlot.lunch
        ? s.lunchRecipeId
        : slot == MealSlot.dinner
            ? s.dinnerRecipeId
            : null;
    return id != null ? _findById(id) : null;
  }

  /// Resolved free-text note for a slot (used by snack).
  String? noteFor(DateTime date, String slot) {
    final entry = _plan[AppDateUtils.toDateString(date)]?[slot];
    if (entry != null) return entry.note;
    if (slot == MealSlot.snack) return _suggestionFor(date)?.snackSuggestion;
    return null;
  }

  Future<void> planRecipe(DateTime date, String slot, String recipeId) async {
    await StorageService.setPlannedMeal(AppDateUtils.toDateString(date), slot,
        recipeId: recipeId);
    await load();
  }

  Future<void> planNote(DateTime date, String slot, String note) async {
    await StorageService.setPlannedMeal(AppDateUtils.toDateString(date), slot,
        note: note.trim().isEmpty ? null : note.trim());
    await load();
  }

  /// Explicitly empties a slot (also suppresses the built-in suggestion).
  Future<void> clearSlot(DateTime date, String slot) async {
    await StorageService.setPlannedMeal(AppDateUtils.toDateString(date), slot);
    await load();
  }

  /// Drops the user's entry so the built-in suggestion applies again.
  Future<void> resetSlotToSuggestion(DateTime date, String slot) async {
    await StorageService.clearPlannedMeal(AppDateUtils.toDateString(date), slot);
    await load();
  }

  /// Copies the built-in suggestions for the visible week into the user's plan,
  /// so there is something concrete to edit and shop for.
  Future<void> fillWeekFromSuggestions() async {
    for (final day in weekDays) {
      final s = _suggestionFor(day);
      if (s == null) continue;
      final dateStr = AppDateUtils.toDateString(day);
      if (s.lunchRecipeId != null) {
        await StorageService.setPlannedMeal(dateStr, MealSlot.lunch,
            recipeId: s.lunchRecipeId);
      }
      if (s.dinnerRecipeId != null) {
        await StorageService.setPlannedMeal(dateStr, MealSlot.dinner,
            recipeId: s.dinnerRecipeId);
      }
      if (s.snackSuggestion != null) {
        await StorageService.setPlannedMeal(dateStr, MealSlot.snack,
            note: s.snackSuggestion);
      }
    }
    await load();
  }

  /// How many recipe slots the visible week has filled.
  int get plannedCount {
    var n = 0;
    for (final day in weekDays) {
      for (final slot in MealSlot.all) {
        if (MealSlot.isFreeText(slot)) continue;
        if (recipeFor(day, slot) != null) n++;
      }
    }
    return n;
  }

  /// Rebuilds the week's shopping list from the planned recipes' ingredients.
  /// Replaces the whole list for that week. Returns the number of items written.
  Future<int> generateShoppingList() async {
    final lines = <String>[];
    for (final day in weekDays) {
      for (final slot in MealSlot.all) {
        if (MealSlot.isFreeText(slot)) continue;
        final recipe = recipeFor(day, slot);
        if (recipe != null) lines.addAll(recipe.ingredients);
      }
    }
    final weekKey = AppDateUtils.weekKey(weekStart);
    final aggregated = IngredientAggregator.aggregate(lines);
    final items = aggregated
        .map((a) => ShoppingItem(
              weekKey: weekKey,
              name: a.label,
              category: IngredientAggregator.categoryFor(a.name),
              isCustom: false,
            ))
        .toList();

    await StorageService.replaceShoppingListForWeek(weekKey, items);
    return items.length;
  }

  Future<void> addCustomRecipe(Recipe r) async {
    await StorageService.saveCustomRecipe(r);
    await load();
  }

  Future<void> deleteCustomRecipe(String id) async {
    await StorageService.deleteCustomRecipe(id);
    await load();
  }

  /// Stable-ish unique id for a new custom recipe (no Random/DateTime.now
  /// dependency issues — based on count + title hash).
  String newRecipeId(String title) =>
      'c_${_customRecipes.length}_${title.hashCode.toUnsigned(20)}';

  /// Changes today's meal: assigns [replacementId], or empties the slot when
  /// null. Writes to the plan, so it is the same mechanism as the week planner.
  Future<void> skipRecipe(String mealType, String? replacementId) async {
    final today = DateTime.now();
    if (replacementId == null) {
      await clearSlot(today, mealType);
    } else {
      await planRecipe(today, mealType, replacementId);
    }
  }

  Future<void> scheduleMealReminders() async {
    if (_settings == null) return;
    final now = DateTime.now();

    if (_todayLunch != null && _settings!.mealRemindersEnabled) {
      final lunchTime = DateTime(now.year, now.month, now.day,
          _settings!.lunchHour, _settings!.lunchMinute);
      final notifyAt = lunchTime.subtract(Duration(minutes: _todayLunch!.totalMinutes));
      await NotificationService.scheduleMealReminder(
        id: NotificationService.idLunchReminder,
        when: notifyAt,
        title: 'Hora de preparar el almuerzo',
        body: 'Conviene empezar: ${_todayLunch!.title} (${_todayLunch!.totalMinutes} min)',
      );
    }

    if (_todayDinner != null && _settings!.mealRemindersEnabled) {
      final dinnerTime = DateTime(now.year, now.month, now.day,
          _settings!.dinnerHour, _settings!.dinnerMinute);
      final notifyAt = dinnerTime.subtract(Duration(minutes: _todayDinner!.totalMinutes));
      await NotificationService.scheduleMealReminder(
        id: NotificationService.idDinnerReminder,
        when: notifyAt,
        title: 'Conviene empezar la cena',
        body: '${_todayDinner!.title} (${_todayDinner!.totalMinutes} min)',
      );
    }
  }

  /// All recipes come from the database — the built-ins are seeded on first run
  /// so nothing is read-only.
  List<Recipe> getAllRecipes() => _customRecipes;

  /// Re-adds any built-in recipe that was deleted.
  Future<int> restoreDefaultRecipes() async {
    final added = await StorageService.restoreDefaultRecipes();
    await load();
    return added;
  }

  MealPlanDay? getPlanDay(int week, int dow) => getMealPlanDay(week, dow);

  int get currentWeekIndex => AppDateUtils.planWeekIndex(_appStart, DateTime.now());
}
