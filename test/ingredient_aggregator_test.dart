import 'package:flutter_test/flutter_test.dart';
import 'package:dieter/core/ingredient_aggregator.dart';

void main() {
  group('parseLine', () {
    test('quantity glued to unit', () {
      final r = IngredientAggregator.parseLine('200g carne picada magra');
      expect(r.name, equals('carne picada magra'));
      expect(r.quantity, equals(200));
      expect(r.unit, equals('g'));
    });

    test('quantity with spaced unit, english unit normalised', () {
      final r = IngredientAggregator.parseLine('1 tsp curry');
      expect(r.name, equals('curry'));
      expect(r.quantity, equals(1));
      expect(r.unit, equals('cdta'));
    });

    test('bare count with no unit', () {
      final r = IngredientAggregator.parseLine('1 cebolla');
      expect(r.name, equals('cebolla'));
      expect(r.quantity, equals(1));
      expect(r.unit, isNull);
    });

    test('multi-word name after a count keeps all words', () {
      final r = IngredientAggregator.parseLine('2 pimientos rojos');
      expect(r.name, equals('pimientos rojos'));
      expect(r.quantity, equals(2));
    });

    test('no quantity at all', () {
      final r = IngredientAggregator.parseLine('aceite oliva');
      expect(r.name, equals('aceite oliva'));
      expect(r.quantity, isNull);
      expect(r.unit, isNull);
    });

    test('decimal quantity with comma', () {
      final r = IngredientAggregator.parseLine('1,5 kg tomate');
      expect(r.quantity, equals(1.5));
      expect(r.unit, equals('kg'));
      expect(r.name, equals('tomate'));
    });
  });

  group('aggregate', () {
    test('sums same ingredient and unit across recipes', () {
      final out = IngredientAggregator.aggregate([
        '200g pechuga pollo',
        '300g pechuga pollo',
      ]);
      expect(out.length, equals(1));
      expect(out.first.quantity, equals(500));
      expect(out.first.unit, equals('g'));
      expect(out.first.label, equals('Pechuga pollo (500 g)'));
    });

    test('keeps different units separate', () {
      final out = IngredientAggregator.aggregate(['200g tomate', '1 tomate']);
      expect(out.length, equals(2));
    });

    test('counts unitless repeats', () {
      final out = IngredientAggregator.aggregate(['sal', 'sal', 'sal']);
      expect(out.length, equals(1));
      expect(out.first.label, equals('Sal (x3)'));
    });

    test('sums bare counts into uds', () {
      final out = IngredientAggregator.aggregate(['1 cebolla', '2 cebolla']);
      expect(out.first.quantity, equals(3));
      expect(out.first.label, equals('Cebolla (3 uds)'));
    });

    test('accent differences still group together', () {
      final out = IngredientAggregator.aggregate(['100g calabacín', '50g calabacin']);
      expect(out.length, equals(1));
      expect(out.first.quantity, equals(150));
    });

    test('ignores blank lines', () {
      final out = IngredientAggregator.aggregate(['', '   ', 'sal']);
      expect(out.length, equals(1));
    });

    test('single unit quantity of 1 omits the count', () {
      final out = IngredientAggregator.aggregate(['1 lechuga']);
      expect(out.first.label, equals('Lechuga'));
    });
  });

  group('categoryFor', () {
    test('classifies common ingredients', () {
      expect(IngredientAggregator.categoryFor('pechuga pollo'), equals('Proteínas'));
      expect(IngredientAggregator.categoryFor('yogur griego 0%'), equals('Lácteos'));
      expect(IngredientAggregator.categoryFor('espinacas'), equals('Verduras'));
      expect(IngredientAggregator.categoryFor('arándanos'), equals('Fruta'));
      expect(IngredientAggregator.categoryFor('aceite oliva'), equals('Despensa'));
      expect(IngredientAggregator.categoryFor('whey protein'), equals('Suplementos'));
    });

    test('falls back to Otros', () {
      expect(IngredientAggregator.categoryFor('algo raro'), equals('Otros'));
    });

    test('is accent insensitive', () {
      expect(IngredientAggregator.categoryFor('atún al natural'), equals('Proteínas'));
    });
  });
}
