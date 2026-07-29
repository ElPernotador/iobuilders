/// A user-editable daily trackable (e.g. "Whey", "Minoxidil"). Everything the
/// Hoy checklist shows is one of these — the defaults are just pre-seeded rows,
/// so they can be renamed, deleted, reordered or added to.
class CustomItem {
  int? id;
  String name;
  String section; // 'supplement' | 'food' | 'training'
  int sortOrder;

  /// Icon key resolved by the UI (see `iconForKey`); null → default icon.
  String? icon;

  CustomItem({
    this.id,
    required this.name,
    required this.section,
    this.sortOrder = 0,
    this.icon,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'section': section,
        'sortOrder': sortOrder,
        'icon': icon,
      };

  factory CustomItem.fromMap(Map<String, dynamic> m) => CustomItem(
        id: m['id'],
        name: m['name'],
        section: m['section'],
        sortOrder: m['sortOrder'] ?? 0,
        icon: m['icon'] as String?,
      );

  CustomItem copyWith({String? name, String? section, int? sortOrder, String? icon}) =>
      CustomItem(
        id: id,
        name: name ?? this.name,
        section: section ?? this.section,
        sortOrder: sortOrder ?? this.sortOrder,
        icon: icon ?? this.icon,
      );
}
