/// Turns recipe ingredient lines into a consolidated shopping list.
///
/// Recipe ingredients are free text in a few shapes:
///   `200g carne picada magra`  → 200 g of "carne picada magra"
///   `1 tsp curry`              → 1 cdta of "curry"
///   `1 cebolla`                → 1 unit of "cebolla"
///   `sal`                      → just "sal", no quantity
/// Lines for the same ingredient and unit are summed so a week's plan collapses
/// into one line per item.
library;

/// One consolidated shopping-list entry.
class AggregatedIngredient {
  final String name;
  final double? quantity;
  final String? unit;

  /// How many recipe lines fed into this entry (used when nothing is countable).
  final int occurrences;

  const AggregatedIngredient({
    required this.name,
    this.quantity,
    this.unit,
    this.occurrences = 1,
  });

  String get displayName =>
      name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);

  /// e.g. `Carne picada magra (300 g)`, `Cebolla (2 uds)`, `Sal`.
  String get label {
    if (quantity == null) {
      return occurrences > 1 ? '$displayName (x$occurrences)' : displayName;
    }
    final qty = _formatQty(quantity!);
    if (unit == null) {
      return quantity == 1 ? displayName : '$displayName ($qty uds)';
    }
    return '$displayName ($qty $unit)';
  }

  static String _formatQty(double q) =>
      q == q.roundToDouble() ? q.round().toString() : q.toStringAsFixed(1);
}

class IngredientAggregator {
  /// Units we recognise, mapped to a canonical form.
  static const _units = <String, String>{
    'g': 'g', 'gr': 'g', 'gramo': 'g', 'gramos': 'g',
    'kg': 'kg', 'kilo': 'kg', 'kilos': 'kg',
    'ml': 'ml',
    'l': 'l', 'litro': 'l', 'litros': 'l',
    'tsp': 'cdta', 'cdta': 'cdta', 'cucharadita': 'cdta', 'cucharaditas': 'cdta',
    'tbsp': 'cda', 'cda': 'cda', 'cucharada': 'cda', 'cucharadas': 'cda',
    'taza': 'taza', 'tazas': 'taza',
    'lata': 'lata', 'latas': 'lata',
    'ud': 'ud', 'uds': 'ud', 'unidad': 'ud', 'unidades': 'ud',
    'diente': 'diente', 'dientes': 'diente',
    'puñado': 'puñado', 'punado': 'puñado',
  };

  static final _linePattern = RegExp(
    r'^(\d+(?:[.,]\d+)?)\s*([a-zA-ZáéíóúñÁÉÍÓÚÑ]+)?\s*(.*)$',
  );

  static String stripAccents(String s) {
    const from = 'áàäâãéèëêíìïîóòöôõúùüûñç';
    const to = 'aaaaaeeeeiiiiooooouuuunc';
    var r = s.toLowerCase();
    for (var i = 0; i < from.length; i++) {
      r = r.replaceAll(from[i], to[i]);
    }
    return r;
  }

  /// Parses one ingredient line. Returns quantity/unit when present.
  static AggregatedIngredient parseLine(String raw) {
    final line = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (line.isEmpty) return const AggregatedIngredient(name: '');

    final m = _linePattern.firstMatch(line);
    if (m == null) return AggregatedIngredient(name: line.toLowerCase());

    final qty = double.tryParse(m.group(1)!.replaceAll(',', '.'));
    if (qty == null) return AggregatedIngredient(name: line.toLowerCase());

    final maybeUnit = m.group(2);
    final rest = (m.group(3) ?? '').trim();

    if (maybeUnit != null && maybeUnit.isNotEmpty) {
      final canonical = _units[stripAccents(maybeUnit)];
      if (canonical != null) {
        // "200g carne" / "1 tsp curry"
        final name = rest.isEmpty ? maybeUnit.toLowerCase() : rest.toLowerCase();
        return AggregatedIngredient(
            name: name, quantity: qty, unit: rest.isEmpty ? null : canonical);
      }
      // Not a unit — it's the start of the name: "1 cebolla grande"
      final name = ('$maybeUnit ${rest.isEmpty ? '' : rest}').trim().toLowerCase();
      return AggregatedIngredient(name: name, quantity: qty);
    }

    if (rest.isEmpty) return AggregatedIngredient(name: line.toLowerCase());
    return AggregatedIngredient(name: rest.toLowerCase(), quantity: qty);
  }

  /// Consolidates many ingredient lines into one entry per name+unit.
  static List<AggregatedIngredient> aggregate(Iterable<String> lines) {
    final byKey = <String, AggregatedIngredient>{};
    for (final raw in lines) {
      final parsed = parseLine(raw);
      if (parsed.name.isEmpty) continue;
      final key = '${stripAccents(parsed.name)}|${parsed.unit ?? ''}';
      final existing = byKey[key];
      if (existing == null) {
        byKey[key] = parsed;
        continue;
      }
      final bothCountable = existing.quantity != null && parsed.quantity != null;
      byKey[key] = AggregatedIngredient(
        name: existing.name,
        unit: existing.unit,
        quantity: bothCountable
            ? existing.quantity! + parsed.quantity!
            : (existing.quantity ?? parsed.quantity),
        occurrences: existing.occurrences + 1,
      );
    }
    final out = byKey.values.toList();
    out.sort((a, b) => a.name.compareTo(b.name));
    return out;
  }

  static const _categoryKeywords = <String, List<String>>{
    'Proteínas': [
      'pollo', 'pechuga', 'carne', 'ternera', 'cerdo', 'lomo', 'pavo', 'jamon',
      'pescado', 'salmon', 'atun', 'merluza', 'bacalao', 'sardina', 'gambas',
      'langostino', 'huevo', 'tofu', 'seitan', 'tempeh',
    ],
    'Lácteos': [
      'yogur', 'queso', 'leche', 'kefir', 'mantequilla', 'nata', 'requeson',
    ],
    'Verduras': [
      'lechuga', 'tomate', 'cebolla', 'ajo', 'pimiento', 'calabacin',
      'espinaca', 'brocoli', 'champinon', 'seta', 'zanahoria', 'berenjena',
      'pepino', 'apio', 'puerro', 'col', 'coliflor', 'rucula', 'canonigo',
      'esparrago', 'judia', 'aguacate', 'calabaza', 'remolacha', 'verdura',
    ],
    'Fruta': [
      'manzana', 'platano', 'banana', 'fresa', 'arandano', 'naranja', 'pera',
      'kiwi', 'limon', 'melon', 'sandia', 'uva', 'pina', 'mandarina',
      'frutos rojos', 'fruta', 'ciruela', 'melocoton',
    ],
    'Despensa': [
      'aceite', 'sal', 'pimienta', 'especia', 'curry', 'curcuma', 'pimenton',
      'comino', 'oregano', 'mostaza', 'vinagre', 'arroz', 'quinoa', 'avena',
      'pasta', 'harina', 'garbanzo', 'lenteja', 'alubia', 'frijol', 'caldo',
      'nuez', 'nueces', 'almendra', 'semilla', 'canela', 'cacao', 'miel',
      'tahini', 'salsa', 'levadura', 'pan',
    ],
    'Suplementos': [
      'whey', 'creatina', 'msm', 'colina', 'fenogreco', 'probiotico',
      'vitamina', 'omega', 'magnesio',
    ],
  };

  /// Best-effort shopping category for an ingredient name.
  static String categoryFor(String name) {
    final n = stripAccents(name);
    for (final entry in _categoryKeywords.entries) {
      for (final keyword in entry.value) {
        if (n.contains(keyword)) return entry.key;
      }
    }
    return 'Otros';
  }
}
