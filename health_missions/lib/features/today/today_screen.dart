import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/date_utils.dart';
import 'today_provider.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});
  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodayProvider>().loadToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodayProvider>(
      builder: (ctx, provider, _) {
        if (provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final check = provider.check;
        if (check == null) return const Center(child: Text('Error cargando datos'));

        final today = DateTime.now();
        final dayName = _dayName(today.weekday);

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0xFF1E1E1E),
                title: Text('$dayName ${AppDateUtils.formatDisplayDate(today)}',
                    style: const TextStyle(color: Colors.white, fontSize: 18)),
                floating: true,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PriorityMissions(missions: provider.priorityMissions),
                      const SizedBox(height: 20),
                      _PainCard(check: check, onUpdate: provider.updatePain),
                      const SizedBox(height: 20),
                      _SectionHeader('Suplementos'),
                      _CheckRow('Whey', check.whey, () => provider.toggle('whey')),
                      _CheckRow('Creatina', check.creatine, () => provider.toggle('creatine')),
                      _CheckRow('MSM', check.msm, () => provider.toggle('msm')),
                      _CheckRow('Colina', check.choline, () => provider.toggle('choline')),
                      _CheckRow('Fenogreco', check.fenugreek, () => provider.toggle('fenugreek')),
                      _CheckRow('Probiótico', check.probiotic, () => provider.toggle('probiotic')),
                      _CheckRow('Vitamina D', check.vitaminD, () => provider.toggle('vitaminD')),
                      _CheckRow('Omega 3', check.omega3, () => provider.toggle('omega3')),
                      const SizedBox(height: 16),
                      _SectionHeader('Alimentación'),
                      _CheckRow('Fruta del día', check.fruit, () => provider.toggle('fruit')),
                      _CheckRow('2 L de agua', check.water2L, () => provider.toggle('water2L')),
                      _CheckRow('Objetivo proteína', check.proteinTarget, () => provider.toggle('proteinTarget')),
                      _CheckRow('Sin bun/pan', check.noBun, () => provider.toggle('noBun')),
                      _CheckRow('Sin ultraprocesados', check.noUltraProcessed, () => provider.toggle('noUltraProcessed')),
                      const SizedBox(height: 16),
                      _SectionHeader('Entrenamiento'),
                      _CheckRow('Misión mañana', check.morningMissionDone,
                          () => provider.toggle('morningMission'),
                          highlight: true),
                      _CheckRow('Fuerza', check.strength, () => provider.toggle('strength')),
                      _CheckRow('Movilidad', check.mobility, () => provider.toggle('mobility')),
                      _BicycleCard(check: check, onSave: provider.updateBicycle),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _dayName(int weekday) {
    const days = ['', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return days[weekday];
  }
}

class _PriorityMissions extends StatelessWidget {
  final List<String> missions;
  const _PriorityMissions({required this.missions});

  @override
  Widget build(BuildContext context) {
    if (missions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B3A2D),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.greenAccent, size: 28),
            SizedBox(width: 12),
            Text('Misiones del día completadas', style: TextStyle(color: Colors.greenAccent, fontSize: 16)),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MISIONES PRIORITARIAS', style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        ...missions.map((m) => Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2A3A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent, size: 14),
              const SizedBox(width: 10),
              Expanded(child: Text(m, style: const TextStyle(color: Colors.white, fontSize: 14))),
            ],
          ),
        )),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title.toUpperCase(),
          style: const TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1.5)),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool value;
  final VoidCallback onTap;
  final bool highlight;
  const _CheckRow(this.label, this.value, this.onTap, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: value
              ? const Color(0xFF1B3A2D)
              : (highlight ? const Color(0xFF2A1E10) : const Color(0xFF1E1E1E)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_box : Icons.check_box_outline_blank,
              color: value ? Colors.greenAccent : Colors.white38,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                  color: value ? Colors.greenAccent : Colors.white,
                  fontSize: 15,
                  decoration: value ? TextDecoration.lineThrough : null,
                  decorationColor: Colors.greenAccent,
                )),
          ],
        ),
      ),
    );
  }
}

