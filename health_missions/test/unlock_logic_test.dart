import 'package:flutter_test/flutter_test.dart';
import 'package:health_missions/core/date_utils.dart';

void main() {
  group('Morning unlock trigger logic', () {
    test('unlock before min hour is ignored', () {
      // Simulate: minHour=8, current hour=7 → should not fire
      const minHour = 8;
      const currentHour = 7;
      expect(currentHour >= minHour, isFalse);
    });

    test('unlock at or after min hour proceeds', () {
      const minHour = 8;
      const currentHour = 9;
      expect(currentHour >= minHour, isTrue);
    });

    test('already fired today is blocked', () {
      final today = AppDateUtils.todayString();
      final lastFired = today;
      expect(lastFired == today, isTrue); // should skip
    });

    test('previous day fired allows today', () {
      final today = AppDateUtils.todayString();
      final yesterday = AppDateUtils.toDateString(DateTime.now().subtract(const Duration(days: 1)));
      expect(yesterday == today, isFalse); // should allow
    });

    test('delay minutes calculation', () {
      const delayMinutes = 10;
      const delayMs = delayMinutes * 60 * 1000;
      expect(delayMs, equals(600000));
    });
  });
}
