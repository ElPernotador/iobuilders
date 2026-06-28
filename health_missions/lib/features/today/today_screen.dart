import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/date_utils.dart';
import '../../core/models/custom_item.dart';
import '../../core/models/daily_check.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import 'today_provider.dart';

/// Builds the editable custom-item rows for a given section.
List<Widget> _customRows(TodayProvider provider, String section) {
  return provider.customItemsFor(section).map((item) {
    return _EditableCustomRow(
      key: ValueKey('custom_${item.id}'),
      item: item,
      checked: provider.isCustomChecked(item.id!),
      onToggle: () => provider.toggleCustomItem(item.id!),
      onRename: (name) => provider.renameCustomItem(item, name),
      onDelete: () => provider.deleteCustomItem(item.id!),
    );
  }).toList();
}

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
                      _PainCard(check: check, onUpdate: provider.updatePain),
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
                        _AddItemRow(hint: 'Añadir suplemento', onAdd: (n) => provider.addCustomItem(n, 'supplement')),
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
                        _AddItemRow(hint: 'Añadir alimento/hábito', onAdd: (n) => provider.addCustomItem(n, 'food')),
                      ]),
                      Gap.xl,
                      const SectionLabel('Entrenamiento'),
                      _CheckGroup(children: [
                        _CheckRow('Misión de la mañana', check.morningMissionDone,
                            () => provider.toggle('morningMission'),
                            icon: Icons.wb_twilight, highlight: true),
                        _CheckRow('Fuerza', check.strength, () => provider.toggle('strength'), icon: Icons.fitness_center),
                        _CheckRow('Movilidad', check.mobility, () => provider.toggle('mobility'), icon: Icons.self_improvement),
                        ..._customRows(provider, 'training'),
                        _AddItemRow(hint: 'Añadir actividad', onAdd: (n) => provider.addCustomItem(n, 'training')),
                      ]),
                      Gap.s,
                      _BicycleCard(check: check, onSave: provider.updateBicycle),
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
  final bool highlight;
  const _CheckRow(this.label, this.value, this.onTap,
      {required this.icon, this.highlight = false});

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
                color: value
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : (highlight ? AppColors.orange.withValues(alpha: 0.12) : AppColors.surfaceAlt),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 18,
                  color: value
                      ? AppColors.primary
                      : (highlight ? AppColors.orange : AppColors.textMid)),
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

// ───────────────────── Editable custom item (inline) ──────────────────────

class _EditableCustomRow extends StatefulWidget {
  final CustomItem item;
  final bool checked;
  final VoidCallback onToggle;
  final ValueChanged<String> onRename;
  final VoidCallback onDelete;
  const _EditableCustomRow({
    super.key,
    required this.item,
    required this.checked,
    required this.onToggle,
    required this.onRename,
    required this.onDelete,
  });
  @override
  State<_EditableCustomRow> createState() => _EditableCustomRowState();
}

class _EditableCustomRowState extends State<_EditableCustomRow> {
  bool _editing = false;
  late final TextEditingController _ctrl = TextEditingController(text: widget.item.name);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _commit() {
    widget.onRename(_ctrl.text);
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.checked;
    if (_editing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        color: AppColors.surfaceAlt,
        child: Row(
          children: [
            const Icon(Icons.edit, size: 18, color: AppColors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                style: const TextStyle(color: AppColors.textHi, fontSize: 15),
                cursorColor: AppColors.primary,
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Nombre',
                  hintStyle: TextStyle(color: AppColors.textLo),
                ),
                onSubmitted: (_) => _commit(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 22),
              tooltip: 'Eliminar',
              onPressed: widget.onDelete,
            ),
            IconButton(
              icon: const Icon(Icons.check, color: AppColors.primary, size: 22),
              tooltip: 'Guardar',
              onPressed: _commit,
            ),
          ],
        ),
      );
    }
    return InkWell(
      onTap: widget.onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        color: v ? AppColors.primary.withValues(alpha: 0.06) : Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: v ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.star_outline,
                  size: 18, color: v ? AppColors.primary : AppColors.textMid),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(widget.item.name,
                  style: TextStyle(
                    color: v ? AppColors.textMid : AppColors.textHi,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    decoration: v ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.textLo,
                  )),
            ),
            GestureDetector(
              onTap: () {
                _ctrl.text = widget.item.name;
                setState(() => _editing = true);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.edit_outlined, size: 18, color: AppColors.textLo),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              v ? Icons.check_circle : Icons.radio_button_unchecked,
              color: v ? AppColors.primary : AppColors.textLo,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────── Inline "add item" row ────────────────────────────

class _AddItemRow extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onAdd;
  const _AddItemRow({required this.hint, required this.onAdd});
  @override
  State<_AddItemRow> createState() => _AddItemRowState();
}

