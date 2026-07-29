import 'package:flutter_test/flutter_test.dart';
import 'package:dieter/core/models/custom_item.dart';
import 'package:dieter/core/models/daily_check.dart';
import 'package:dieter/data/seed_tracked_items.dart';

void main() {
  group('Default tracked items', () {
    test('seed list covers both habit sections', () {
      final items = defaultTrackedItemsAsModels();
      expect(items, isNotEmpty);
      expect(items.where((i) => i.section == 'supplement'), isNotEmpty);
      expect(items.where((i) => i.section == 'food'), isNotEmpty);
    });

    test('every seeded item has a name and an icon key', () {
      for (final item in defaultTrackedItemsAsModels()) {
        expect(item.name.trim(), isNotEmpty);
        expect(item.icon, isNotNull);
      }
    });

    test('sortOrder is a stable ascending sequence', () {
      final items = defaultTrackedItemsAsModels();
      for (var i = 0; i < items.length; i++) {
        expect(items[i].sortOrder, equals(i));
      }
    });

    test('names are unique per section so restore cannot duplicate', () {
      final keys = defaultTrackedItemsAsModels()
          .map((i) => '${i.section}|${i.name.toLowerCase()}')
          .toList();
      expect(keys.toSet().length, equals(keys.length));
    });
  });

  group('CustomItem', () {
    test('round-trips through toMap/fromMap including icon', () {
      final item = CustomItem(
          id: 7, name: 'Minoxidil', section: 'supplement', sortOrder: 3, icon: 'pill');
      final copy = CustomItem.fromMap(item.toMap());
      expect(copy.id, equals(7));
      expect(copy.name, equals('Minoxidil'));
      expect(copy.section, equals('supplement'));
      expect(copy.sortOrder, equals(3));
      expect(copy.icon, equals('pill'));
    });

    test('copyWith overrides only what is given', () {
      final item = CustomItem(name: 'Whey', section: 'supplement', icon: 'drink');
      final renamed = item.copyWith(name: 'Proteína');
      expect(renamed.name, equals('Proteína'));
      expect(renamed.section, equals('supplement'));
      expect(renamed.icon, equals('drink'));
    });
  });

  group('DailyCheck training score', () {
    test('counts only the four training-linked checks', () {
      final check = DailyCheck(date: '2026-07-29');
      expect(check.trainingScore, equals(0));

      final done = check.copyWith(
          morningMissionDone: true, strength: true, bicycle: true, mobility: true);
      expect(done.trainingScore, equals(DailyCheck.trainingScoreMax));
    });

    test('legacy habit booleans no longer affect the score', () {
      final check = DailyCheck(date: '2026-07-29')
          .copyWith(whey: true, creatine: true, fruit: true, water2L: true);
      expect(check.trainingScore, equals(0));
    });
  });
}
