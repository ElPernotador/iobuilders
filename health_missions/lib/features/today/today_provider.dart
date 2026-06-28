import 'package:flutter/material.dart';
import '../../core/date_utils.dart';
import '../../core/models/daily_check.dart';
import '../../core/storage_service.dart';

class TodayProvider extends ChangeNotifier {
  DailyCheck? _check;
  bool _loading = true;

  DailyCheck? get check => _check;
  bool get loading => _loading;

  Future<void> loadToday() async {
    _loading = true;
    notifyListeners();
    _check = await StorageService.getTodayCheck(AppDateUtils.todayString());
    _loading = false;
    notifyListeners();
  }

  Future<void> toggle(String field) async {
    if (_check == null) return;
    DailyCheck updated;
    switch (field) {
      case 'whey': updated = _check!.copyWith(whey: !_check!.whey); break;
      case 'creatine': updated = _check!.copyWith(creatine: !_check!.creatine); break;
      case 'msm': updated = _check!.copyWith(msm: !_check!.msm); break;
      case 'choline': updated = _check!.copyWith(choline: !_check!.choline); break;
      case 'fenugreek': updated = _check!.copyWith(fenugreek: !_check!.fenugreek); break;
      case 'probiotic': updated = _check!.copyWith(probiotic: !_check!.probiotic); break;
      case 'vitaminD': updated = _check!.copyWith(vitaminD: !_check!.vitaminD); break;
      case 'omega3': updated = _check!.copyWith(omega3: !_check!.omega3); break;
      case 'fruit': updated = _check!.copyWith(fruit: !_check!.fruit); break;
      case 'water2L': updated = _check!.copyWith(water2L: !_check!.water2L); break;
      case 'strength': updated = _check!.copyWith(strength: !_check!.strength); break;
      case 'bicycle': updated = _check!.copyWith(bicycle: !_check!.bicycle); break;
      case 'mobility': updated = _check!.copyWith(mobility: !_check!.mobility); break;
      case 'noBun': updated = _check!.copyWith(noBun: !_check!.noBun); break;
      case 'noUltraProcessed': updated = _check!.copyWith(noUltraProcessed: !_check!.noUltraProcessed); break;
      case 'proteinTarget': updated = _check!.copyWith(proteinTarget: !_check!.proteinTarget); break;
      case 'morningMission': updated = _check!.copyWith(morningMissionDone: !_check!.morningMissionDone); break;
      default: return;
    }
    _check = updated;
    await StorageService.saveDailyCheck(updated);
    notifyListeners();
  }

  Future<void> updatePain(int shoulder, int knee, int abdomen) async {
    if (_check == null) return;
    final updated = _check!.copyWith(
      shoulderPain: shoulder,
      kneePain: knee,
      abdomenBloating: abdomen,
    );
    _check = updated;
    await StorageService.saveDailyCheck(updated);
    notifyListeners();
  }

  Future<void> updateBicycle(int minutes, int intensity) async {
    if (_check == null) return;
    final updated = _check!.copyWith(
      bicycleMinutes: minutes,
      bicycleIntensity: intensity,
      bicycle: true,
    );
    _check = updated;
    await StorageService.saveDailyCheck(updated);
    notifyListeners();
  }

  List<String> get priorityMissions {
    if (_check == null) return [];
    final now = DateTime.now();
    final dayType = AppDateUtils.trainingTypeForDay(now);
    final shoulder = _check!.shoulderPain ?? 0;
    final knee = _check!.kneePain ?? 0;

    final missions = <_MissionPriority>[];

    if (!_check!.morningMissionDone) {
      missions.add(_MissionPriority('Misión mañana: 15 min fuerza', 100));
    }
    if (!_check!.proteinTarget) {
      missions.add(_MissionPriority('Alcanzar objetivo proteína', 90));
    }
    if (dayType.startsWith('strength') && !_check!.strength) {
      missions.add(_MissionPriority('Sesión de fuerza de hoy', 85));
    }
    if (dayType == 'bicycle' && !_check!.bicycle && knee < 6) {
      missions.add(_MissionPriority('Sesión de bicicleta', 80));
    }
    if ((shoulder >= 4 || knee >= 4) && !_check!.mobility) {
      missions.add(_MissionPriority('Movilidad (dolor activo)', 75));
    }
    if (!_check!.water2L) {
      missions.add(_MissionPriority('Beber 2 litros de agua', 60));
    }
    if (!_check!.whey) {
      missions.add(_MissionPriority('Tomar whey', 55));
    }

    missions.sort((a, b) => b.priority.compareTo(a.priority));
    return missions.take(5).map((m) => m.label).toList();
  }
}

class _MissionPriority {
  final String label;
  final int priority;
  _MissionPriority(this.label, this.priority);
}
