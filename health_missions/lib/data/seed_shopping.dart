import '../core/models/recipe.dart';

// Static weekly shopping lists derived from meal plan
// Grouped by category: proteins, vegetables, dairy, pantry, fruit, supplements
const Map<int, List<Map<String, String>>> weeklyShoppingLists = {
  1: [
    {'name': 'Pechuga de pollo (600g)', 'category': 'Proteínas'},
    {'name': 'Carne picada magra (400g)', 'category': 'Proteínas'},
    {'name': 'Atún al natural (3 latas)', 'category': 'Proteínas'},
    {'name': 'Huevos (12 uds)', 'category': 'Proteínas'},
    {'name': 'Salmón (200g)', 'category': 'Proteínas'},
    {'name': 'Lechuga romana (1 ud)', 'category': 'Verduras'},
    {'name': 'Tomates (1kg)', 'category': 'Verduras'},
    {'name': 'Pimientos rojos (3 uds)', 'category': 'Verduras'},
    {'name': 'Calabacín (2 uds)', 'category': 'Verduras'},
    {'name': 'Espinacas (200g)', 'category': 'Verduras'},
    {'name': 'Brócoli (1 ud)', 'category': 'Verduras'},
    {'name': 'Champiñones (200g)', 'category': 'Verduras'},
    {'name': 'Zanahoria (500g)', 'category': 'Verduras'},
    {'name': 'Cebolla (1kg)', 'category': 'Verduras'},
    {'name': 'Ajo (1 cabeza)', 'category': 'Verduras'},
    {'name': 'Yogur griego 0% (500g)', 'category': 'Lácteos'},
    {'name': 'Queso fresco (200g)', 'category': 'Lácteos'},
    {'name': 'Aceite de oliva virgen extra', 'category': 'Despensa'},
    {'name': 'Mostaza dijon', 'category': 'Despensa'},
    {'name': 'Sal, pimienta, especias', 'category': 'Despensa'},
    {'name': 'Fresas o arándanos (250g)', 'category': 'Fruta'},
    {'name': 'Fruta de temporada (3-4 uds)', 'category': 'Fruta'},
    {'name': 'Whey protein', 'category': 'Suplementos'},
    {'name': 'Creatina', 'category': 'Suplementos'},
  ],
  2: [
    {'name': 'Pechuga de pollo (600g)', 'category': 'Proteínas'},
    {'name': 'Caballa en aceite (3 latas)', 'category': 'Proteínas'},
    {'name': 'Huevos (12 uds)', 'category': 'Proteínas'},
    {'name': 'Salmón (200g)', 'category': 'Proteínas'},
    {'name': 'Pavo filete (200g)', 'category': 'Proteínas'},
    {'name': 'Lechuga (1 ud)', 'category': 'Verduras'},
    {'name': 'Tomates (1kg)', 'category': 'Verduras'},
    {'name': 'Espárragos (1 manojo)', 'category': 'Verduras'},
    {'name': 'Espinacas baby (150g)', 'category': 'Verduras'},
    {'name': 'Pimiento verde (2 uds)', 'category': 'Verduras'},
    {'name': 'Calabacín (2 uds)', 'category': 'Verduras'},
    {'name': 'Cebolla (1kg)', 'category': 'Verduras'},
    {'name': 'Yogur griego 0% (500g)', 'category': 'Lácteos'},
    {'name': 'Queso fresco (200g)', 'category': 'Lácteos'},
    {'name': 'Quinoa (250g)', 'category': 'Despensa'},
    {'name': 'Curry en polvo', 'category': 'Despensa'},
    {'name': 'Cúrcuma', 'category': 'Despensa'},
    {'name': 'Fruta de temporada (4 uds)', 'category': 'Fruta'},
    {'name': 'Arándanos o fresas (250g)', 'category': 'Fruta'},
    {'name': 'Whey protein', 'category': 'Suplementos'},
  ],
};

List<ShoppingItem> getShoppingListForWeek(int weekNumber, String weekKey) {
  final weekIndex = ((weekNumber - 1) % 2) + 1;
  final rawList = weeklyShoppingLists[weekIndex] ?? weeklyShoppingLists[1]!;
  return rawList
      .map((item) => ShoppingItem(
            weekKey: weekKey,
            name: item['name']!,
            category: item['category']!,
          ))
      .toList();
}
