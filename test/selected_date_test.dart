import 'package:flutter_test/flutter_test.dart';
import 'package:dieter/core/selected_date_controller.dart';

void main() {
  group('SelectedDateController', () {
    test('starts on today', () {
      final c = SelectedDateController();
      expect(c.isToday, isTrue);
    });

    test('setDate strips the time component', () {
      final c = SelectedDateController();
      c.setDate(DateTime(2026, 6, 28, 15, 30));
      expect(c.selected, equals(DateTime(2026, 6, 28)));
    });

    test('shift moves by whole days', () {
      final c = SelectedDateController();
      c.setDate(DateTime(2026, 6, 28));
      c.shift(-1);
      expect(c.selected, equals(DateTime(2026, 6, 27)));
      c.shift(2);
      expect(c.selected, equals(DateTime(2026, 6, 29)));
    });

    test('today() returns to today and isToday is true', () {
      final c = SelectedDateController();
      c.setDate(DateTime(2020, 1, 1));
      expect(c.isToday, isFalse);
      c.today();
      expect(c.isToday, isTrue);
    });

    test('notifies listeners only on actual change', () {
      final c = SelectedDateController();
      c.setDate(DateTime(2026, 6, 28));
      var count = 0;
      c.addListener(() => count++);
      c.setDate(DateTime(2026, 6, 28)); // same → no notify
      expect(count, equals(0));
      c.setDate(DateTime(2026, 6, 29));
      expect(count, equals(1));
    });
  });
}
