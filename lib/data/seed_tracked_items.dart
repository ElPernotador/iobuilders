import '../core/models/custom_item.dart';

/// Default daily trackables seeded on first run. They are ordinary rows once
/// seeded — the user can rename, delete, reorder them or add their own.
/// [CustomItem.icon] is a key resolved by `iconForKey` in the UI.
const List<Map<String, String>> defaultTrackedItems = [
  // Suplementos
  {'name': 'Whey', 'section': 'supplement', 'icon': 'drink'},
  {'name': 'Creatina', 'section': 'supplement', 'icon': 'bolt'},
  {'name': 'MSM', 'section': 'supplement', 'icon': 'healing'},
  {'name': 'Colina', 'section': 'supplement', 'icon': 'spa'},
  {'name': 'Fenogreco', 'section': 'supplement', 'icon': 'grass'},
  {'name': 'Probiótico', 'section': 'supplement', 'icon': 'biotech'},
  {'name': 'Vitamina D', 'section': 'supplement', 'icon': 'sun'},
  {'name': 'Omega 3', 'section': 'supplement', 'icon': 'water'},
  // Alimentación
  {'name': 'Fruta del día', 'section': 'food', 'icon': 'apple'},
  {'name': '2 L de agua', 'section': 'food', 'icon': 'drink'},
  {'name': 'Objetivo proteína', 'section': 'food', 'icon': 'egg'},
  {'name': 'Sin bun/pan', 'section': 'food', 'icon': 'nofood'},
  {'name': 'Sin ultraprocesados', 'section': 'food', 'icon': 'fastfood'},
];

/// Rows ready for insertion, with a stable initial order.
List<CustomItem> defaultTrackedItemsAsModels() {
  final out = <CustomItem>[];
  for (var i = 0; i < defaultTrackedItems.length; i++) {
    final d = defaultTrackedItems[i];
    out.add(CustomItem(
      name: d['name']!,
      section: d['section']!,
      icon: d['icon'],
      sortOrder: i,
    ));
  }
  return out;
}
