import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/daily_check.dart';
import 'models/body_metric.dart';
import 'models/workout.dart';
import 'models/recipe.dart';
import 'models/app_settings.dart';

class StorageService {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'health_missions.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE daily_checks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT UNIQUE NOT NULL,
            whey INTEGER DEFAULT 0,
            creatine INTEGER DEFAULT 0,
            msm INTEGER DEFAULT 0,
            choline INTEGER DEFAULT 0,
            fenugreek INTEGER DEFAULT 0,
            probiotic INTEGER DEFAULT 0,
            vitaminD INTEGER DEFAULT 0,
            omega3 INTEGER DEFAULT 0,
            fruit INTEGER DEFAULT 0,
            water2L INTEGER DEFAULT 0,
            strength INTEGER DEFAULT 0,
            bicycle INTEGER DEFAULT 0,
            mobility INTEGER DEFAULT 0,
            noBun INTEGER DEFAULT 0,
            noUltraProcessed INTEGER DEFAULT 0,
            proteinTarget INTEGER DEFAULT 0,
            morningMissionDone INTEGER DEFAULT 0,
            shoulderPain INTEGER,
            kneePain INTEGER,
            abdomenBloating INTEGER,
            bicycleMinutes INTEGER,
            bicycleIntensity INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE body_metrics (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            weight REAL,
            waist REAL,
            frontPhotoPath TEXT,
            sidePhotoPath TEXT,
            notes TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE workout_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            workoutId TEXT NOT NULL,
            workoutType TEXT NOT NULL,
            completedExerciseIds TEXT DEFAULT '',
            completed INTEGER DEFAULT 0,
            durationMinutes INTEGER,
            perceivedEffort INTEGER,
            notes TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE shopping_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            weekKey TEXT NOT NULL,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            checked INTEGER DEFAULT 0,
            isCustom INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE skipped_recipes (
            date TEXT NOT NULL,
            mealType TEXT NOT NULL,
            replacedWithId TEXT,
            PRIMARY KEY (date, mealType)
          )
        ''');
      },
    );
  }

  // --- DailyCheck ---
  static Future<DailyCheck> getTodayCheck(String date) async {
    final database = await db;
    final rows = await database.query('daily_checks', where: 'date = ?', whereArgs: [date]);
    if (rows.isNotEmpty) return DailyCheck.fromMap(rows.first);
    final check = DailyCheck(date: date);
    final id = await database.insert('daily_checks', check.toMap());
    return check..id = id;
  }

  static Future<void> saveDailyCheck(DailyCheck check) async {
    final database = await db;
    if (check.id != null) {
      await database.update('daily_checks', check.toMap(), where: 'id = ?', whereArgs: [check.id]);
    } else {
      check.id = await database.insert('daily_checks', check.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  static Future<List<DailyCheck>> getChecksRange(String from, String to) async {
    final database = await db;
    final rows = await database.query('daily_checks',
        where: 'date >= ? AND date <= ?', whereArgs: [from, to], orderBy: 'date ASC');
    return rows.map(DailyCheck.fromMap).toList();
  }

  // --- BodyMetric ---
  static Future<List<BodyMetric>> getMetrics() async {
    final database = await db;
    final rows = await database.query('body_metrics', orderBy: 'date ASC');
    return rows.map(BodyMetric.fromMap).toList();
  }

  static Future<void> saveMetric(BodyMetric metric) async {
    final database = await db;
    if (metric.id != null) {
      await database.update('body_metrics', metric.toMap(), where: 'id = ?', whereArgs: [metric.id]);
    } else {
      metric.id = await database.insert('body_metrics', metric.toMap());
    }
  }

  // --- WorkoutLog ---
  static Future<List<WorkoutLog>> getWorkoutLogs(String from, String to) async {
    final database = await db;
    final rows = await database.query('workout_logs',
        where: 'date >= ? AND date <= ?', whereArgs: [from, to], orderBy: 'date ASC');
    return rows.map(WorkoutLog.fromMap).toList();
  }

  static Future<WorkoutLog?> getWorkoutLogForDate(String date) async {
    final database = await db;
    final rows = await database.query('workout_logs', where: 'date = ?', whereArgs: [date]);
    if (rows.isEmpty) return null;
    return WorkoutLog.fromMap(rows.first);
  }

  static Future<void> saveWorkoutLog(WorkoutLog log) async {
    final database = await db;
    if (log.id != null) {
      await database.update('workout_logs', log.toMap(), where: 'id = ?', whereArgs: [log.id]);
    } else {
      log.id = await database.insert('workout_logs', log.toMap());
    }
  }

  // --- ShoppingItem ---
  static Future<List<ShoppingItem>> getShoppingItems(String weekKey) async {
    final database = await db;
    final rows = await database.query('shopping_items',
        where: 'weekKey = ?', whereArgs: [weekKey]);
    return rows.map(ShoppingItem.fromMap).toList();
  }

  static Future<void> saveShoppingItem(ShoppingItem item) async {
    final database = await db;
    if (item.id != null) {
      await database.update('shopping_items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
    } else {
      item.id = await database.insert('shopping_items', item.toMap());
    }
  }

  static Future<void> deleteShoppingItemsForWeek(String weekKey) async {
    final database = await db;
    await database.delete('shopping_items', where: 'weekKey = ? AND isCustom = 0', whereArgs: [weekKey]);
  }

  static Future<void> bulkInsertShoppingItems(List<ShoppingItem> items) async {
    final database = await db;
    final batch = database.batch();
    for (final item in items) {
      batch.insert('shopping_items', item.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  // --- Settings ---
  static Future<AppSettings> getSettings() async {
    final database = await db;
    final rows = await database.query('settings');
    final map = <String, dynamic>{};
    for (final row in rows) {
      final key = row['key'] as String;
      final value = row['value'] as String;
      if (value == 'true' || value == 'false') {
        map[key] = value == 'true' ? 1 : 0;
      } else {
        final num? parsed = num.tryParse(value);
        map[key] = parsed ?? value;
      }
    }
    return AppSettings.fromMap(map);
  }

  static Future<void> saveSettings(AppSettings settings) async {
    final database = await db;
    final map = settings.toMap();
    final batch = database.batch();
    for (final entry in map.entries) {
      batch.insert(
        'settings',
        {'key': entry.key, 'value': entry.value.toString()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // --- Skipped/replaced recipes ---
  static Future<void> skipRecipe(String date, String mealType, String? replacementId) async {
    final database = await db;
    await database.insert(
      'skipped_recipes',
      {'date': date, 'mealType': mealType, 'replacedWithId': replacementId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, String?>> getSkippedRecipes(String date) async {
    final database = await db;
    final rows = await database.query('skipped_recipes', where: 'date = ?', whereArgs: [date]);
    final result = <String, String?>{};
    for (final row in rows) {
      result[row['mealType'] as String] = row['replacedWithId'] as String?;
    }
    return result;
  }

  // --- Export/Import ---
  static Future<String> exportData() async {
    final database = await db;
    final checks = await database.query('daily_checks');
    final metrics = await database.query('body_metrics');
    final workouts = await database.query('workout_logs');
    final shopping = await database.query('shopping_items');
    final settings = await database.query('settings');
    final skipped = await database.query('skipped_recipes');

    return jsonEncode({
      'version': 1,
      'exported': DateTime.now().toIso8601String(),
      'daily_checks': checks,
      'body_metrics': metrics,
      'workout_logs': workouts,
      'shopping_items': shopping,
      'settings': settings,
      'skipped_recipes': skipped,
    });
  }

  static Future<void> importData(String jsonStr) async {
    final database = await db;
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;

    await database.transaction((txn) async {
      for (final table in ['daily_checks', 'body_metrics', 'workout_logs', 'shopping_items', 'settings', 'skipped_recipes']) {
        final rows = data[table] as List<dynamic>?;
        if (rows == null) continue;
        for (final row in rows) {
          await txn.insert(table, Map<String, dynamic>.from(row as Map),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    });
  }

  static Future<void> resetAllData() async {
    final database = await db;
    await database.transaction((txn) async {
      for (final table in ['daily_checks', 'body_metrics', 'workout_logs', 'shopping_items', 'skipped_recipes']) {
        await txn.delete(table);
      }
    });
  }
}
