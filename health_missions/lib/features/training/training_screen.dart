import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/workout.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import 'training_provider.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});
  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  bool _sessionStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrainingProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrainingProvider>(
      builder: (ctx, provider, _) {
        if (provider.loading) return const AppLoader();
        if (provider.error != null) {
          return StateMessage(
            icon: Icons.cloud_off,
            title: provider.error!,
            action: PrimaryButton(
                label: 'Reintentar', icon: Icons.refresh, onPressed: () => provider.load()),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: CustomScrollView(
            slivers: [
              GradientAppBar(
                title: 'Entrenamiento',
                subtitle: _subtitleFor(provider.trainingType),
                actions: [
                  if (provider.todayLog?.completed == true)
                    const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(Icons.check_circle, color: AppColors.primary),
                    ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: _buildContent(ctx, provider),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _subtitleFor(String type) {
    switch (type) {
      case 'strength_a':
      case 'strength_b':
      case 'strength_c':
        return 'Día de fuerza';
      case 'bicycle':
        return 'Día de cardio';
      default:
        return 'Día de descanso';
    }
  }

  Widget _buildContent(BuildContext ctx, TrainingProvider provider) {
    if (provider.trainingType == 'rest') return const _RestDayCard();
    if (provider.trainingType == 'bicycle') return _BicycleDayCard(provider: provider);

    final workout = provider.todayWorkout;
    if (workout == null) {
      return const StateMessage(icon: Icons.event_busy, title: 'Sin entrenamiento hoy');
    }
    if (provider.todayLog?.completed == true) {
      return _CompletedCard(
        workoutName: workout.name,
        count: provider.todayLog?.completedExerciseIds.length ?? 0,
      );
    }
    if (provider.todayLog?.notes == 'Omitido por dolor') {
      return _SkippedCard(onReset: () => provider.load());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WorkoutHeader(workout: workout, exerciseCount: provider.exercises.length),
        if (provider.hiddenByPain > 0) ...[
          Gap.m,
          _PainNotice(count: provider.hiddenByPain),
        ],
        Gap.l,
        if (!_sessionStarted)
          PrimaryButton(
            label: 'INICIAR SESIÓN',
            icon: Icons.play_arrow_rounded,
            height: 56,
            onPressed: () => setState(() => _sessionStarted = true),
          )
        else ...[
          ...provider.exercises.asMap().entries.map((e) => _ExerciseCard(
                index: e.key + 1,
                exercise: e.value,
                completed: provider.isExerciseCompleted(e.value.id),
                onToggle: () => provider.toggleExercise(e.value.id),
              )),
          Gap.l,
          _ActionButtons(
            onDone: () => _showDoneSheet(ctx, provider),
            onPain: () => _confirmPain(ctx, provider),
          ),
        ],
      ],
    );
  }

  void _showDoneSheet(BuildContext ctx, TrainingProvider provider) {
    int effort = 3;
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (_, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: AppColors.primary, size: 40),
              const SizedBox(height: 12),
              const Text('Sesión completada',
                  style: TextStyle(color: AppColors.textHi, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Esfuerzo percibido',
                    style: TextStyle(color: AppColors.textMid, fontSize: 13)),
              ),
              Slider(
                value: effort.toDouble(),
                min: 1, max: 5, divisions: 4,
                label: '$effort/5',
                onChanged: (v) => setSheet(() => effort = v.round()),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'Guardar sesión',
                icon: Icons.check,
                onPressed: () {
                  Navigator.pop(ctx);
                  provider.markCompleted(effort: effort);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmPain(BuildContext ctx, TrainingProvider provider) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Dolor elevado', style: TextStyle(color: AppColors.danger)),
        content: const Text('¿Omitir la sesión de hoy por dolor?',
            style: TextStyle(color: AppColors.textMid)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textMid))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.reportTooMuchPain();
            },
            child: const Text('Sí, omitir', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _WorkoutHeader extends StatelessWidget {
  final Workout workout;
  final int exerciseCount;
  const _WorkoutHeader({required this.workout, required this.exerciseCount});
  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: AppColors.heroGradient,
      border: Border.all(color: AppColors.blue.withValues(alpha: 0.25)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(workout.name,
              style: const TextStyle(color: AppColors.textHi, fontSize: 19, fontWeight: FontWeight.w800, height: 1.2)),
          const SizedBox(height: 12),
          Row(
            children: [
              MetaChip('~${workout.estimatedMinutes} min', Icons.schedule, AppColors.blue),
              const SizedBox(width: 8),
              MetaChip('$exerciseCount ejercicios', Icons.list_alt, AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }
}

class _PainNotice extends StatelessWidget {
  final int count;
  const _PainNotice({required this.count});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.orange, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Se ocultaron $count ejercicio(s) por tu dolor de hoy. Rutina adaptada.',
              style: const TextStyle(color: AppColors.orange, fontSize: 12.5, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatefulWidget {
  final int index;
  final Exercise exercise;
  final bool completed;
  final VoidCallback onToggle;
  const _ExerciseCard({
    required this.index,
    required this.exercise,
    required this.completed,
    required this.onToggle,
  });
  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  bool _showVariants = false;

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final done = widget.completed;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      color: done ? AppColors.primary.withValues(alpha: 0.07) : AppColors.surface,
      border: Border.all(
          color: done ? AppColors.primary.withValues(alpha: 0.3) : AppColors.hairline),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: widget.onToggle,
                child: AnimatedScale(
                  scale: done ? 1 : 0.9,
                  duration: const Duration(milliseconds: 160),
                  child: Icon(
                    done ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: done ? AppColors.primary : AppColors.textLo,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: widget.onToggle,
                  child: Text(ex.name,
                      style: TextStyle(
                        color: done ? AppColors.textMid : AppColors.textHi,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        decoration: done ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.textLo,
                      )),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${ex.sets}×${ex.reps}',
                    style: const TextStyle(color: AppColors.blue, fontSize: 12.5, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(ex.instructions,
              style: const TextStyle(color: AppColors.textMid, fontSize: 13, height: 1.4)),
          if (ex.safetyNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.orange, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(ex.safetyNote,
                      style: const TextStyle(color: AppColors.orange, fontSize: 11.5, height: 1.3)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 13, color: AppColors.textLo),
              const SizedBox(width: 4),
              Text('${ex.restSeconds}s descanso',
                  style: const TextStyle(color: AppColors.textLo, fontSize: 12)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showVariants = !_showVariants),
                child: Row(
                  children: [
                    Text(_showVariants ? 'Ocultar' : 'Variantes',
                        style: const TextStyle(color: AppColors.blue, fontSize: 12.5, fontWeight: FontWeight.w600)),
                    Icon(_showVariants ? Icons.expand_less : Icons.expand_more,
                        size: 16, color: AppColors.blue),
                  ],
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _showVariants ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  _VariantRow(Icons.trending_down, 'Más fácil', ex.easierVariant, AppColors.primary),
                  const SizedBox(height: 6),
                  _VariantRow(Icons.trending_up, 'Más difícil', ex.harderVariant, AppColors.orange),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VariantRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;
  final Color color;
  const _VariantRow(this.icon, this.label, this.text, this.color);
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w600)),
        Expanded(child: Text(text, style: const TextStyle(color: AppColors.textMid, fontSize: 12.5))),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onDone;
  final VoidCallback onPain;
  const _ActionButtons({required this.onDone, required this.onPain});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PrimaryButton(label: 'Completado', icon: Icons.done_all, height: 52, onPressed: onDone),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: onPain,
              icon: const Icon(Icons.healing, color: AppColors.danger, size: 18),
              label: const Text('Dolor', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.danger),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RestDayCard extends StatelessWidget {
  const _RestDayCard();
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.self_improvement, color: AppColors.blue, size: 38),
          ),
          const SizedBox(height: 16),
          const Text('Día de recuperación',
              style: TextStyle(color: AppColors.textHi, fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Movilidad suave, estiramientos o descanso completo.\nTu cuerpo crece cuando descansa.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMid, fontSize: 13.5, height: 1.5)),
        ],
      ),
    );
  }
}

class _BicycleDayCard extends StatefulWidget {
  final TrainingProvider provider;
  const _BicycleDayCard({required this.provider});
  @override
  State<_BicycleDayCard> createState() => _BicycleDayCardState();
}

class _BicycleDayCardState extends State<_BicycleDayCard> {
  int _minutes = 20;
  int _effort = 2;

  @override
  Widget build(BuildContext context) {
    if (widget.provider.todayLog?.completed == true) {
      return const _CompletedCard(workoutName: 'Bicicleta', count: 0);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          gradient: AppColors.heroGradient,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.directions_bike, color: AppColors.blue, size: 26),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bicicleta',
                        style: TextStyle(color: AppColors.textHi, fontSize: 19, fontWeight: FontWeight.w800)),
                    SizedBox(height: 2),
                    Text('Cardio suave de bajo impacto',
                        style: TextStyle(color: AppColors.textMid, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Gap.xl,
        AppCard(
          child: Column(
            children: [
              _BigSlider('DURACIÓN', '$_minutes', 'min', _minutes.toDouble(), 10, 60, 10,
                  (v) => setState(() => _minutes = v.round())),
              const SizedBox(height: 16),
              _BigSlider('INTENSIDAD', '$_effort', '/5', _effort.toDouble(), 1, 5, 4,
                  (v) => setState(() => _effort = v.round())),
            ],
          ),
        ),
        Gap.l,
        PrimaryButton(
          label: 'Registrar bicicleta',
          icon: Icons.check,
          height: 56,
          onPressed: () => widget.provider.markCompleted(durationMinutes: _minutes, effort: _effort),
        ),
      ],
    );
  }
}

class _BigSlider extends StatelessWidget {
  final String label, value, unit;
  final double current;
  final int min, max, divisions;
  final ValueChanged<double> onChanged;
  const _BigSlider(this.label, this.value, this.unit, this.current, this.min, this.max,
      this.divisions, this.onChanged);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: AppColors.textMid, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
            RichText(
              text: TextSpan(children: [
                TextSpan(text: value, style: const TextStyle(color: AppColors.textHi, fontSize: 22, fontWeight: FontWeight.w800)),
                TextSpan(text: ' $unit', style: const TextStyle(color: AppColors.textMid, fontSize: 13)),
              ]),
            ),
          ],
        ),
        Slider(
          value: current,
          min: min.toDouble(), max: max.toDouble(), divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _CompletedCard extends StatelessWidget {
  final String workoutName;
  final int count;
  const _CompletedCard({required this.workoutName, required this.count});
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(28),
      color: AppColors.primaryDim,
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: 16),
          Text(workoutName,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textHi, fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(count > 0 ? '$count ejercicios · sesión completada hoy' : 'Sesión completada hoy',
              style: const TextStyle(color: AppColors.primary, fontSize: 14)),
        ],
      ),
    );
  }
}

class _SkippedCard extends StatelessWidget {
  final VoidCallback onReset;
  const _SkippedCard({required this.onReset});
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(28),
      color: AppColors.dangerDim,
      child: Column(
        children: [
          const Icon(Icons.healing, color: AppColors.danger, size: 44),
          const SizedBox(height: 14),
          const Text('Sesión omitida por dolor',
              style: TextStyle(color: AppColors.textHi, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onReset,
            child: const Text('Actualizar', style: TextStyle(color: AppColors.blue)),
          ),
        ],
      ),
    );
  }
}
