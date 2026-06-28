import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                      SectionLabel('Todas las recetas · ${all.length}'),
                      Gap.s,
                      _SearchField(onChanged: (v) => setState(() => _query = v)),
                      Gap.m,
                      ...filtered.map((r) => _RecipeListTile(
                            recipe: r,
                            onTap: () => showRecipeDetail(ctx, r),
                          )),
                      if (filtered.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text('Sin resultados',
                                style: TextStyle(color: AppColors.textLo)),
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
}

// ─────────────────────────── Shared detail sheet ──────────────────────────

void showRecipeDetail(BuildContext context, Recipe r) {
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
          Text(r.title,
              style: const TextStyle(
                  color: AppColors.textHi, fontSize: 22, fontWeight: FontWeight.w800)),
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
  const _RecipeListTile({required this.recipe, required this.onTap});
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
                Text(recipe.title,
                    style: const TextStyle(color: AppColors.textHi, fontSize: 14.5, fontWeight: FontWeight.w600)),
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
