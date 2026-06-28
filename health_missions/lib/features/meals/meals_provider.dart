import 'package:flutter/material.dart';
import '../../core/date_utils.dart';
import '../../core/models/app_settings.dart';
import '../../core/models/recipe.dart';
import '../../core/notification_service.dart';
import '../../core/storage_service.dart';
import '../../data/seed_meal_plan.dart';
import '../../data/seed_recipes.dart';

class MealsProvider extends ChangeNotifier {
  static final DateTime _appStart = DateTime(2026, 6, 28);

  Recipe? _todayLunch;
  Recipe? _todayDinner;
  String? _todaySnack;
  Map<String, String?> _skipped = {};
  bool _loading = true;
  AppSettings? _settings;

  Recipe? get todayLunch => _todayLunch;
  Recipe? get todayDinner => _todayDinner;
  String? get todaySnack => _todaySnack;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    _settings = await StorageService.getSettings();
    final today = DateTime.now();
    final weekIndex = AppDateUtils.planWeekIndex(_appStart, today);
    final dow = today.weekday;
    final planDay = getMealPlanDay(weekIndex, dow);

    final dateStr = AppDateUtils.todayString();
    _skipped = await StorageService.getSkippedRecipes(dateStr);

    if (planDay != null) {
      final lunchId = _skipped['lunch'] ?? planDay.lunchRecipeId;
      final dinnerId = _skipped['dinner'] ?? planDay.dinnerRecipeId;
      _todayLunch = lunchId != null ? findRecipeById(lunchId) : null;
      _todayDinner = dinnerId != null ? findRecipeById(dinnerId) : null;
      _todaySnack = planDay.snackSuggestion;
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> skipRecipe(String mealType, String? replacementId) async {
    final dateStr = AppDateUtils.todayString();
    await StorageService.skipRecipe(dateStr, mealType, replacementId);
    await load();
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

  List<Recipe> getAllRecipes() => seedRecipes;

  MealPlanDay? getPlanDay(int week, int dow) => getMealPlanDay(week, dow);

  int get currentWeekIndex => AppDateUtils.planWeekIndex(_appStart, DateTime.now());
}
