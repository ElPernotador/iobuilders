class AppSettings {
  bool morningReminderEnabled;
  int morningMinHour;
  int morningMinMinute;
  int morningDelayMinutes;
  int lunchHour;
  int lunchMinute;
  int dinnerHour;
  int dinnerMinute;
  bool saturdayReminderEnabled;
  bool mealRemindersEnabled;
  bool weeklyWeightReminderEnabled;
  Set<int> shoppingDays; // weekdays 1=Mon..7=Sun the user goes shopping
  int shoppingHour;
  int shoppingMinute;
  String units;

  AppSettings({
    this.morningReminderEnabled = true,
    this.morningMinHour = 8,
    this.morningMinMinute = 0,
    this.morningDelayMinutes = 10,
    this.lunchHour = 13,
    this.lunchMinute = 30,
    this.dinnerHour = 21,
    this.dinnerMinute = 0,
    this.saturdayReminderEnabled = true,
    this.mealRemindersEnabled = true,
    this.weeklyWeightReminderEnabled = true,
    Set<int>? shoppingDays,
    this.shoppingHour = 10,
    this.shoppingMinute = 0,
    this.units = 'kg/cm',
  }) : shoppingDays = shoppingDays ?? {DateTime.saturday};

  Map<String, dynamic> toMap() => {
        'morningReminderEnabled': morningReminderEnabled ? 1 : 0,
        'morningMinHour': morningMinHour,
        'morningMinMinute': morningMinMinute,
        'morningDelayMinutes': morningDelayMinutes,
        'lunchHour': lunchHour,
        'lunchMinute': lunchMinute,
        'dinnerHour': dinnerHour,
        'dinnerMinute': dinnerMinute,
        'saturdayReminderEnabled': saturdayReminderEnabled ? 1 : 0,
        'mealRemindersEnabled': mealRemindersEnabled ? 1 : 0,
        'weeklyWeightReminderEnabled': weeklyWeightReminderEnabled ? 1 : 0,
        'shoppingDays': (shoppingDays.toList()..sort()).join(','),
        'shoppingHour': shoppingHour,
        'shoppingMinute': shoppingMinute,
        'units': units,
      };

  factory AppSettings.fromMap(Map<String, dynamic> m) => AppSettings(
        morningReminderEnabled: (m['morningReminderEnabled'] ?? 1) == 1,
        morningMinHour: m['morningMinHour'] ?? 8,
        morningMinMinute: m['morningMinMinute'] ?? 0,
        morningDelayMinutes: m['morningDelayMinutes'] ?? 10,
        lunchHour: m['lunchHour'] ?? 13,
        lunchMinute: m['lunchMinute'] ?? 30,
        dinnerHour: m['dinnerHour'] ?? 21,
        dinnerMinute: m['dinnerMinute'] ?? 0,
        saturdayReminderEnabled: (m['saturdayReminderEnabled'] ?? 1) == 1,
        mealRemindersEnabled: (m['mealRemindersEnabled'] ?? 1) == 1,
        weeklyWeightReminderEnabled: (m['weeklyWeightReminderEnabled'] ?? 1) == 1,
        shoppingDays: _parseDays(m['shoppingDays']),
        shoppingHour: m['shoppingHour'] ?? 10,
        shoppingMinute: m['shoppingMinute'] ?? 0,
        units: m['units'] ?? 'kg/cm',
      );

  /// Accepts a List<int>, an int, or a comma-separated String (storage layer
  /// may stringify a single value).
  static Set<int> _parseDays(dynamic raw) {
    if (raw == null) return {DateTime.saturday};
    if (raw is List) return raw.map((e) => e as int).toSet();
    if (raw is int) return {raw};
    if (raw is String) {
      final parts = raw.split(',').where((s) => s.trim().isNotEmpty);
      final s = parts.map((e) => int.tryParse(e.trim())).whereType<int>().toSet();
      return s.isEmpty ? {DateTime.saturday} : s;
    }
    return {DateTime.saturday};
  }
}
