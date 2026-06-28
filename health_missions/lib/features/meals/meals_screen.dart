import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/recipe.dart';
import 'meals_provider.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});
  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
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
        if (provider.loading) return const Center(child: CircularProgressIndicator());
        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: CustomScrollView(
            slivers: [
              const SliverAppBar(
                backgroundColor: Color(0xFF1E1E1E),
                title: Text('Comidas', style: TextStyle(color: Colors.white)),
                floating: true,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _WeekBadge(week: provider.currentWeekIndex),
                      const SizedBox(height: 16),
                      if (provider.todayLunch != null)
                        _RecipeCard(
                          meal: 'ALMUERZO',
                          recipe: provider.todayLunch!,
                          onSkip: () => _showReplaceSheet(ctx, provider, 'lunch'),
                        ),
                      const SizedBox(height: 12),
                      if (provider.todayDinner != null)
                        _RecipeCard(
                          meal: 'CENA',
                          recipe: provider.todayDinner!,
                          onSkip: () => _showReplaceSheet(ctx, provider, 'dinner'),
                        ),
                      if (provider.todaySnack != null) ...[
                        const SizedBox(height: 12),
                        _SnackCard(snack: provider.todaySnack!),
                      ],
                      const SizedBox(height: 24),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 8),
                      const Text('TODAS LAS RECETAS',
                          style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1.5)),
                      const SizedBox(height: 8),
                      ...provider.getAllRecipes().map((r) => _RecipeListTile(recipe: r)),
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
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Reemplazar receta', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          ListTile(
            leading: const Icon(Icons.skip_next, color: Colors.white54),
            title: const Text('Saltar hoy (sin reemplazo)', style: TextStyle(color: Colors.white70)),
            onTap: () {
              Navigator.pop(ctx);
              provider.skipRecipe(mealType, null);
            },
          ),
          ...provider.getAllRecipes().take(10).map((r) => ListTile(
            title: Text(r.title, style: const TextStyle(color: Colors.white)),
            subtitle: Text('${r.proteinLevel} prot · ${r.carbLevel} carb',
                style: const TextStyle(color: Colors.white38, fontSize: 12)),
            onTap: () {
              Navigator.pop(ctx);
              provider.skipRecipe(mealType, r.id);
            },
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _WeekBadge extends StatelessWidget {
  final int week;
  const _WeekBadge({required this.week});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('Semana $week de 26', style: const TextStyle(color: Colors.blueAccent, fontSize: 13)),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final String meal;
  final Recipe recipe;
  final VoidCallback onSkip;
  const _RecipeCard({required this.meal, required this.recipe, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context, recipe),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(meal, style: const TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5)),
                const Spacer(),
                GestureDetector(
                  onTap: onSkip,
                  child: const Text('Cambiar', style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(recipe.title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              children: [
                _Chip('${recipe.totalMinutes} min', Icons.timer, Colors.white38),
                const SizedBox(width: 8),
                _Chip(recipe.proteinLevel == 'high' ? 'Prot. alta' : 'Prot. media', Icons.fitness_center, Colors.greenAccent),
                const SizedBox(width: 8),
                _Chip(recipe.carbLevel == 'low' ? 'Carb. bajo' : 'Carb. medio', Icons.grain, Colors.orangeAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, Recipe r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        builder: (_, sc) => SingleChildScrollView(
          controller: sc,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('${r.totalMinutes} min · ${r.servings} ración(es)',
                  style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 16),
              const Text('INGREDIENTES', style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5)),
              ...r.ingredients.map((i) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('• $i', style: const TextStyle(color: Colors.white70)),
                  )),
              const SizedBox(height: 16),
              const Text('PREPARACIÓN', style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5)),
              ...r.steps.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('${e.key + 1}. ${e.value}', style: const TextStyle(color: Colors.white70)),
                  )),
              const SizedBox(height: 16),
              if (r.gutNote.isNotEmpty)
                _NoteRow(Icons.spa, 'IBS', r.gutNote, Colors.greenAccent),
              if (r.liverNote.isNotEmpty)
                _NoteRow(Icons.favorite, 'Hígado', r.liverNote, Colors.orangeAccent),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _Chip(this.label, this.icon, this.color);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }
}

class _NoteRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;
  final Color color;
  const _NoteRow(this.icon, this.label, this.text, this.color);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(child: Text('$label: $text', style: TextStyle(color: color, fontSize: 12))),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(Icons.apple, color: Colors.greenAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SNACK', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.5)),
                Text(snack, style: const TextStyle(color: Colors.white, fontSize: 13)),
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
  const _RecipeListTile({required this.recipe});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      title: Text(recipe.title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: Text('${recipe.totalMinutes} min · ${recipe.proteinLevel} prot',
          style: const TextStyle(color: Colors.white38, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: () {
        // reuse detail sheet from RecipeCard
      },
    );
  }
}
