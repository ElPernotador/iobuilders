import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/workout.dart';
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
        if (provider.loading) return const Center(child: CircularProgressIndicator());

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0xFF1E1E1E),
                title: const Text('Entrenamiento', style: TextStyle(color: Colors.white)),
                floating: true,
                actions: [
                  if (provider.todayLog?.completed == true)
                    const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(Icons.check_circle, color: Colors.greenAccent),
                    ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildContent(ctx, provider),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext ctx, TrainingProvider provider) {
    if (provider.trainingType == 'rest') {
      return _RestDayCard();
    }
    if (provider.trainingType == 'bicycle') {
      return _BicycleDayCard(provider: provider);
    }

    final workout = provider.todayWorkout;
    if (workout == null) return const Center(child: Text('Sin entrenamiento', style: TextStyle(color: Colors.white)));

    if (provider.todayLog?.completed == true) {
      return _CompletedCard(workoutName: workout.name);
    }
    if (provider.todayLog?.notes == 'Omitido por dolor') {
      return _SkippedCard(onReset: () async { await provider.load(); });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WorkoutHeader(workout: workout),
        const SizedBox(height: 16),
        if (!_sessionStarted)
          _StartButton(onStart: () => setState(() => _sessionStarted = true))
        else ...[
          ...provider.exercises.map((ex) => _ExerciseCard(
                exercise: ex,
                completed: provider.isExerciseCompleted(ex.id),
                onToggle: () => provider.toggleExercise(ex.id),
              )),
          const SizedBox(height: 20),
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
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (_) => StatefulBuilder(
        builder: (_, setState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Sesión completada', style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 16),
              const Text('Esfuerzo percibido:', style: TextStyle(color: Colors.white70)),
              Slider(
                value: effort.toDouble(),
                min: 1, max: 5, divisions: 4,
                label: '$effort/5',
                activeColor: Colors.greenAccent,
                onChanged: (v) => setState(() => effort = v.round()),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  provider.markCompleted(effort: effort);
                },
                icon: const Icon(Icons.check),
                label: const Text('Guardar sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 8),
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
        backgroundColor: const Color(0xFF2A1A1A),
        title: const Text('Dolor elevado', style: TextStyle(color: Colors.redAccent)),
        content: const Text('¿Omitir la sesión de hoy por dolor?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.reportTooMuchPain();
            },
            child: const Text('Sí, omitir', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _WorkoutHeader extends StatelessWidget {
  final Workout workout;
  const _WorkoutHeader({required this.workout});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(workout.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('~${workout.estimatedMinutes} min', style: const TextStyle(color: Colors.blueAccent, fontSize: 14)),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  final VoidCallback onStart;
  const _StartButton({required this.onStart});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onStart,
        icon: const Icon(Icons.play_arrow),
        label: const Text('INICIAR SESIÓN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final bool completed;
  final VoidCallback onToggle;
  const _ExerciseCard({required this.exercise, required this.completed, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: completed ? const Color(0xFF1B3A2D) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: completed ? Colors.greenAccent.withValues(alpha: 0.3) : Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  completed ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: completed ? Colors.greenAccent : Colors.white38,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(exercise.name,
                      style: TextStyle(
                        color: completed ? Colors.greenAccent : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      )),
                ),
                Text('${exercise.sets}×${exercise.reps}',
                    style: const TextStyle(color: Colors.blueAccent, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 6),
            Text(exercise.instructions,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
            if (exercise.safetyNote.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orangeAccent, size: 12),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(exercise.safetyNote,
                        style: const TextStyle(color: Colors.orangeAccent, fontSize: 11)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
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
          child: ElevatedButton.icon(
            onPressed: onDone,
            icon: const Icon(Icons.done_all),
            label: const Text('Completado'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
              minimumSize: const Size(0, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            onPressed: onPain,
            icon: const Icon(Icons.healing, color: Colors.redAccent, size: 18),
            label: const Text('Dolor', style: TextStyle(color: Colors.redAccent)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.redAccent),
              minimumSize: const Size(0, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}

class _RestDayCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.self_improvement, color: Colors.white38, size: 48),
          SizedBox(height: 12),
          Text('Día de recuperación', style: TextStyle(color: Colors.white, fontSize: 18)),
          SizedBox(height: 8),
          Text('Movilidad suave o descanso completo', style: TextStyle(color: Colors.white54, fontSize: 14)),
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
      return _CompletedCard(workoutName: 'Bicicleta');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2A3A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bicicleta', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Cardio suave de bajo impacto', style: TextStyle(color: Colors.blueAccent, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('DURACIÓN', style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5)),
        Slider(
          value: _minutes.toDouble(),
          min: 10, max: 60, divisions: 10,
          label: '$_minutes min',
          activeColor: Colors.blueAccent,
          onChanged: (v) => setState(() => _minutes = v.round()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$_minutes minutos', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        const Text('INTENSIDAD', style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5)),
        Slider(
          value: _effort.toDouble(),
          min: 1, max: 5, divisions: 4,
          label: '$_effort/5',
          activeColor: Colors.greenAccent,
          onChanged: (v) => setState(() => _effort = v.round()),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () => widget.provider.markCompleted(durationMinutes: _minutes, effort: _effort),
            icon: const Icon(Icons.directions_bike),
            label: const Text('Registrar bicicleta', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompletedCard extends StatelessWidget {
  final String workoutName;
  const _CompletedCard({required this.workoutName});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3A2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.greenAccent, size: 48),
          const SizedBox(height: 12),
          Text(workoutName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Sesión completada hoy', style: TextStyle(color: Colors.greenAccent, fontSize: 15)),
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.healing, color: Colors.redAccent, size: 48),
          const SizedBox(height: 12),
          const Text('Sesión omitida por dolor', style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onReset,
            child: const Text('Actualizar', style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }
}
