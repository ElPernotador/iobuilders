import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/date_utils.dart';
import '../../core/models/daily_check.dart';
import '../../core/nav_controller.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import 'today_provider.dart';

/// Builds read-only custom-item check rows for a given section.
/// (Add/rename/delete now lives in Settings → "Mis ítems".)
List<Widget> _customRows(TodayProvider provider, String section) {
  return provider.customItemsFor(section).map((item) {
    return _CheckRow(
      item.name,
      provider.isCustomChecked(item.id!),
      () => provider.toggleCustomItem(item.id!),
      icon: Icons.star_outline,
    );
  }).toList();
}

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});
  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  NavController? _nav;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodayProvider>().loadToday();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh the dashboard whenever the Hoy tab regains focus, so summaries
    // reflect edits made in other tabs (e.g. training logged in Entrenamiento).
    final nav = context.read<NavController>();
    if (nav != _nav) {
      _nav?.removeListener(_onNav);
      _nav = nav..addListener(_onNav);
    }
  }

  void _onNav() {
    if (_nav?.index == Tabs.today && mounted) {
      context.read<TodayProvider>().loadToday();
    }
  }

  @override
  void dispose() {
    _nav?.removeListener(_onNav);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodayProvider>(
      builder: (ctx, provider, _) {
        if (provider.loading) return const AppLoader();
        final check = provider.check;
        if (check == null) {
          return StateMessage(
            icon: Icons.cloud_off,
            title: 'No se pudieron cargar los datos',
            subtitle: 'Inténtalo de nuevo.',
            action: PrimaryButton(
              label: 'Reintentar',
              icon: Icons.refresh,
              onPressed: () => provider.loadToday(),
            ),
          );
        }

        final today = DateTime.now();
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _Hero(
                  done: provider.completedCount,
                  total: provider.totalCount,
                  date: today,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PriorityMissions(missions: provider.priorityMissions),
                      Gap.l,
                      _TrainingSummary(check: check),
                      Gap.xl,
                      const SectionLabel('Suplementos'),
                      _CheckGroup(children: [
                        _CheckRow('Whey', check.whey, () => provider.toggle('whey'), icon: Icons.local_drink),
                        _CheckRow('Creatina', check.creatine, () => provider.toggle('creatine'), icon: Icons.bolt),
                        _CheckRow('MSM', check.msm, () => provider.toggle('msm'), icon: Icons.healing),
                        _CheckRow('Colina', check.choline, () => provider.toggle('choline'), icon: Icons.spa),
                        _CheckRow('Fenogreco', check.fenugreek, () => provider.toggle('fenugreek'), icon: Icons.grass),
                        _CheckRow('Probiótico', check.probiotic, () => provider.toggle('probiotic'), icon: Icons.biotech),
                        _CheckRow('Vitamina D', check.vitaminD, () => provider.toggle('vitaminD'), icon: Icons.wb_sunny),
                        _CheckRow('Omega 3', check.omega3, () => provider.toggle('omega3'), icon: Icons.water_drop),
                        ..._customRows(provider, 'supplement'),
                      ]),
                      Gap.xl,
                      const SectionLabel('Alimentación'),
                      _CheckGroup(children: [
                        _CheckRow('Fruta del día', check.fruit, () => provider.toggle('fruit'), icon: Icons.apple),
                        _CheckRow('2 L de agua', check.water2L, () => provider.toggle('water2L'), icon: Icons.local_drink_outlined),
                        _CheckRow('Objetivo proteína', check.proteinTarget, () => provider.toggle('proteinTarget'), icon: Icons.egg_alt),
                        _CheckRow('Sin bun/pan', check.noBun, () => provider.toggle('noBun'), icon: Icons.no_food),
                        _CheckRow('Sin ultraprocesados', check.noUltraProcessed, () => provider.toggle('noUltraProcessed'), icon: Icons.fastfood_outlined),
                        ..._customRows(provider, 'food'),
                      ]),
                      if (provider.customItemsFor('training').isNotEmpty) ...[
                        Gap.xl,
                        const SectionLabel('Otros hábitos'),
                        _CheckGroup(children: _customRows(provider, 'training')),
                      ],
                      Gap.xl,
                      _ManageHint(),
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
}

// ───────────────────────────────── Hero ──────────────────────────────────

class _Hero extends StatelessWidget {
  final int done;
  final int total;
  final DateTime date;
  const _Hero({required this.done, required this.total, required this.date});

  @override
  Widget build(BuildContext context) {
    final score = done;
    final pct = total == 0 ? 0.0 : done / total;
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, top + 20, 20, 24),
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting(),
                    style: const TextStyle(
                        color: AppColors.textHi, fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('${_dayName(date.weekday)}, ${AppDateUtils.formatDisplayDate(date)}',
                    style: const TextStyle(color: AppColors.textMid, fontSize: 14)),
                const SizedBox(height: 14),
                Text(_motivation(pct),
                    style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ProgressRing(
            value: pct,
            size: 92,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$score',
                    style: const TextStyle(
                        color: AppColors.textHi, fontSize: 26, fontWeight: FontWeight.w800, height: 1)),
                Text('de $total',
                    style: const TextStyle(color: AppColors.textMid, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 6) return 'Buenas noches';
    if (h < 13) return 'Buenos días';
    if (h < 20) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String _motivation(double pct) {
    if (pct >= 1) return '¡Día perfecto! 🏆';
    if (pct >= 0.7) return 'Vas estupendamente 💪';
    if (pct >= 0.4) return 'Buen ritmo, sigue así';
    if (pct > 0) return 'Empieza por una misión';
    return 'Hoy es tu día — empieza ya';
  }

  String _dayName(int weekday) {
    const days = ['', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return days[weekday];
  }
}

// ──────────────────────────── Priority missions ───────────────────────────

class _PriorityMissions extends StatelessWidget {
  final List<String> missions;
  const _PriorityMissions({required this.missions});

  @override
  Widget build(BuildContext context) {
    if (missions.isEmpty) {
      return AppCard(
        color: AppColors.primaryDim,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        child: const Row(
          children: [
            Icon(Icons.emoji_events, color: AppColors.primary, size: 30),
            SizedBox(width: 14),
            Expanded(
              child: Text('Misiones del día completadas',
                  style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Misiones prioritarias'),
        ...missions.asMap().entries.map((e) {
          final isTop = e.key == 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              gradient: isTop ? AppColors.blueGradient : null,
              color: isTop ? null : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                  color: isTop ? Colors.transparent : AppColors.hairline),
            ),
            child: Row(
              children: [
                Icon(isTop ? Icons.star_rounded : Icons.chevron_right,
                    color: isTop ? Colors.white : AppColors.blue, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(e.value,
                      style: TextStyle(
                          color: isTop ? Colors.white : AppColors.textHi,
                          fontSize: 14.5,
                          fontWeight: isTop ? FontWeight.w700 : FontWeight.w500)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────── Check rows ───────────────────────────────

class _CheckGroup extends StatelessWidget {
  final List<Widget> children;
  const _CheckGroup({required this.children});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.hairline),
        ),
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: AppColors.hairlineSoft),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool value;
  final VoidCallback onTap;
  final IconData icon;
  const _CheckRow(this.label, this.value, this.onTap, {required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        color: value ? AppColors.primary.withValues(alpha: 0.06) : Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: value ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 18, color: value ? AppColors.primary : AppColors.textMid),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    color: value ? AppColors.textMid : AppColors.textHi,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    decoration: value ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.textLo,
                  )),
            ),
            AnimatedScale(
              scale: value ? 1 : 0.85,
              duration: const Duration(milliseconds: 160),
              child: Icon(
                value ? Icons.check_circle : Icons.radio_button_unchecked,
                color: value ? AppColors.primary : AppColors.textLo,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────── Read-only training summary (→ Entrenamiento) ────────────

class _TrainingSummary extends StatelessWidget {
  final DailyCheck check;
  const _TrainingSummary({required this.check});

  @override
  Widget build(BuildContext context) {
    final type = AppDateUtils.trainingTypeForDay(DateTime.now());
    final isStrength = type.startsWith('strength');
    final isBike = type == 'bicycle';
    final isRest = type == 'rest';

    final String typeLabel;
    final IconData typeIcon;
    if (isStrength) {
      const names = {
        'strength_a': 'Fuerza A',
        'strength_b': 'Fuerza B',
        'strength_c': 'Fuerza C',
      };
      typeLabel = names[type] ?? 'Fuerza';
      typeIcon = Icons.fitness_center;
    } else if (isBike) {
      typeLabel = 'Bicicleta';
      typeIcon = Icons.directions_bike;
    } else {
      typeLabel = 'Descanso';
      typeIcon = Icons.self_improvement;
    }

    final done = isStrength ? check.strength : (isBike ? check.bicycle : false);
    final pain = <String>[];
    if ((check.shoulderPain ?? 0) > 0) pain.add('hombro ${check.shoulderPain}');
    if ((check.kneePain ?? 0) > 0) pain.add('rodilla ${check.kneePain}');
    if ((check.abdomenBloating ?? 0) > 0) pain.add('abdomen ${check.abdomenBloating}');

    return AppCard(
      gradient: AppColors.heroGradient,
      border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
      onTap: () => context.read<NavController>().goTo(Tabs.training),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(typeIcon, color: AppColors.blue, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ENTRENAMIENTO DE HOY',
                        style: TextStyle(color: AppColors.textMid, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(typeLabel,
                        style: const TextStyle(color: AppColors.textHi, fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              if (!isRest)
                Icon(done ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: done ? AppColors.primary : AppColors.textLo, size: 26),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusPill('Misión mañana', check.morningMissionDone),
              _StatusPill('Movilidad', check.mobility),
              if (pain.isNotEmpty)
                MetaChip('Dolor: ${pain.join(' · ')}', Icons.monitor_heart, AppColors.danger),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(isRest ? 'Toca para ver movilidad y registrar' : 'Toca para ver la rutina y registrar',
                  style: const TextStyle(color: AppColors.textMid, fontSize: 12)),
              const Spacer(),
              const Icon(Icons.arrow_forward, color: AppColors.blue, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final bool done;
  const _StatusPill(this.label, this.done);
  @override
  Widget build(BuildContext context) {
    final c = done ? AppColors.primary : AppColors.textLo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(done ? Icons.check_circle : Icons.circle_outlined, size: 13, color: c),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: c, fontSize: 11.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─────────────── Hint linking to custom-item management ───────────────────

class _ManageHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () => context.read<NavController>().goTo(Tabs.settings),
        icon: const Icon(Icons.tune, size: 16, color: AppColors.textMid),
        label: const Text('Personalizar mis ítems',
            style: TextStyle(color: AppColors.textMid, fontSize: 13)),
      ),
    );
  }
}
