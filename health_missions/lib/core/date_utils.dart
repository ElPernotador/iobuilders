class AppDateUtils {
  static String toDateString(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  static String todayString() => toDateString(DateTime.now());

  // Returns week number of year (ISO 8601)
  static int weekNumber(DateTime date) {
    final dayOfYear = int.parse(
        '${date.difference(DateTime(date.year, 1, 1)).inDays + 1}');
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  // Returns how many weeks have passed since startDate
  static int weeksSince(DateTime startDate, DateTime now) {
    final diff = now.difference(startDate).inDays;
    return (diff / 7).floor();
  }

  // Returns plan week index (1-26) given app start date
  static int planWeekIndex(DateTime startDate, DateTime now) {
    final weeks = weeksSince(startDate, now);
    return (weeks % 26) + 1; // 1-indexed, wraps 0-25 → 1-26
  }

  // Returns day of week (1=Mon, 7=Sun)
  static int dayOfWeek(DateTime dt) => dt.weekday;

  static String weekKey(DateTime dt) {
    final w = weekNumber(dt);
    return '${dt.year}-W${w.toString().padLeft(2, '0')}';
  }

  static bool isSunday(DateTime dt) => dt.weekday == DateTime.sunday;
  static bool isSaturday(DateTime dt) => dt.weekday == DateTime.saturday;

  // Training day type based on day of week
  // Mon=A, Wed=B, Fri=C, Tue/Thu/Sat=bicycle, Sun=rest
  static String trainingTypeForDay(DateTime dt) {
    switch (dt.weekday) {
      case DateTime.monday: return 'strength_a';
      case DateTime.tuesday: return 'bicycle';
      case DateTime.wednesday: return 'strength_b';
      case DateTime.thursday: return 'bicycle';
      case DateTime.friday: return 'strength_c';
      case DateTime.saturday: return 'bicycle';
      case DateTime.sunday: return 'rest';
      default: return 'rest';
    }
  }

  static DateTime parseDate(String s) {
    final parts = s.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  static String formatDisplayDate(DateTime dt) {
    const months = [
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${dt.day} ${months[dt.month]}';
  }
}
