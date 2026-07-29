import '../core/models/recipe.dart';

// 26 weeks, each week has 7 days (Mon-Sun)
// Each day has: lunch, dinner, optional snack
// Weeks rotate across ~47 unique recipes

const List<MealPlanDay> seedMealPlan = [
  // WEEK 1
  MealPlanDay(weekNumber: 1, dayOfWeek: 1, lunchRecipeId: 'r05', dinnerRecipeId: 'r06', snackSuggestion: 'Yogur griego con fruta'),
  MealPlanDay(weekNumber: 1, dayOfWeek: 2, lunchRecipeId: 'r04', dinnerRecipeId: 'r22', snackSuggestion: 'Queso fresco con nueces'),
  MealPlanDay(weekNumber: 1, dayOfWeek: 3, lunchRecipeId: 'r01', dinnerRecipeId: 'r07', snackSuggestion: 'Fruta de temporada'),
  MealPlanDay(weekNumber: 1, dayOfWeek: 4, lunchRecipeId: 'r09', dinnerRecipeId: 'r19', snackSuggestion: 'Yogur griego con whey'),
  MealPlanDay(weekNumber: 1, dayOfWeek: 5, lunchRecipeId: 'r08', dinnerRecipeId: 'r14', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 1, dayOfWeek: 6, lunchRecipeId: 'r21', dinnerRecipeId: 'r18', snackSuggestion: 'Kefir o yogur'),
  MealPlanDay(weekNumber: 1, dayOfWeek: 7, lunchRecipeId: 'r35', dinnerRecipeId: 'r43', snackSuggestion: 'Fruta + nueces'),

  // WEEK 2
  MealPlanDay(weekNumber: 2, dayOfWeek: 1, lunchRecipeId: 'r11', dinnerRecipeId: 'r38', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 2, dayOfWeek: 2, lunchRecipeId: 'r15', dinnerRecipeId: 'r28', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 2, dayOfWeek: 3, lunchRecipeId: 'r03', dinnerRecipeId: 'r22', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 2, dayOfWeek: 4, lunchRecipeId: 'r20', dinnerRecipeId: 'r06', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 2, dayOfWeek: 5, lunchRecipeId: 'r08', dinnerRecipeId: 'r46', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 2, dayOfWeek: 6, lunchRecipeId: 'r44', dinnerRecipeId: 'r47', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 2, dayOfWeek: 7, lunchRecipeId: 'r36', dinnerRecipeId: 'r29', snackSuggestion: 'Fruta + whey'),

  // WEEK 3
  MealPlanDay(weekNumber: 3, dayOfWeek: 1, lunchRecipeId: 'r33', dinnerRecipeId: 'r07', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 3, dayOfWeek: 2, lunchRecipeId: 'r26', dinnerRecipeId: 'r27', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 3, dayOfWeek: 3, lunchRecipeId: 'r17', dinnerRecipeId: 'r38', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 3, dayOfWeek: 4, lunchRecipeId: 'r12', dinnerRecipeId: 'r43', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 3, dayOfWeek: 5, lunchRecipeId: 'r25', dinnerRecipeId: 'r34', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 3, dayOfWeek: 6, lunchRecipeId: 'r42', dinnerRecipeId: 'r19', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 3, dayOfWeek: 7, lunchRecipeId: 'r16', dinnerRecipeId: 'r29', snackSuggestion: 'Fruta + yogur'),

  // WEEK 4
  MealPlanDay(weekNumber: 4, dayOfWeek: 1, lunchRecipeId: 'r39', dinnerRecipeId: 'r02', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 4, dayOfWeek: 2, lunchRecipeId: 'r23', dinnerRecipeId: 'r22', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 4, dayOfWeek: 3, lunchRecipeId: 'r30', dinnerRecipeId: 'r47', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 4, dayOfWeek: 4, lunchRecipeId: 'r05', dinnerRecipeId: 'r06', snackSuggestion: 'Yogur + whey'),
  MealPlanDay(weekNumber: 4, dayOfWeek: 5, lunchRecipeId: 'r31', dinnerRecipeId: 'r14', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 4, dayOfWeek: 6, lunchRecipeId: 'r21', dinnerRecipeId: 'r18', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 4, dayOfWeek: 7, lunchRecipeId: 'r40', dinnerRecipeId: 'r43', snackSuggestion: 'Fruta + nueces'),

  // WEEK 5
  MealPlanDay(weekNumber: 5, dayOfWeek: 1, lunchRecipeId: 'r01', dinnerRecipeId: 'r38', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 5, dayOfWeek: 2, lunchRecipeId: 'r04', dinnerRecipeId: 'r46', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 5, dayOfWeek: 3, lunchRecipeId: 'r03', dinnerRecipeId: 'r28', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 5, dayOfWeek: 4, lunchRecipeId: 'r37', dinnerRecipeId: 'r27', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 5, dayOfWeek: 5, lunchRecipeId: 'r08', dinnerRecipeId: 'r07', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 5, dayOfWeek: 6, lunchRecipeId: 'r44', dinnerRecipeId: 'r19', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 5, dayOfWeek: 7, lunchRecipeId: 'r35', dinnerRecipeId: 'r43', snackSuggestion: 'Fruta + yogur'),

  // WEEK 6
  MealPlanDay(weekNumber: 6, dayOfWeek: 1, lunchRecipeId: 'r11', dinnerRecipeId: 'r22', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 6, dayOfWeek: 2, lunchRecipeId: 'r15', dinnerRecipeId: 'r34', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 6, dayOfWeek: 3, lunchRecipeId: 'r13', dinnerRecipeId: 'r47', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 6, dayOfWeek: 4, lunchRecipeId: 'r24', dinnerRecipeId: 'r06', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 6, dayOfWeek: 5, lunchRecipeId: 'r33', dinnerRecipeId: 'r18', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 6, dayOfWeek: 6, lunchRecipeId: 'r41', dinnerRecipeId: 'r02', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 6, dayOfWeek: 7, lunchRecipeId: 'r36', dinnerRecipeId: 'r29', snackSuggestion: 'Fruta + whey'),

  // WEEK 7
  MealPlanDay(weekNumber: 7, dayOfWeek: 1, lunchRecipeId: 'r26', dinnerRecipeId: 'r07', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 7, dayOfWeek: 2, lunchRecipeId: 'r45', dinnerRecipeId: 'r22', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 7, dayOfWeek: 3, lunchRecipeId: 'r30', dinnerRecipeId: 'r38', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 7, dayOfWeek: 4, lunchRecipeId: 'r09', dinnerRecipeId: 'r19', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 7, dayOfWeek: 5, lunchRecipeId: 'r31', dinnerRecipeId: 'r14', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 7, dayOfWeek: 6, lunchRecipeId: 'r25', dinnerRecipeId: 'r46', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 7, dayOfWeek: 7, lunchRecipeId: 'r40', dinnerRecipeId: 'r43', snackSuggestion: 'Fruta + yogur'),

  // WEEK 8 (free meal day on Sunday)
  MealPlanDay(weekNumber: 8, dayOfWeek: 1, lunchRecipeId: 'r05', dinnerRecipeId: 'r28', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 8, dayOfWeek: 2, lunchRecipeId: 'r04', dinnerRecipeId: 'r06', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 8, dayOfWeek: 3, lunchRecipeId: 'r17', dinnerRecipeId: 'r22', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 8, dayOfWeek: 4, lunchRecipeId: 'r23', dinnerRecipeId: 'r47', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 8, dayOfWeek: 5, lunchRecipeId: 'r08', dinnerRecipeId: 'r18', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 8, dayOfWeek: 6, lunchRecipeId: 'r21', dinnerRecipeId: 'r07', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 8, dayOfWeek: 7, lunchRecipeId: 'r36', dinnerRecipeId: 'r43', snackSuggestion: 'Fruta + nueces'),

  // WEEK 9
  MealPlanDay(weekNumber: 9, dayOfWeek: 1, lunchRecipeId: 'r16', dinnerRecipeId: 'r38', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 9, dayOfWeek: 2, lunchRecipeId: 'r01', dinnerRecipeId: 'r34', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 9, dayOfWeek: 3, lunchRecipeId: 'r42', dinnerRecipeId: 'r06', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 9, dayOfWeek: 4, lunchRecipeId: 'r37', dinnerRecipeId: 'r19', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 9, dayOfWeek: 5, lunchRecipeId: 'r11', dinnerRecipeId: 'r14', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 9, dayOfWeek: 6, lunchRecipeId: 'r44', dinnerRecipeId: 'r46', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 9, dayOfWeek: 7, lunchRecipeId: 'r35', dinnerRecipeId: 'r29', snackSuggestion: 'Fruta + yogur'),

  // WEEK 10
  MealPlanDay(weekNumber: 10, dayOfWeek: 1, lunchRecipeId: 'r39', dinnerRecipeId: 'r02', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 10, dayOfWeek: 2, lunchRecipeId: 'r24', dinnerRecipeId: 'r27', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 10, dayOfWeek: 3, lunchRecipeId: 'r03', dinnerRecipeId: 'r28', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 10, dayOfWeek: 4, lunchRecipeId: 'r33', dinnerRecipeId: 'r22', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 10, dayOfWeek: 5, lunchRecipeId: 'r30', dinnerRecipeId: 'r47', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 10, dayOfWeek: 6, lunchRecipeId: 'r25', dinnerRecipeId: 'r18', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 10, dayOfWeek: 7, lunchRecipeId: 'r40', dinnerRecipeId: 'r43', snackSuggestion: 'Fruta + whey'),

  // WEEK 11
  MealPlanDay(weekNumber: 11, dayOfWeek: 1, lunchRecipeId: 'r05', dinnerRecipeId: 'r07', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 11, dayOfWeek: 2, lunchRecipeId: 'r26', dinnerRecipeId: 'r06', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 11, dayOfWeek: 3, lunchRecipeId: 'r17', dinnerRecipeId: 'r38', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 11, dayOfWeek: 4, lunchRecipeId: 'r12', dinnerRecipeId: 'r46', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 11, dayOfWeek: 5, lunchRecipeId: 'r01', dinnerRecipeId: 'r14', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 11, dayOfWeek: 6, lunchRecipeId: 'r32', dinnerRecipeId: 'r19', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 11, dayOfWeek: 7, lunchRecipeId: 'r36', dinnerRecipeId: 'r43', snackSuggestion: 'Fruta + nueces'),

  // WEEK 12 (free meal)
  MealPlanDay(weekNumber: 12, dayOfWeek: 1, lunchRecipeId: 'r45', dinnerRecipeId: 'r02', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 12, dayOfWeek: 2, lunchRecipeId: 'r04', dinnerRecipeId: 'r22', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 12, dayOfWeek: 3, lunchRecipeId: 'r08', dinnerRecipeId: 'r34', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 12, dayOfWeek: 4, lunchRecipeId: 'r37', dinnerRecipeId: 'r27', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 12, dayOfWeek: 5, lunchRecipeId: 'r11', dinnerRecipeId: 'r28', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 12, dayOfWeek: 6, lunchRecipeId: 'r44', dinnerRecipeId: 'r07', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 12, dayOfWeek: 7, lunchRecipeId: 'r36', dinnerRecipeId: 'r43', snackSuggestion: 'Fruta + yogur'),

  // WEEK 13
  MealPlanDay(weekNumber: 13, dayOfWeek: 1, lunchRecipeId: 'r16', dinnerRecipeId: 'r47', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 13, dayOfWeek: 2, lunchRecipeId: 'r23', dinnerRecipeId: 'r06', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 13, dayOfWeek: 3, lunchRecipeId: 'r42', dinnerRecipeId: 'r18', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 13, dayOfWeek: 4, lunchRecipeId: 'r09', dinnerRecipeId: 'r22', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 13, dayOfWeek: 5, lunchRecipeId: 'r30', dinnerRecipeId: 'r46', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 13, dayOfWeek: 6, lunchRecipeId: 'r41', dinnerRecipeId: 'r38', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 13, dayOfWeek: 7, lunchRecipeId: 'r40', dinnerRecipeId: 'r43', snackSuggestion: 'Fruta + nueces'),

  // WEEKS 14-26: rotate through patterns
  MealPlanDay(weekNumber: 14, dayOfWeek: 1, lunchRecipeId: 'r05', dinnerRecipeId: 'r28', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 14, dayOfWeek: 2, lunchRecipeId: 'r03', dinnerRecipeId: 'r06', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 14, dayOfWeek: 3, lunchRecipeId: 'r01', dinnerRecipeId: 'r22', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 14, dayOfWeek: 4, lunchRecipeId: 'r26', dinnerRecipeId: 'r19', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 14, dayOfWeek: 5, lunchRecipeId: 'r08', dinnerRecipeId: 'r14', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 14, dayOfWeek: 6, lunchRecipeId: 'r21', dinnerRecipeId: 'r07', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 14, dayOfWeek: 7, lunchRecipeId: 'r35', dinnerRecipeId: 'r43', snackSuggestion: 'Fruta + yogur'),

  MealPlanDay(weekNumber: 15, dayOfWeek: 1, lunchRecipeId: 'r33', dinnerRecipeId: 'r02', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 15, dayOfWeek: 2, lunchRecipeId: 'r24', dinnerRecipeId: 'r47', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 15, dayOfWeek: 3, lunchRecipeId: 'r17', dinnerRecipeId: 'r38', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 15, dayOfWeek: 4, lunchRecipeId: 'r12', dinnerRecipeId: 'r22', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 15, dayOfWeek: 5, lunchRecipeId: 'r04', dinnerRecipeId: 'r18', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 15, dayOfWeek: 6, lunchRecipeId: 'r44', dinnerRecipeId: 'r46', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 15, dayOfWeek: 7, lunchRecipeId: 'r36', dinnerRecipeId: 'r29', snackSuggestion: 'Fruta + whey'),

  MealPlanDay(weekNumber: 16, dayOfWeek: 1, lunchRecipeId: 'r39', dinnerRecipeId: 'r06', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 16, dayOfWeek: 2, lunchRecipeId: 'r45', dinnerRecipeId: 'r22', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 16, dayOfWeek: 3, lunchRecipeId: 'r30', dinnerRecipeId: 'r34', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 16, dayOfWeek: 4, lunchRecipeId: 'r11', dinnerRecipeId: 'r27', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 16, dayOfWeek: 5, lunchRecipeId: 'r16', dinnerRecipeId: 'r14', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 16, dayOfWeek: 6, lunchRecipeId: 'r25', dinnerRecipeId: 'r19', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 16, dayOfWeek: 7, lunchRecipeId: 'r40', dinnerRecipeId: 'r43', snackSuggestion: 'Fruta + nueces'),

  MealPlanDay(weekNumber: 17, dayOfWeek: 1, lunchRecipeId: 'r01', dinnerRecipeId: 'r07', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 17, dayOfWeek: 2, lunchRecipeId: 'r37', dinnerRecipeId: 'r28', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 17, dayOfWeek: 3, lunchRecipeId: 'r42', dinnerRecipeId: 'r47', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 17, dayOfWeek: 4, lunchRecipeId: 'r09', dinnerRecipeId: 'r06', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 17, dayOfWeek: 5, lunchRecipeId: 'r31', dinnerRecipeId: 'r22', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 17, dayOfWeek: 6, lunchRecipeId: 'r21', dinnerRecipeId: 'r02', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 17, dayOfWeek: 7, lunchRecipeId: 'r36', dinnerRecipeId: 'r43', snackSuggestion: 'Fruta + yogur'),

  MealPlanDay(weekNumber: 18, dayOfWeek: 1, lunchRecipeId: 'r05', dinnerRecipeId: 'r38', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 18, dayOfWeek: 2, lunchRecipeId: 'r23', dinnerRecipeId: 'r18', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 18, dayOfWeek: 3, lunchRecipeId: 'r03', dinnerRecipeId: 'r46', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 18, dayOfWeek: 4, lunchRecipeId: 'r15', dinnerRecipeId: 'r22', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 18, dayOfWeek: 5, lunchRecipeId: 'r08', dinnerRecipeId: 'r34', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 18, dayOfWeek: 6, lunchRecipeId: 'r44', dinnerRecipeId: 'r19', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 18, dayOfWeek: 7, lunchRecipeId: 'r35', dinnerRecipeId: 'r29', snackSuggestion: 'Fruta + nueces'),

  MealPlanDay(weekNumber: 19, dayOfWeek: 1, lunchRecipeId: 'r16', dinnerRecipeId: 'r07', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 19, dayOfWeek: 2, lunchRecipeId: 'r04', dinnerRecipeId: 'r27', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 19, dayOfWeek: 3, lunchRecipeId: 'r30', dinnerRecipeId: 'r22', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 19, dayOfWeek: 4, lunchRecipeId: 'r26', dinnerRecipeId: 'r47', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 19, dayOfWeek: 5, lunchRecipeId: 'r11', dinnerRecipeId: 'r14', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 19, dayOfWeek: 6, lunchRecipeId: 'r25', dinnerRecipeId: 'r06', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 19, dayOfWeek: 7, lunchRecipeId: 'r40', dinnerRecipeId: 'r43', snackSuggestion: 'Fruta + whey'),

  MealPlanDay(weekNumber: 20, dayOfWeek: 1, lunchRecipeId: 'r33', dinnerRecipeId: 'r38', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 20, dayOfWeek: 2, lunchRecipeId: 'r01', dinnerRecipeId: 'r28', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 20, dayOfWeek: 3, lunchRecipeId: 'r17', dinnerRecipeId: 'r02', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 20, dayOfWeek: 4, lunchRecipeId: 'r39', dinnerRecipeId: 'r22', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 20, dayOfWeek: 5, lunchRecipeId: 'r08', dinnerRecipeId: 'r18', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 20, dayOfWeek: 6, lunchRecipeId: 'r41', dinnerRecipeId: 'r46', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 20, dayOfWeek: 7, lunchRecipeId: 'r36', dinnerRecipeId: 'r43', snackSuggestion: 'Fruta + yogur'),

  MealPlanDay(weekNumber: 21, dayOfWeek: 1, lunchRecipeId: 'r03', dinnerRecipeId: 'r07', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 21, dayOfWeek: 2, lunchRecipeId: 'r45', dinnerRecipeId: 'r06', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 21, dayOfWeek: 3, lunchRecipeId: 'r42', dinnerRecipeId: 'r47', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 21, dayOfWeek: 4, lunchRecipeId: 'r24', dinnerRecipeId: 'r19', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 21, dayOfWeek: 5, lunchRecipeId: 'r12', dinnerRecipeId: 'r14', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 21, dayOfWeek: 6, lunchRecipeId: 'r32', dinnerRecipeId: 'r38', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 21, dayOfWeek: 7, lunchRecipeId: 'r40', dinnerRecipeId: 'r29', snackSuggestion: 'Fruta + nueces'),

  MealPlanDay(weekNumber: 22, dayOfWeek: 1, lunchRecipeId: 'r09', dinnerRecipeId: 'r22', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 22, dayOfWeek: 2, lunchRecipeId: 'r23', dinnerRecipeId: 'r34', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 22, dayOfWeek: 3, lunchRecipeId: 'r05', dinnerRecipeId: 'r28', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 22, dayOfWeek: 4, lunchRecipeId: 'r37', dinnerRecipeId: 'r06', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 22, dayOfWeek: 5, lunchRecipeId: 'r11', dinnerRecipeId: 'r18', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 22, dayOfWeek: 6, lunchRecipeId: 'r44', dinnerRecipeId: 'r46', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 22, dayOfWeek: 7, lunchRecipeId: 'r36', dinnerRecipeId: 'r43', snackSuggestion: 'Fruta + yogur'),

  MealPlanDay(weekNumber: 23, dayOfWeek: 1, lunchRecipeId: 'r16', dinnerRecipeId: 'r02', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 23, dayOfWeek: 2, lunchRecipeId: 'r31', dinnerRecipeId: 'r27', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 23, dayOfWeek: 3, lunchRecipeId: 'r30', dinnerRecipeId: 'r47', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 23, dayOfWeek: 4, lunchRecipeId: 'r26', dinnerRecipeId: 'r22', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 23, dayOfWeek: 5, lunchRecipeId: 'r08', dinnerRecipeId: 'r14', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 23, dayOfWeek: 6, lunchRecipeId: 'r25', dinnerRecipeId: 'r07', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 23, dayOfWeek: 7, lunchRecipeId: 'r35', dinnerRecipeId: 'r43', snackSuggestion: 'Fruta + whey'),

  MealPlanDay(weekNumber: 24, dayOfWeek: 1, lunchRecipeId: 'r01', dinnerRecipeId: 'r38', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 24, dayOfWeek: 2, lunchRecipeId: 'r04', dinnerRecipeId: 'r06', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 24, dayOfWeek: 3, lunchRecipeId: 'r03', dinnerRecipeId: 'r19', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 24, dayOfWeek: 4, lunchRecipeId: 'r15', dinnerRecipeId: 'r22', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 24, dayOfWeek: 5, lunchRecipeId: 'r33', dinnerRecipeId: 'r18', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 24, dayOfWeek: 6, lunchRecipeId: 'r21', dinnerRecipeId: 'r46', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 24, dayOfWeek: 7, lunchRecipeId: 'r40', dinnerRecipeId: 'r29', snackSuggestion: 'Fruta + nueces'),

  MealPlanDay(weekNumber: 25, dayOfWeek: 1, lunchRecipeId: 'r39', dinnerRecipeId: 'r28', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 25, dayOfWeek: 2, lunchRecipeId: 'r24', dinnerRecipeId: 'r47', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 25, dayOfWeek: 3, lunchRecipeId: 'r42', dinnerRecipeId: 'r07', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 25, dayOfWeek: 4, lunchRecipeId: 'r09', dinnerRecipeId: 'r06', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 25, dayOfWeek: 5, lunchRecipeId: 'r11', dinnerRecipeId: 'r34', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 25, dayOfWeek: 6, lunchRecipeId: 'r44', dinnerRecipeId: 'r02', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 25, dayOfWeek: 7, lunchRecipeId: 'r36', dinnerRecipeId: 'r43', snackSuggestion: 'Fruta + yogur'),

  MealPlanDay(weekNumber: 26, dayOfWeek: 1, lunchRecipeId: 'r05', dinnerRecipeId: 'r22', snackSuggestion: 'Yogur griego'),
  MealPlanDay(weekNumber: 26, dayOfWeek: 2, lunchRecipeId: 'r45', dinnerRecipeId: 'r06', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 26, dayOfWeek: 3, lunchRecipeId: 'r17', dinnerRecipeId: 'r38', snackSuggestion: 'Queso fresco'),
  MealPlanDay(weekNumber: 26, dayOfWeek: 4, lunchRecipeId: 'r12', dinnerRecipeId: 'r19', snackSuggestion: 'Yogur + fruta'),
  MealPlanDay(weekNumber: 26, dayOfWeek: 5, lunchRecipeId: 'r08', dinnerRecipeId: 'r18', snackSuggestion: 'Fruta'),
  MealPlanDay(weekNumber: 26, dayOfWeek: 6, lunchRecipeId: 'r41', dinnerRecipeId: 'r46', snackSuggestion: 'Kefir'),
  MealPlanDay(weekNumber: 26, dayOfWeek: 7, lunchRecipeId: 'r36', dinnerRecipeId: 'r43', snackSuggestion: 'Fruta + nueces'),
];

MealPlanDay? getMealPlanDay(int weekNumber, int dayOfWeek) {
  try {
    return seedMealPlan.firstWhere(
        (d) => d.weekNumber == weekNumber && d.dayOfWeek == dayOfWeek);
  } catch (_) {
    return null;
  }
}
