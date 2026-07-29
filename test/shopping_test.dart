import 'package:flutter_test/flutter_test.dart';
import 'package:dieter/data/seed_shopping.dart';

void main() {
  group('Shopping list grouping', () {
    test('items are grouped by category', () {
      final items = getShoppingListForWeek(1, '2026-W27');
      final grouped = <String, List<String>>{};
      for (final item in items) {
        grouped.putIfAbsent(item.category, () => []).add(item.name);
      }
      expect(grouped.containsKey('Proteínas'), isTrue);
      expect(grouped.containsKey('Verduras'), isTrue);
      expect(grouped.containsKey('Lácteos'), isTrue);
    });

    test('all items have non-empty name and category', () {
      final items = getShoppingListForWeek(1, '2026-W27');
      for (final item in items) {
        expect(item.name.isNotEmpty, isTrue);
        expect(item.category.isNotEmpty, isTrue);
      }
    });

    test('items start unchecked', () {
      final items = getShoppingListForWeek(1, '2026-W27');
      expect(items.every((i) => !i.checked), isTrue);
    });

    test('week index wraps modulo 2 for seed data', () {
      final w1 = getShoppingListForWeek(1, '2026-W01');
      final w3 = getShoppingListForWeek(3, '2026-W03'); // same as week 1
      expect(w1.length, equals(w3.length));
    });
  });
}
