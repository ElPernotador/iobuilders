import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/mealdb_service.dart';
import '../../core/models/recipe.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import 'meals_provider.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});
  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MealsProvider>(
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

        final all = provider.getAllRecipes();
        final filtered = _query.isEmpty
            ? all
            : all
                .where((r) =>
                    r.title.toLowerCase().contains(_query.toLowerCase()) ||
                    r.tags.any((t) => t.toLowerCase().contains(_query.toLowerCase())))
                .toList();

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: CustomScrollView(
            slivers: [
              GradientAppBar(
                title: 'Comidas',
                subtitle: 'Semana ${provider.currentWeekIndex} de 26',
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Plan de hoy'),
                      if (provider.todayLunch != null)
                        _MealCard(
                          meal: 'Almuerzo',
                          icon: Icons.wb_sunny,
                          accent: AppColors.orange,
                          recipe: provider.todayLunch!,
                          onChange: () => _showReplaceSheet(ctx, provider, 'lunch'),
                        ),
                      if (provider.todayDinner != null) ...[
                        Gap.m,
                        _MealCard(
                          meal: 'Cena',
                          icon: Icons.nightlight_round,
                          accent: AppColors.purple,
                          recipe: provider.todayDinner!,
                          onChange: () => _showReplaceSheet(ctx, provider, 'dinner'),
                        ),
                      ],
                      if (provider.todayLunch == null && provider.todayDinner == null)
                        const AppCard(
                          child: Text('No hay plan para hoy.',
                              style: TextStyle(color: AppColors.textMid)),
                        ),
                      if (provider.todaySnack != null) ...[
                        Gap.m,
                        _SnackCard(snack: provider.todaySnack!),
                      ],
                      Gap.xl,
                      SectionLabel(
                        'Todas las recetas · ${all.length}',
                        trailing: _HeaderAction(
                          icon: Icons.add_circle,
                          label: 'Crear',
                          onTap: () => _showRecipeForm(ctx, provider),
                        ),
                      ),
                      Gap.s,
                      AppCard(
                        onTap: () => _showInternetSearch(ctx, provider),
                        gradient: AppColors.blueGradient,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            const Icon(Icons.travel_explore, color: Colors.white, size: 22),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text('Buscar recetas nuevas en internet',
                                  style: TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w700)),
                            ),
                            const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                      Gap.m,
                      _SearchField(onChanged: (v) => setState(() => _query = v)),
                      Gap.m,
                      ...filtered.map((r) => _RecipeListTile(
                            recipe: r,
                            isCustom: provider.isUserCreated(r),
                            onTap: () => _openRecipe(ctx, provider, r),
                          )),
                      if (filtered.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text('Sin resultados',
                                style: TextStyle(color: AppColors.textLo)),
                          ),
                        ),
                      Gap.m,
                      Center(
                        child: TextButton.icon(
                          onPressed: () async {
                            final added = await provider.restoreDefaultRecipes();
                            if (!ctx.mounted) return;
                            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                              content: Text(added == 0
                                  ? 'Ya tenías todas las recetas por defecto'
                                  : 'Se restauraron $added receta(s)'),
                            ));
                          },
                          icon: const Icon(Icons.restore, size: 16, color: AppColors.textMid),
                          label: const Text('Restaurar recetas por defecto',
                              style: TextStyle(color: AppColors.textMid, fontSize: 13)),
                        ),
                      ),
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

  /// Opens a recipe with edit + delete available (every recipe is editable).
  void _openRecipe(BuildContext ctx, MealsProvider provider, Recipe r) {
    showRecipeDetail(
      ctx,
      r,
      onEdit: () {
        Navigator.pop(ctx);
        _showRecipeForm(ctx, provider, existing: r);
      },
      onDelete: () {
        Navigator.pop(ctx);
        provider.deleteCustomRecipe(r.id);
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('"${r.title}" eliminada')),
        );
      },
    );
  }

  void _showReplaceSheet(BuildContext ctx, MealsProvider provider, String mealType) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        builder: (_, sc) => ListView(
          controller: sc,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const _SheetHandle(),
            const SizedBox(height: 8),
            const Text('Reemplazar receta',
                style: TextStyle(color: AppColors.textHi, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: AppColors.surfaceAlt,
              leading: const Icon(Icons.skip_next, color: AppColors.textMid),
              title: const Text('Saltar hoy (sin reemplazo)',
                  style: TextStyle(color: AppColors.textHi)),
              onTap: () {
                Navigator.pop(ctx);
                provider.skipRecipe(mealType, null);
              },
            ),
            const SizedBox(height: 12),
            const SectionLabel('Elegir otra receta'),
            ...provider.getAllRecipes().map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _RecipeListTile(
                    recipe: r,
                    isCustom: provider.isCustom(r),
                    onTap: () {
                      Navigator.pop(ctx);
                      provider.skipRecipe(mealType, r.id);
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showRecipeForm(BuildContext ctx, MealsProvider provider, {Recipe? existing}) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _RecipeForm(
        existing: existing,
        onSave: (recipe) {
          Navigator.pop(ctx);
          provider.addCustomRecipe(recipe); // insert-or-replace by id
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(existing == null ? 'Receta creada' : 'Receta actualizada')),
          );
        },
        newId: provider.newRecipeId,
      ),
    );
  }

  void _showInternetSearch(BuildContext ctx, MealsProvider provider) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _InternetSearchSheet(
        onSave: (recipe) {
          provider.addCustomRecipe(recipe);
          if (mounted) setState(() => _query = ''); // clear filter so it shows
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text('“${recipe.title}” guardada en tus recetas')),
          );
        },
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _HeaderAction({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(color: AppColors.primary, fontSize: 12.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ──────────────────────────── Recipe create form ──────────────────────────

class _RecipeForm extends StatefulWidget {
  final ValueChanged<Recipe> onSave;
  final String Function(String title) newId;

  /// When set, the form edits this recipe in place instead of creating one.
  final Recipe? existing;
  const _RecipeForm({required this.onSave, required this.newId, this.existing});
  @override
  State<_RecipeForm> createState() => _RecipeFormState();
}

class _RecipeFormState extends State<_RecipeForm> {
  late final Recipe? _e = widget.existing;
  late final _title = TextEditingController(text: _e?.title ?? '');
  late final _ingredients =
      TextEditingController(text: _e?.ingredients.join('\n') ?? '');
  late final _steps = TextEditingController(text: _e?.steps.join('\n') ?? '');
  late final _prep = TextEditingController(text: '${_e?.prepMinutes ?? 10}');
  late final _cook = TextEditingController(text: '${_e?.cookMinutes ?? 15}');
  late final _gut = TextEditingController(text: _e?.gutNote ?? '');
  late final _liver = TextEditingController(text: _e?.liverNote ?? '');
  late String _protein = _e?.proteinLevel ?? 'high';
  late String _carb = _e?.carbLevel ?? 'low';

  @override
  void dispose() {
    _title.dispose();
    _ingredients.dispose();
    _steps.dispose();
    _prep.dispose();
    _cook.dispose();
    _gut.dispose();
    _liver.dispose();
    super.dispose();
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ponle un título a la receta')),
      );
      return;
    }
    final recipe = Recipe(
      id: _e?.id ?? widget.newId(title),
      title: title,
      category: _e?.category ?? 'custom',
      prepMinutes: int.tryParse(_prep.text) ?? 0,
      cookMinutes: int.tryParse(_cook.text) ?? 0,
      servings: _e?.servings ?? 1,
      ingredients: _ingredients.text
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      steps: _steps.text
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      proteinLevel: _protein,
      carbLevel: _carb,
      gutNote: _gut.text.trim(),
      liverNote: _liver.text.trim(),
      oilLimitNote: _e?.oilLimitNote ?? '',
      tags: _e?.tags ?? const ['custom'],
    );
    widget.onSave(recipe);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        builder: (_, sc) => ListView(
          controller: sc,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const _SheetHandle(),
            const SizedBox(height: 12),
            Text(_e == null ? 'Nueva receta' : 'Editar receta',
                style: const TextStyle(
                    color: AppColors.textHi, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _Field('Título', _title, hint: 'Ej: Tortilla de espinacas'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _Field('Prep (min)', _prep, number: true)),
                const SizedBox(width: 12),
                Expanded(child: _Field('Cocción (min)', _cook, number: true)),
              ],
            ),
            const SizedBox(height: 16),
            const SectionLabel('Proteína'),
            _Segmented(
              options: const {'high': 'Alta', 'medium': 'Media', 'low': 'Baja'},
              value: _protein,
              onChanged: (v) => setState(() => _protein = v),
            ),
            const SizedBox(height: 14),
            const SectionLabel('Carbohidratos'),
            _Segmented(
              options: const {'low': 'Bajo', 'medium': 'Medio', 'high': 'Alto'},
              value: _carb,
              onChanged: (v) => setState(() => _carb = v),
            ),
            const SizedBox(height: 16),
            _Field('Ingredientes (uno por línea)', _ingredients, lines: 5,
                hint: '3 huevos\n100 g espinacas\n…'),
            const SizedBox(height: 12),
            _Field('Preparación (un paso por línea)', _steps, lines: 5,
                hint: 'Batir los huevos\nSaltear las espinacas\n…'),
            const SizedBox(height: 12),
            _Field('Nota intestino / IBS (opcional)', _gut),
            const SizedBox(height: 12),
            _Field('Nota hígado (opcional)', _liver),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Guardar receta', icon: Icons.check, onPressed: _save),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int lines;
  final bool number;
  const _Field(this.label, this.controller, {this.hint, this.lines = 1, this.number = false});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMid, fontSize: 12.5)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: lines,
          keyboardType: number
              ? TextInputType.number
              : (lines > 1 ? TextInputType.multiline : TextInputType.text),
          textCapitalization:
              number ? TextCapitalization.none : TextCapitalization.sentences,
          style: const TextStyle(color: AppColors.textHi, fontSize: 14.5),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textLo, fontSize: 13.5),
            filled: true,
            fillColor: AppColors.surfaceAlt,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _Segmented extends StatelessWidget {
  final Map<String, String> options;
  final String value;
  final ValueChanged<String> onChanged;
  const _Segmented({required this.options, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.entries.map((e) {
        final selected = e.key == value;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(e.key),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary.withValues(alpha: 0.18) : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: selected ? AppColors.primary : Colors.transparent),
              ),
              child: Text(e.value,
                  style: TextStyle(
                      color: selected ? AppColors.primary : AppColors.textMid,
                      fontSize: 13.5,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────── Shared detail sheet ──────────────────────────

void showRecipeDetail(BuildContext context, Recipe r,
    {VoidCallback? onDelete, VoidCallback? onSave, VoidCallback? onEdit}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (_, sc) => ListView(
        controller: sc,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          const _SheetHandle(),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(r.title,
                    style: const TextStyle(
                        color: AppColors.textHi, fontSize: 22, fontWeight: FontWeight.w800)),
              ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.blue),
                  tooltip: 'Editar receta',
                  onPressed: onEdit,
                ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                  tooltip: 'Eliminar receta',
                  onPressed: onDelete,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              MetaChip('${r.totalMinutes} min', Icons.timer, AppColors.textMid),
              MetaChip('${r.servings} ración(es)', Icons.people_outline, AppColors.textMid),
              MetaChip(_protLabel(r.proteinLevel), Icons.fitness_center, AppColors.primary),
              MetaChip(_carbLabel(r.carbLevel), Icons.grain, AppColors.orange),
            ],
          ),
          const SizedBox(height: 22),
          const SectionLabel('Ingredientes'),
          ...r.ingredients.map((i) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle, size: 6, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(i,
                            style: const TextStyle(color: AppColors.textHi, fontSize: 14.5, height: 1.4))),
                  ],
                ),
              )),
          const SizedBox(height: 18),
          const SectionLabel('Preparación'),
          ...r.steps.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Text('${e.key + 1}',
                          style: const TextStyle(
                              color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(e.value,
                            style: const TextStyle(color: AppColors.textHi, fontSize: 14.5, height: 1.45))),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          if (r.gutNote.isNotEmpty)
            _NoteCard(Icons.spa, 'Intestino / IBS', r.gutNote, AppColors.primary),
          if (r.liverNote.isNotEmpty)
            _NoteCard(Icons.favorite, 'Hígado', r.liverNote, AppColors.orange),
          if (r.oilLimitNote.isNotEmpty)
            _NoteCard(Icons.opacity, 'Aceite', r.oilLimitNote, AppColors.blue),
          if (onSave != null) ...[
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Guardar en mis recetas',
              icon: Icons.bookmark_add_outlined,
              onPressed: () {
                Navigator.pop(context);
                onSave();
              },
            ),
          ],
        ],
      ),
    ),
  );
}

