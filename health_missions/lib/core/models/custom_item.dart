/// A user-defined trackable item (e.g. "Minoxidil", "Magnesio") that lives
/// alongside the built-in daily checks. Section groups it under the right
/// header on the Today screen.
class CustomItem {
  int? id;
  String name;
  String section; // 'supplement' | 'food' | 'training'
  int sortOrder;

  CustomItem({
    this.id,
    required this.name,
    required this.section,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'section': section,
        'sortOrder': sortOrder,
      };

  factory CustomItem.fromMap(Map<String, dynamic> m) => CustomItem(
        id: m['id'],
        name: m['name'],
        section: m['section'],
        sortOrder: m['sortOrder'] ?? 0,
      );
}
