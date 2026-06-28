import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'health_missions';
  static const _channelName = 'Misiones de salud';

  static const int idMorningMission = 1;
  static const int idLunchReminder = 2;
  static const int idDinnerReminder = 3;
  static const int idSaturdayMarket = 4;
  static const int idWeeklyWeight = 5;
  static const int idMonthlyMeasure = 6;

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Deep link handled via payload in main.dart
  }

  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  static Future<bool> areNotificationsEnabled() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.areNotificationsEnabled() ?? false;
  }

  static AndroidNotificationDetails get _androidDetails =>
      const AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

  static Future<void> showMorningMission() async {
    await _plugin.show(
      idMorningMission,
      'Misión de la mañana',
      '15 minutos de fuerza',
      NotificationDetails(android: _androidDetails),
      payload: 'screen:today',
    );
  }

  static Future<void> cancelMorningMission() async {
    await _plugin.cancel(idMorningMission);
  }

  static Future<void> scheduleMealReminder({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    final scheduled = tz.TZDateTime.from(when, tz.local);
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      NotificationDetails(android: _androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'screen:meals',
    );
  }

  static Future<void> scheduleSaturdayMarket(TimeOfDay time) async {
    final now = tz.TZDateTime.now(tz.local);
    var next = _nextWeekday(now, DateTime.saturday, time.hour, time.minute);
    await _plugin.zonedSchedule(
      idSaturdayMarket,
      'Feria del sábado',
      'Compra fruta y verduras para 4-5 días',
      next,
      NotificationDetails(android: _androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'screen:shopping',
    );
  }

  static Future<void> scheduleWeeklySundayWeight(TimeOfDay time) async {
    final now = tz.TZDateTime.now(tz.local);
    final next = _nextWeekday(now, DateTime.sunday, time.hour, time.minute);
    await _plugin.zonedSchedule(
      idWeeklyWeight,
      'Registro dominical',
      'Anota tu peso de hoy',
      next,
      NotificationDetails(android: _androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'screen:progress',
    );
  }

  static tz.TZDateTime _nextWeekday(
      tz.TZDateTime from, int weekday, int hour, int minute) {
    var dt = tz.TZDateTime(tz.local, from.year, from.month, from.day, hour, minute);
    while (dt.weekday != weekday || dt.isBefore(from)) {
      dt = dt.add(const Duration(days: 1));
    }
    return dt;
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}
