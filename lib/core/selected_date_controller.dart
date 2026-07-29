import 'package:flutter/foundation.dart';
import 'date_utils.dart';

/// Holds the date the day-scoped screens (Hoy / Entrenamiento / Progreso)
/// are currently viewing, so the user can backfill or pre-fill any day.
/// Mirrors the [NavController] ChangeNotifier pattern.
class SelectedDateController extends ChangeNotifier {
  DateTime _selected = _dateOnly(DateTime.now());

  /// Date at midnight (no time component).
  DateTime get selected => _selected;
  String get selectedString => AppDateUtils.toDateString(_selected);

  bool get isToday => AppDateUtils.toDateString(_selected) == AppDateUtils.todayString();

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  void setDate(DateTime date) {
    final d = _dateOnly(date);
    if (d == _selected) return;
    _selected = d;
    notifyListeners();
  }

  void today() => setDate(DateTime.now());

  void shift(int days) => setDate(_selected.add(Duration(days: days)));
}