class _AddItemRowState extends State<_AddItemRow> {
  bool _adding = false;
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      setState(() => _adding = false);
      return;
    }
    widget.onAdd(text);
    _ctrl.clear(); // keep open for rapid multiple entries
  }

  @override
  Widget build(BuildContext context) {
    if (!_adding) {
      return InkWell(
        onTap: () => setState(() => _adding = true),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text(widget.hint,
                  style: const TextStyle(color: AppColors.textMid, fontSize: 14.5)),
            ],
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: AppColors.surfaceAlt,
      child: Row(
        children: [
          const Icon(Icons.add, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              style: const TextStyle(color: AppColors.textHi, fontSize: 15),
              cursorColor: AppColors.primary,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: widget.hint,
                hintStyle: const TextStyle(color: AppColors.textLo),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textLo, size: 20),
            tooltip: 'Cerrar',
            onPressed: () => setState(() => _adding = false),
          ),
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.primary, size: 22),
            tooltip: 'Añadir',
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────── Pain card ────────────────────────────────

class _PainCard extends StatefulWidget {
  final DailyCheck check;
  final Function(int, int, int) onUpdate;
  const _PainCard({required this.check, required this.onUpdate});
  @override
  State<_PainCard> createState() => _PainCardState();
}

class _PainCardState extends State<_PainCard> {
  bool _expanded = false;
  late int _shoulder = widget.check.shoulderPain ?? 0;
  late int _knee = widget.check.kneePain ?? 0;
  late int _abdomen = widget.check.abdomenBloating ?? 0;

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
                      ? 'Hombro $_shoulder · Rodilla $_knee · Abdomen $_abdomen'
                      : 'Registro de dolor',
                  style: TextStyle(
                      color: hasPain ? AppColors.danger : AppColors.textHi,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600),
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
                      widget.onUpdate(_shoulder, _knee, _abdomen);
                      setState(() => _expanded = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dolor registrado'), duration: Duration(seconds: 1)),
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
        Container(
          width: 30,
          alignment: Alignment.center,
          child: Text('$value',
              style: TextStyle(
                  color: hot ? AppColors.danger : AppColors.textHi,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

// ─────────────────────────────── Bicycle ──────────────────────────────────

class _BicycleCard extends StatefulWidget {
  final DailyCheck check;
  final Function(int, int) onSave;
  const _BicycleCard({required this.check, required this.onSave});
  @override
  State<_BicycleCard> createState() => _BicycleCardState();
}

class _BicycleCardState extends State<_BicycleCard> {
  bool _expanded = false;
  late int _minutes = widget.check.bicycleMinutes ?? 20;
  late int _intensity = widget.check.bicycleIntensity ?? 2;

  @override
  Widget build(BuildContext context) {
    final done = widget.check.bicycle;
    return AppCard(
      margin: const EdgeInsets.only(top: 8),
      onTap: () => setState(() => _expanded = !_expanded),
      color: done ? AppColors.primary.withValues(alpha: 0.06) : AppColors.surface,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: done ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.directions_bike,
                    size: 18, color: done ? AppColors.primary : AppColors.textMid),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  done ? 'Bicicleta · ${widget.check.bicycleMinutes ?? _minutes} min' : 'Bicicleta',
                  style: TextStyle(
                      color: done ? AppColors.textMid : AppColors.textHi,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
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
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  _LabeledSlider('Minutos', _minutes, 10, 60, 10, '$_minutes min',
                      (v) => setState(() => _minutes = v)),
                  _LabeledSlider('Intensidad', _intensity, 1, 5, 4, '$_intensity/5',
                      (v) => setState(() => _intensity = v)),
                  const SizedBox(height: 8),
                  PrimaryButton(
                    label: 'Registrar bici',
                    icon: Icons.check,
                    height: 46,
                    onPressed: () {
                      widget.onSave(_minutes, _intensity);
                      setState(() => _expanded = false);
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

class _LabeledSlider extends StatelessWidget {
  final String label;
  final int value, min, max, divisions;
  final String display;
  final ValueChanged<int> onChanged;
  const _LabeledSlider(
      this.label, this.value, this.min, this.max, this.divisions, this.display, this.onChanged);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(color: AppColors.textMid, fontSize: 13))),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(), max: max.toDouble(), divisions: divisions,
            label: display,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(width: 52, child: Text(display, textAlign: TextAlign.end, style: const TextStyle(color: AppColors.textHi, fontSize: 12, fontWeight: FontWeight.w600))),
      ],
    );
  }
}
