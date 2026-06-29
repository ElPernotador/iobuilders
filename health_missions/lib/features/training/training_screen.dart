import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/workout.dart';
import '../../core/selected_date_controller.dart';
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
  bool _editing = false;
  SelectedDateController? _dateCtrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  void _reload() {
    if (!mounted) return;
    context.read<TrainingProvider>().load(context.read<SelectedDateController>().selected);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dateCtrl = context.read<SelectedDateController>();
    if (dateCtrl != _dateCtrl) {
      _dateCtrl?.removeListener(_reload);
      _dateCtrl = dateCtrl..addListener(_reload);
    }
  }

  @override
  void dispose() {
    _dateCtrl?.removeListener(_reload);
    super.dispose();
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
                label: 'Reintentar', icon: Icons.refresh, onPressed: _reload),
          );
        }

        final dateCtrl = ctx.watch<SelectedDateController>();
        final canEdit = provider.trainingType.startsWith('strength');
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: CustomScrollView(
            slivers: [
              GradientAppBar(
                title: 'Entrenamiento',
                subtitle: _subtitleFor(provider.trainingType),
                actions: [
                  if (canEdit)
                    IconButton(
                      icon: Icon(_editing ? Icons.check : Icons.edit_outlined,
                          color: _editing ? AppColors.primary : AppColors.textMid),
                      tooltip: _editing ? 'Listo' : 'Editar rutina',
                      onPressed: () => setState(() => _editing = !_editing),
                    ),
                  if (provider.todayLog?.completed == true)
                    const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(Icons.check_circle, color: AppColors.primary),
                    ),
                ],
              ),
              SliverToBoxAdapter(
                child: DateBar(
                  date: dateCtrl.selected,
                  isToday: dateCtrl.isToday,
                  onShift: (d) => dateCtrl.shift(d),
                  onToday: dateCtrl.today,
                  onPick: dateCtrl.setDate,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _QuickLog(provider: provider),
                      Gap.m,
                      _PainEditor(
                        key: ValueKey(
                            '${provider.shoulderPain}-${provider.kneePain}-${provider.abdomenBloating}'),
                        provider: provider,
                      ),
                      Gap.xl,
                      _buildContent(ctx, provider),
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
      return _SkippedCard(onReset: _reload);
    }

    if (_editing) {
      return _EditRoutine(
        workout: workout,
        provider: provider,
        onDone: () => setState(() => _editing = false),
      );
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

// ─────────────────── Quick log: misión mañana + movilidad ─────────────────

class _QuickLog extends StatelessWidget {
  final TrainingProvider provider;
  const _QuickLog({required this.provider});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickToggle(
            label: 'Misión mañana',
            icon: Icons.wb_twilight,
            active: provider.morningMissionDone,
            onTap: provider.toggleMorningMission,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickToggle(
            label: 'Movilidad',
            icon: Icons.self_improvement,
            active: provider.mobilityDone,
            onTap: provider.toggleMobility,
          ),
        ),
      ],
    );
  }
}