class _PainCard extends StatefulWidget {
  final dynamic check;
  final Function(int, int, int) onUpdate;
  const _PainCard({required this.check, required this.onUpdate});
  @override
  State<_PainCard> createState() => _PainCardState();
}

class _PainCardState extends State<_PainCard> {
  bool _expanded = false;
  late int _shoulder;
  late int _knee;
  late int _abdomen;

  @override
  void initState() {
    super.initState();
    _shoulder = widget.check.shoulderPain ?? 0;
    _knee = widget.check.kneePain ?? 0;
    _abdomen = widget.check.abdomenBloating ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final hasPain = _shoulder > 0 || _knee > 0 || _abdomen > 0;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasPain ? const Color(0xFF2A1A1A) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: hasPain ? Border.all(color: Colors.redAccent.withValues(alpha: 0.4)) : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.monitor_heart, color: hasPain ? Colors.redAccent : Colors.white38),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasPain
                        ? 'Dolor: hombro $_shoulder/10  rodilla $_knee/10  abdomen $_abdomen/10'
                        : 'Registro de dolor (toca para editar)',
                    style: TextStyle(
                      color: hasPain ? Colors.redAccent : Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: Colors.white38),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              _PainSlider('Hombro', _shoulder, (v) => setState(() => _shoulder = v)),
              _PainSlider('Rodilla', _knee, (v) => setState(() => _knee = v)),
              _PainSlider('Abdomen', _abdomen, (v) => setState(() => _abdomen = v)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  widget.onUpdate(_shoulder, _knee, _abdomen);
                  setState(() => _expanded = false);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: const Text('Guardar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PainSlider extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  const _PainSlider(this.label, this.value, this.onChanged);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 70, child: Text(label, style: const TextStyle(color: Colors.white70))),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 0, max: 10, divisions: 10,
            label: '$value',
            activeColor: value >= 6 ? Colors.redAccent : Colors.blueAccent,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(width: 24, child: Text('$value', style: const TextStyle(color: Colors.white70))),
      ],
    );
  }
}

class _BicycleCard extends StatefulWidget {
  final dynamic check;
  final Function(int, int) onSave;
  const _BicycleCard({required this.check, required this.onSave});
  @override
  State<_BicycleCard> createState() => _BicycleCardState();
}

class _BicycleCardState extends State<_BicycleCard> {
  bool _expanded = false;
  int _minutes = 20;
  int _intensity = 2;

  @override
  void initState() {
    super.initState();
    _minutes = widget.check.bicycleMinutes ?? 20;
    _intensity = widget.check.bicycleIntensity ?? 2;
  }

  @override
  Widget build(BuildContext context) {
    final done = widget.check.bicycle as bool;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: done ? const Color(0xFF1B3A2D) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  done ? Icons.check_box : Icons.check_box_outline_blank,
                  color: done ? Colors.greenAccent : Colors.white38, size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    done
                        ? 'Bicicleta ${widget.check.bicycleMinutes ?? _minutes} min'
                        : 'Bicicleta',
                    style: TextStyle(
                      color: done ? Colors.greenAccent : Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: Colors.white38),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Minutos: ', style: TextStyle(color: Colors.white70)),
                  Expanded(
                    child: Slider(
                      value: _minutes.toDouble(),
                      min: 10, max: 60, divisions: 10,
                      label: '$_minutes min',
                      activeColor: Colors.greenAccent,
                      onChanged: (v) => setState(() => _minutes = v.round()),
                    ),
                  ),
                  Text('$_minutes', style: const TextStyle(color: Colors.white70)),
                ],
              ),
              Row(
                children: [
                  const Text('Intensidad: ', style: TextStyle(color: Colors.white70)),
                  Expanded(
                    child: Slider(
                      value: _intensity.toDouble(),
                      min: 1, max: 5, divisions: 4,
                      label: '$_intensity/5',
                      activeColor: Colors.greenAccent,
                      onChanged: (v) => setState(() => _intensity = v.round()),
                    ),
                  ),
                  Text('$_intensity/5', style: const TextStyle(color: Colors.white70)),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onSave(_minutes, _intensity);
                  setState(() => _expanded = false);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
                child: const Text('Registrar bici'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
