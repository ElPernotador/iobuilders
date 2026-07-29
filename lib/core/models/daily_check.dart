class DailyCheck {
  int? id;
  String date; // yyyy-MM-dd
  bool whey;
  bool creatine;
  bool msm;
  bool choline;
  bool fenugreek;
  bool probiotic;
  bool vitaminD;
  bool omega3;
  bool fruit;
  bool water2L;
  bool strength;
  bool bicycle;
  bool mobility;
  bool noBun;
  bool noUltraProcessed;
  bool proteinTarget;
  bool morningMissionDone;
  int? shoulderPain;
  int? kneePain;
  int? abdomenBloating;
  int? bicycleMinutes;
  int? bicycleIntensity;

  DailyCheck({
    this.id,
    required this.date,
    this.whey = false,
    this.creatine = false,
    this.msm = false,
    this.choline = false,
    this.fenugreek = false,
    this.probiotic = false,
    this.vitaminD = false,
    this.omega3 = false,
    this.fruit = false,
    this.water2L = false,
    this.strength = false,
    this.bicycle = false,
    this.mobility = false,
    this.noBun = false,
    this.noUltraProcessed = false,
    this.proteinTarget = false,
    this.morningMissionDone = false,
    this.shoulderPain,
    this.kneePain,
    this.abdomenBloating,
    this.bicycleMinutes,
    this.bicycleIntensity,
  });

  /// Number of training-linked checks done. The supplement / food habits are no
  /// longer hardcoded here — they are editable rows (see [CustomItem]) counted
  /// separately, so this only covers what the Entrenamiento tab writes.
  static const int trainingScoreMax = 4;

  int get trainingScore {
    final checks = [morningMissionDone, strength, bicycle, mobility];
    return checks.where((c) => c).length;
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'date': date,
        'whey': whey ? 1 : 0,
        'creatine': creatine ? 1 : 0,
        'msm': msm ? 1 : 0,
        'choline': choline ? 1 : 0,
        'fenugreek': fenugreek ? 1 : 0,
        'probiotic': probiotic ? 1 : 0,
        'vitaminD': vitaminD ? 1 : 0,
        'omega3': omega3 ? 1 : 0,
        'fruit': fruit ? 1 : 0,
        'water2L': water2L ? 1 : 0,
        'strength': strength ? 1 : 0,
        'bicycle': bicycle ? 1 : 0,
        'mobility': mobility ? 1 : 0,
        'noBun': noBun ? 1 : 0,
        'noUltraProcessed': noUltraProcessed ? 1 : 0,
        'proteinTarget': proteinTarget ? 1 : 0,
        'morningMissionDone': morningMissionDone ? 1 : 0,
        'shoulderPain': shoulderPain,
        'kneePain': kneePain,
        'abdomenBloating': abdomenBloating,
        'bicycleMinutes': bicycleMinutes,
        'bicycleIntensity': bicycleIntensity,
      };

  factory DailyCheck.fromMap(Map<String, dynamic> m) => DailyCheck(
        id: m['id'],
        date: m['date'],
        whey: (m['whey'] ?? 0) == 1,
        creatine: (m['creatine'] ?? 0) == 1,
        msm: (m['msm'] ?? 0) == 1,
        choline: (m['choline'] ?? 0) == 1,
        fenugreek: (m['fenugreek'] ?? 0) == 1,
        probiotic: (m['probiotic'] ?? 0) == 1,
        vitaminD: (m['vitaminD'] ?? 0) == 1,
        omega3: (m['omega3'] ?? 0) == 1,
        fruit: (m['fruit'] ?? 0) == 1,
        water2L: (m['water2L'] ?? 0) == 1,
        strength: (m['strength'] ?? 0) == 1,
        bicycle: (m['bicycle'] ?? 0) == 1,
        mobility: (m['mobility'] ?? 0) == 1,
        noBun: (m['noBun'] ?? 0) == 1,
        noUltraProcessed: (m['noUltraProcessed'] ?? 0) == 1,
        proteinTarget: (m['proteinTarget'] ?? 0) == 1,
        morningMissionDone: (m['morningMissionDone'] ?? 0) == 1,
        shoulderPain: m['shoulderPain'],
        kneePain: m['kneePain'],
        abdomenBloating: m['abdomenBloating'],
        bicycleMinutes: m['bicycleMinutes'],
        bicycleIntensity: m['bicycleIntensity'],
      );

  DailyCheck copyWith({
    bool? whey, bool? creatine, bool? msm, bool? choline, bool? fenugreek,
    bool? probiotic, bool? vitaminD, bool? omega3, bool? fruit, bool? water2L,
    bool? strength, bool? bicycle, bool? mobility, bool? noBun,
    bool? noUltraProcessed, bool? proteinTarget, bool? morningMissionDone,
    int? shoulderPain, int? kneePain, int? abdomenBloating,
    int? bicycleMinutes, int? bicycleIntensity,
  }) => DailyCheck(
    id: id, date: date,
    whey: whey ?? this.whey,
    creatine: creatine ?? this.creatine,
    msm: msm ?? this.msm,
    choline: choline ?? this.choline,
    fenugreek: fenugreek ?? this.fenugreek,
    probiotic: probiotic ?? this.probiotic,
    vitaminD: vitaminD ?? this.vitaminD,
    omega3: omega3 ?? this.omega3,
    fruit: fruit ?? this.fruit,
    water2L: water2L ?? this.water2L,
    strength: strength ?? this.strength,
    bicycle: bicycle ?? this.bicycle,
    mobility: mobility ?? this.mobility,
    noBun: noBun ?? this.noBun,
    noUltraProcessed: noUltraProcessed ?? this.noUltraProcessed,
    proteinTarget: proteinTarget ?? this.proteinTarget,
    morningMissionDone: morningMissionDone ?? this.morningMissionDone,
    shoulderPain: shoulderPain ?? this.shoulderPain,
    kneePain: kneePain ?? this.kneePain,
    abdomenBloating: abdomenBloating ?? this.abdomenBloating,
    bicycleMinutes: bicycleMinutes ?? this.bicycleMinutes,
    bicycleIntensity: bicycleIntensity ?? this.bicycleIntensity,
  );
}
