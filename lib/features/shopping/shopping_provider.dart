import 'package:flutter/material.dart';
import '../../core/date_utils.dart';
import '../../core/models/recipe.dart';
import '../../core/storage_service.dart';
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

  /// Loads the list for the week containing [anchor] (defaults to today), so the
  /// screen can follow whichever week the meal planner is showing.
  Future<void> load([DateTime? anchor]) async {
    _loading = true;
    notifyListeners();

    final today = anchor ?? DateTime.now();
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

  /// Categories currently in use, for the add-item picker.
  List<String> get categories => grouped.keys.toList();

  Future<void> addItem(String name, String category) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await StorageService.saveShoppingItem(ShoppingItem(
      weekKey: _currentWeekKey,
      name: trimmed,
      category: category.trim().isEmpty ? 'Otros' : category.trim(),
      isCustom: true,
    ));
    _items = await StorageService.getShoppingItems(_currentWeekKey);
    notifyListeners();
  }

  Future<void> renameItem(ShoppingItem item, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    item.name = trimmed;
    await StorageService.saveShoppingItem(item);
    notifyListeners();
  }

  Future<void> deleteItem(ShoppingItem item) async {
    if (item.id == null) return;
    await StorageService.deleteShoppingItem(item.id!);
    _items = _items.where((i) => i.id != item.id).toList();
    notifyListeners();
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
}
