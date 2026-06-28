import 'package:flutter/material.dart';
import '../../core/date_utils.dart';
import '../../core/models/app_settings.dart';
import '../../core/models/recipe.dart';
import '../../core/notification_service.dart';
import '../../core/storage_service.dart';
import '../../data/seed_meal_plan.dart';
import '../../data/seed_shopping.dart';

class ShoppingProvider extends ChangeNotifier {
  List<ShoppingItem> _items = [];
  bool _loading = true;
  String _currentWeekKey = '';
  int _currentWeekIndex = 1;

  List<ShoppingItem> get items => _items;
  bool get loading => _loading;
  String get weekKey => _currentWeekKey;

  Map<String, List<ShoppingItem>> get grouped {
    final map = <String, List<ShoppingItem>>{};
    for (final item in _items) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    final today = DateTime.now();
    _currentWeekKey = AppDateUtils.weekKey(today);
    _currentWeekIndex = AppDateUtils.planWeekIndex(DateTime(2026, 6, 28), today);

    var items = await StorageService.getShoppingItems(_currentWeekKey);
    if (items.isEmpty) {
      final seed = getShoppingListForWeek(_currentWeekIndex, _currentWeekKey);
      await StorageService.bulkInsertShoppingItems(seed);
      items = await StorageService.getShoppingItems(_currentWeekKey);
    }
    _items = items;
    _loading = false;
    notifyListeners();
  }

  Future<void> toggleItem(ShoppingItem item) async {
    final updated = ShoppingItem(
      id: item.id,
      weekKey: item.weekKey,
      name: item.name,
      category: item.category,
      checked: !item.checked,
      isCustom: item.isCustom,
    );
    await StorageService.saveShoppingItem(updated);
    final idx = _items.indexWhere((i) => i.id == item.id);
    if (idx >= 0) _items[idx] = updated;
    notifyListeners();
  }

  Future<void> resetWeek() async {
    await StorageService.deleteShoppingItemsForWeek(_currentWeekKey);
    await load();
  }

  String copyList() {
    final buf = StringBuffer();
    for (final entry in grouped.entries) {
      buf.writeln('${entry.key}:');
      for (final item in entry.value) {
        buf.writeln('  ${item.checked ? "[x]" : "[ ]"} ${item.name}');
      }
      buf.writeln();
    }
    return buf.toString().trim();
  }

  Future<void> scheduleSaturdayReminder(AppSettings settings) async {
    if (!settings.saturdayReminderEnabled) {
      await NotificationService.cancel(NotificationService.idSaturdayMarket);
      return;
    }
    await NotificationService.scheduleSaturdayMarket(const TimeOfDay(hour: 10, minute: 0));
  }
}
