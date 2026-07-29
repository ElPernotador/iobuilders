import 'package:flutter/foundation.dart';

/// Bottom-navigation tab indices. Single source of truth so screens can
/// deep-link to each other without magic numbers.
class Tabs {
  static const today = 0;
  static const meals = 1;
  static const training = 2;
  static const progress = 3;
  static const settings = 4;
}

/// Holds the selected bottom-nav tab so any screen can switch tabs
/// (e.g. a Hoy summary card jumping to the Entrenamiento tab).
class NavController extends ChangeNotifier {
  int _index = Tabs.today;
  int get index => _index;

  void goTo(int index) {
    if (index == _index) return;
    _index = index;
    notifyListeners();
  }
}
