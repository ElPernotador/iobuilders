import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/recipe.dart';

/// Fetches recipes from TheMealDB free public API (no key required).
/// https://www.themealdb.com/api.php
///
/// TheMealDB is English-first, so a small ES→EN map + category browsing make it
/// usable for a Spanish speaker. Recipes are generic and mapped into [Recipe];
/// saved as custom recipes when the user keeps one.
class MealDbService {
  static const _base = 'https://www.themealdb.com/api/json/v1/1';

  /// Categories surfaced as quick-browse chips (TheMealDB category names).
  static const categories = [
    'Chicken', 'Beef', 'Seafood', 'Pasta', 'Vegetarian', 'Breakfast', 'Dessert',
  ];

  /// Spanish (and common) terms → TheMealDB search terms.
  static const _esToEn = {
    'pollo': 'chicken',
    'pechuga': 'chicken',
    'gallina': 'chicken',
    'carne': 'beef',
    'ternera': 'beef',
    'res': 'beef',
    'vaca': 'beef',
    'cerdo': 'pork',
    'chancho': 'pork',
    'pescado': 'fish',
    'salmon': 'salmon',
    'atun': 'tuna',
    'gambas': 'shrimp',
    'camaron': 'shrimp',
    'camarones': 'shrimp',
    'marisco': 'seafood',
    'mariscos': 'seafood',
    'huevo': 'omelette',
    'huevos': 'omelette',
    'tortilla': 'omelette',
    'verdura': 'vegetarian',
    'verduras': 'vegetarian',
    'vegetariano': 'vegetarian',
    'ensalada': 'salad',
    'pasta': 'pasta',
    'arroz': 'rice',
    'sopa': 'soup',
    'desayuno': 'breakfast',
    'postre': 'dessert',
    'queso': 'cheese',
    'lenteja': 'lentils',
    'lentejas': 'lentils',
    'cordero': 'lamb',
    'pavo': 'turkey',
  };

  static String _stripAccents(String s) {
    const from = 'áàäâãéèëêíìïîóòöôõúùüûñç';
    const to = 'aaaaaeeeeiiiiooooouuuunc';
    var r = s.toLowerCase();
    for (var i = 0; i < from.length; i++) {
      r = r.replaceAll(from[i], to[i]);
    }
    return r;
  }

  /// Translates a known Spanish food word; otherwise returns the query as-is.
  static String _normalize(String query) {
    final q = _stripAccents(query.trim());
    if (_esToEn.containsKey(q)) return _esToEn[q]!;
    for (final word in q.split(RegExp(r'\s+'))) {
      if (_esToEn.containsKey(word)) return _esToEn[word]!;
    }
    return query.trim();
  }

  static Future<Map<String, dynamic>> _get(String path) async {
    final res = await http.get(Uri.parse('$_base/$path')).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('Respuesta del servidor: HTTP ${res.statusCode}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Search by name (full recipes). Falls back to ingredient filter (stubs)
  /// when the name search finds nothing.
  static Future<List<Recipe>> searchByName(String query) async {
    final term = _normalize(query);
    final data = await _get('search.php?s=${Uri.encodeQueryComponent(term)}');
    final meals = data['meals'] as List<dynamic>?;
    if (meals != null && meals.isNotEmpty) {
      return meals.map((m) => _mapMeal(m as Map<String, dynamic>)).whereType<Recipe>().toList();
    }
    // Fallback: ingredient filter (returns lightweight stubs).
    return _filter('filter.php?i=${Uri.encodeQueryComponent(term.replaceAll(' ', '_'))}');
  }

  /// Browse a category → lightweight stubs (need [lookupById] for details).
  static Future<List<Recipe>> browseByCategory(String category) =>
      _filter('filter.php?c=${Uri.encodeQueryComponent(category)}');

  static Future<List<Recipe>> _filter(String path) async {
    final data = await _get(path);
    final meals = data['meals'] as List<dynamic>?;
    if (meals == null) return [];
    return meals.map((m) => _mapStub(m as Map<String, dynamic>)).whereType<Recipe>().toList();
  }

  /// Full recipe by id ('md_<idMeal>' or raw idMeal).
  static Future<Recipe?> lookupById(String id) async {
    final raw = id.replaceFirst('md_', '');
    final data = await _get('lookup.php?i=${Uri.encodeQueryComponent(raw)}');
    final meals = data['meals'] as List<dynamic>?;
    if (meals == null || meals.isEmpty) return null;
    return _mapMeal(meals.first as Map<String, dynamic>);
  }

  /// A lightweight result (name only) — tag 'stub' means details must be
  /// fetched via [lookupById] before preview/save.
  static Recipe? _mapStub(Map<String, dynamic> m) {
    final id = m['idMeal']?.toString();
    final title = (m['strMeal'] as String?)?.trim();
    if (id == null || title == null || title.isEmpty) return null;
    return Recipe(
      id: 'md_$id',
      title: title,
      category: 'Internet',
      prepMinutes: 0,
      cookMinutes: 0,
      servings: 2,
      ingredients: const [],
      steps: const [],
      proteinLevel: 'medium',
      carbLevel: 'unknown',
      gutNote: '',
      liverNote: '',
      oilLimitNote: '',
      tags: const ['themealdb', 'internet', 'stub'],
    );
  }

  static bool isStub(Recipe r) => r.tags.contains('stub') || r.steps.isEmpty;

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