String _protLabel(String l) => l == 'high'
    ? 'Proteína alta'
    : l == 'medium'
        ? 'Proteína media'
        : 'Proteína baja';
String _carbLabel(String l) => l == 'low'
    ? 'Carbo. bajo'
    : l == 'medium'
        ? 'Carbo. medio'
        : 'Carbo. alto';

// ───────────────────────────────── Widgets ────────────────────────────────

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.textLo,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchField({required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.textHi),
      decoration: InputDecoration(
        hintText: 'Buscar receta o etiqueta…',
        hintStyle: const TextStyle(color: AppColors.textLo),
        prefixIcon: const Icon(Icons.search, color: AppColors.textMid),
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final String meal;
  final IconData icon;
  final Color accent;
  final Recipe recipe;
  final VoidCallback onChange;
  const _MealCard({
    required this.meal,
    required this.icon,
    required this.accent,
    required this.recipe,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => showRecipeDetail(context, recipe),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 6),
              Text(meal.toUpperCase(),
                  style: TextStyle(
                      color: accent, fontSize: 11.5, letterSpacing: 1.4, fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton.icon(
                onPressed: onChange,
                icon: const Icon(Icons.swap_horiz, size: 16, color: AppColors.blue),
                label: const Text('Cambiar', style: TextStyle(color: AppColors.blue, fontSize: 13)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(recipe.title,
              style: const TextStyle(
                  color: AppColors.textHi, fontSize: 17.5, fontWeight: FontWeight.w700, height: 1.2)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              MetaChip('${recipe.totalMinutes} min', Icons.timer, AppColors.textMid),
              MetaChip(_protLabel(recipe.proteinLevel), Icons.fitness_center, AppColors.primary),
              MetaChip(_carbLabel(recipe.carbLevel), Icons.grain, AppColors.orange),
            ],
          ),
        ],
      ),
    );
  }
}

class _SnackCard extends StatelessWidget {
  final String snack;
  const _SnackCard({required this.snack});
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.eco, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SNACK',
                    style: TextStyle(color: AppColors.textMid, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(snack, style: const TextStyle(color: AppColors.textHi, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;
  final Color color;
  const _NoteCard(this.icon, this.label, this.text, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(),
                    style: TextStyle(color: color, fontSize: 10.5, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(text, style: const TextStyle(color: AppColors.textHi, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeListTile extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final bool isCustom;
  const _RecipeListTile({required this.recipe, required this.onTap, this.isCustom = false});
  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(recipe.title,
                          style: const TextStyle(color: AppColors.textHi, fontSize: 14.5, fontWeight: FontWeight.w600)),
                    ),
                    if (isCustom) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Tuya',
                            style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.timer, size: 12, color: AppColors.textLo),
                    const SizedBox(width: 4),
                    Text('${recipe.totalMinutes} min',
                        style: const TextStyle(color: AppColors.textLo, fontSize: 12)),
                    const SizedBox(width: 10),
                    Icon(Icons.fitness_center, size: 12, color: AppColors.primary.withValues(alpha: 0.8)),
                    const SizedBox(width: 4),
                    Text(_protLabel(recipe.proteinLevel),
                        style: const TextStyle(color: AppColors.textLo, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textLo),
        ],
      ),
    );
  }
}

// ─────────────────────── Internet recipe search (TheMealDB) ────────────────

class _InternetSearchSheet extends StatefulWidget {
  final ValueChanged<Recipe> onSave;
  const _InternetSearchSheet({required this.onSave});
  @override
  State<_InternetSearchSheet> createState() => _InternetSearchSheetState();
}

class _InternetSearchSheetState extends State<_InternetSearchSheet> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  bool _opening = false; // looking up a stub's full details
  String? _error;
  List<Recipe> _results = [];
  String _activeCategory = 'Chicken';

  @override
  void initState() {
    super.initState();
    // Never start empty: show a category immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) => _browse(_activeCategory));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _run(Future<List<Recipe>> Function() op) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await op();
      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo conectar. $e';
        _loading = false;
      });
    }
  }

  void _browse(String category) {
    setState(() => _activeCategory = category);
    _ctrl.clear();
    _run(() => MealDbService.browseByCategory(category));
  }

  void _search() {
    final q = _ctrl.text.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _activeCategory = '');
    _run(() => MealDbService.searchByName(q));
  }

  Future<void> _open(Recipe r) async {
    // Stubs (from browse / ingredient filter) need a lookup for full details.
    if (!MealDbService.isStub(r)) {
      showRecipeDetail(context, r, onSave: () => widget.onSave(r));
      return;
    }
    setState(() => _opening = true);
    try {
      final full = await MealDbService.lookupById(r.id);
      if (!mounted) return;
      setState(() => _opening = false);
      if (full != null) {
        showRecipeDetail(context, full, onSave: () => widget.onSave(full));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo cargar la receta')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _opening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        builder: (_, sc) => Column(
          children: [
            const SizedBox(height: 12),
            const _SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recetas de internet',
                      style: TextStyle(color: AppColors.textHi, fontSize: 19, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  const Text('Toca una categoría o busca (ej: pollo, salmón).',
                      style: TextStyle(color: AppColors.textLo, fontSize: 12)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          style: const TextStyle(color: AppColors.textHi),
                          cursorColor: AppColors.primary,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _search(),
                          decoration: InputDecoration(
                            hintText: 'Buscar plato o ingrediente…',
                            hintStyle: const TextStyle(color: AppColors.textLo),
                            prefixIcon: const Icon(Icons.search, color: AppColors.textMid),
                            filled: true,
                            fillColor: AppColors.surfaceAlt,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(height: 52, child: PrimaryButton(label: 'Buscar', onPressed: _search)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: MealDbService.categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final c = MealDbService.categories[i];
                        final on = c == _activeCategory;
                        return GestureDetector(
                          onTap: () => _browse(c),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: on ? AppColors.primary : AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(_catLabel(c),
                                style: TextStyle(
                                    color: on ? const Color(0xFF06251A) : AppColors.textMid,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _body(sc)),
          ],
        ),
      ),
    );
  }

  String _catLabel(String c) {
    const es = {
      'Chicken': 'Pollo', 'Beef': 'Carne', 'Seafood': 'Mariscos',
      'Pasta': 'Pasta', 'Vegetarian': 'Vegetariano', 'Breakfast': 'Desayuno',
      'Dessert': 'Postre',
    };
    return es[c] ?? c;
  }

  Widget _body(ScrollController sc) {
    if (_loading) return const AppLoader();
    if (_error != null) {
      return StateMessage(
        icon: Icons.wifi_off,
        title: 'Sin conexión',
        subtitle: _error,
        action: PrimaryButton(
            label: 'Reintentar',
            icon: Icons.refresh,
            onPressed: () => _activeCategory.isEmpty ? _search() : _browse(_activeCategory)),
      );
    }
    if (_results.isEmpty) {
      return StateMessage(
        icon: Icons.search_off,
        title: 'Sin resultados',
        subtitle: 'Prueba otra palabra o toca una categoría de arriba.',
        action: PrimaryButton(
            label: 'Ver pollo', icon: Icons.restaurant, onPressed: () => _browse('Chicken')),
      );
    }
    return Stack(
      children: [
        ListView.builder(
          controller: sc,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: _results.length,
          itemBuilder: (_, i) {
            final r = _results[i];
            final stub = MealDbService.isStub(r);
            return AppCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              onTap: () => _open(r),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.title,
                            style: const TextStyle(color: AppColors.textHi, fontSize: 14.5, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(stub ? 'Toca para ver la receta' : '${r.category} · ${r.ingredients.length} ingredientes',
                            style: const TextStyle(color: AppColors.textLo, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textLo),
                ],
              ),
            );
          },
        ),
        if (_opening)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: const AppLoader(),
            ),
          ),
      ],
    );
  }
}