class _QuickToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _QuickToggle({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      color: active ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
      border: Border.all(
          color: active ? AppColors.primary.withValues(alpha: 0.4) : AppColors.hairline),
      child: Row(
        children: [
          Icon(active ? Icons.check_circle : icon,
              size: 20, color: active ? AppColors.primary : AppColors.textMid),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    color: active ? AppColors.primary : AppColors.textHi,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── Pain editor ────────────────────────────────

class _PainEditor extends StatefulWidget {
  final TrainingProvider provider;
  const _PainEditor({super.key, required this.provider});
  @override
  State<_PainEditor> createState() => _PainEditorState();
}

class _PainEditorState extends State<_PainEditor> {
  bool _expanded = false;
  late int _shoulder = widget.provider.shoulderPain;
  late int _knee = widget.provider.kneePain;
  late int _abdomen = widget.provider.abdomenBloating;

  @override
  Widget build(BuildContext context) {
    final hasPain = _shoulder > 0 || _knee > 0 || _abdomen > 0;
    return AppCard(
      onTap: () => setState(() => _expanded = !_expanded),
      color: hasPain ? AppColors.dangerDim : AppColors.surface,
      border: Border.all(
          color: hasPain ? AppColors.danger.withValues(alpha: 0.4) : AppColors.hairline),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.monitor_heart,
                  color: hasPain ? AppColors.danger : AppColors.textMid, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasPain
                      ? 'Dolor — hombro $_shoulder · rodilla $_knee · abdomen $_abdomen'
                      : 'Registro de dolor (adapta la rutina)',
                  style: TextStyle(
                      color: hasPain ? AppColors.danger : AppColors.textHi,
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: AppColors.textMid),
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Column(
                children: [
                  _PainSlider('Hombro', _shoulder, (v) => setState(() => _shoulder = v)),
                  _PainSlider('Rodilla', _knee, (v) => setState(() => _knee = v)),
                  _PainSlider('Abdomen', _abdomen, (v) => setState(() => _abdomen = v)),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    label: 'Guardar dolor',
                    icon: Icons.save_outlined,
                    gradient: AppColors.blueGradient,
                    height: 46,
                    onPressed: () {
                      widget.provider.updatePain(_shoulder, _knee, _abdomen);
                      setState(() => _expanded = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Dolor registrado · rutina adaptada'),
                            duration: Duration(seconds: 1)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
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
    final hot = value >= 6;
    return Row(
      children: [
        SizedBox(width: 64, child: Text(label, style: const TextStyle(color: AppColors.textMid, fontSize: 13))),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: hot ? AppColors.danger : AppColors.blue,
              thumbColor: hot ? AppColors.danger : AppColors.blue,
            ),
            child: Slider(
              value: value.toDouble(),
              min: 0, max: 10, divisions: 10,
              label: '$value',
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ),
        SizedBox(
          width: 30,
          child: Text('$value',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: hot ? AppColors.danger : AppColors.textHi,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

// ───────────────────────────── Edit routine ───────────────────────────────

class _EditRoutine extends StatefulWidget {
  final Workout workout;
  final TrainingProvider provider;
  final VoidCallback onDone;
  const _EditRoutine({required this.workout, required this.provider, required this.onDone});
  @override
  State<_EditRoutine> createState() => _EditRoutineState();
}

class _EditRoutineState extends State<_EditRoutine> {
  final _name = TextEditingController();
  final _sets = TextEditingController(text: '3');
  final _reps = TextEditingController(text: '10-12');

  @override
  void dispose() {
    _name.dispose();
    _sets.dispose();
    _reps.dispose();
    super.dispose();
  }

  void _add() {
    final n = _name.text.trim();
    if (n.isEmpty) return;
    widget.provider.addExercise(n, int.tryParse(_sets.text) ?? 3,
        _reps.text.trim().isEmpty ? '10' : _reps.text.trim());
    _name.clear();
    _sets.text = '3';
    _reps.text = '10-12';
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          color: AppColors.blueDim,
          border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
          child: Row(
            children: [
              const Icon(Icons.edit, color: AppColors.blue, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Editando rutina — añade, quita o cambia ejercicios',
                    style: TextStyle(color: AppColors.textHi, fontSize: 13.5, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        Gap.l,
        ...p.exercises.map((e) => AppCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(e.name,
                                  style: const TextStyle(color: AppColors.textHi, fontSize: 14.5, fontWeight: FontWeight.w600)),
                            ),
                            if (p.isCustomExercise(e)) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('Tuyo',
                                    style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('${e.sets}×${e.reps}',
                            style: const TextStyle(color: AppColors.textMid, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                    tooltip: 'Quitar',
                    onPressed: () => widget.provider.removeExercise(e),
                  ),
                ],
              ),
            )),
        Gap.s,
        const SectionLabel('Añadir ejercicio'),
        AppCard(
          child: Column(
            children: [
              TextField(
                controller: _name,
                style: const TextStyle(color: AppColors.textHi),
                cursorColor: AppColors.primary,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Nombre del ejercicio',
                  hintStyle: TextStyle(color: AppColors.textLo),
                ),
              ),
              const Divider(color: AppColors.hairlineSoft),
              Row(
                children: [
                  Expanded(
                    child: _MiniField(label: 'Series', controller: _sets, number: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _MiniField(label: 'Reps', controller: _reps),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filled(
                    onPressed: _add,
                    style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                    icon: const Icon(Icons.add, color: Color(0xFF06251A)),
                  ),
                ],
              ),
            ],
          ),
        ),
        Gap.l,
        PrimaryButton(label: 'Listo', icon: Icons.check, onPressed: widget.onDone),
      ],
    );
  }
}

class _MiniField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool number;
  const _MiniField({required this.label, required this.controller, this.number = false});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMid, fontSize: 11)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: number ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: AppColors.textHi, fontSize: 14),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.surfaceAlt,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
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
