import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/recipe.dart';

/// Fetches recipes from TheMealDB free public API (no key required).
/// https://www.themealdb.com/api.php
///
/// Recipes are generic and mostly in English; mapped into our [Recipe] model
/// and saved as custom recipes when the user chooses to keep one.
class MealDbService {
  static const _base = 'https://www.themealdb.com/api/json/v1/1';

  /// Search recipes by name. Returns mapped [Recipe]s (may be empty).
  static Future<List<Recipe>> searchByName(String query) async {
    final uri = Uri.parse('$_base/search.php?s=${Uri.encodeQueryComponent(query)}');
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final meals = data['meals'] as List<dynamic>?;
    if (meals == null) return [];
    return meals
        .map((m) => _mapMeal(m as Map<String, dynamic>))
        .whereType<Recipe>()
        .toList();
  }

  static Recipe? _mapMeal(Map<String, dynamic> m) {
    final id = m['idMeal']?.toString();
    final title = (m['strMeal'] as String?)?.trim();
    if (id == null || title == null || title.isEmpty) return null;

    final ingredients = <String>[];
    for (var i = 1; i <= 20; i++) {
      final ing = (m['strIngredient$i'] as String?)?.trim() ?? '';
      final measure = (m['strMeasure$i'] as String?)?.trim() ?? '';
      if (ing.isEmpty) continue;
      ingredients.add(measure.isEmpty ? ing : '$measure $ing');
    }

    final instructions = (m['strInstructions'] as String?)?.trim() ?? '';
    final steps = instructions
        .split(RegExp(r'\r?\n|(?<=\.)\s+(?=[A-ZÁÉÍÓÚ])'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final category = (m['strCategory'] as String?)?.trim() ?? 'Internet';

    return Recipe(
      id: 'md_$id',
      title: title,
      category: category,
      prepMinutes: 0,
      cookMinutes: 0,
      servings: 2,
      ingredients: ingredients,
      steps: steps.isEmpty ? [instructions] : steps,
      proteinLevel: 'medium',
      carbLevel: 'unknown',
      gutNote: '',
      liverNote: '',
      oilLimitNote: 'Receta de TheMealDB — ajusta aceite y carbohidratos a tus objetivos.',
      tags: const ['themealdb', 'internet'],
    );
  }
}
