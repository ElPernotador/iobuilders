import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../core/models/app_settings.dart';
import '../../core/notification_service.dart';
import '../../core/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  AppSettings _settings = AppSettings();
  bool _loading = true;
  bool _notificationsGranted = false;

  AppSettings get settings => _settings;
  bool get loading => _loading;
  bool get notificationsGranted => _notificationsGranted;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _settings = await StorageService.getSettings();
    _notificationsGranted = await NotificationService.areNotificationsEnabled();
    _loading = false;
    notifyListeners();
  }

  Future<void> update(AppSettings newSettings) async {
    _settings = newSettings;
    await StorageService.saveSettings(newSettings);
    await _rescheduleNotifications();
    notifyListeners();
  }

  Future<void> requestNotificationPermission() async {
    final granted = await NotificationService.requestPermission();
    _notificationsGranted = granted;
    notifyListeners();
  }

  Future<void> _rescheduleNotifications() async {
    if (!_settings.saturdayReminderEnabled) {
      await NotificationService.cancel(NotificationService.idSaturdayMarket);
    } else {
      await NotificationService.scheduleSaturdayMarket(
          TimeOfDay(hour: 10, minute: 0));
    }
    if (_settings.weeklyWeightReminderEnabled) {
      await NotificationService.scheduleWeeklySundayWeight(
          const TimeOfDay(hour: 9, minute: 0));
    } else {
      await NotificationService.cancel(NotificationService.idWeeklyWeight);
    }
  }

  Future<String> exportData() async {
    return await StorageService.exportData();
  }

  Future<String?> exportToFile() async {
    try {
      final json = await StorageService.exportData();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/health_missions_backup.json');
      await file.writeAsString(json);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  Future<bool> importFromFile(String path) async {
    try {
      final file = File(path);
      final json = await file.readAsString();
      await StorageService.importData(json);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> resetAllData() async {
    await StorageService.resetAllData();
    notifyListeners();
  }
}
