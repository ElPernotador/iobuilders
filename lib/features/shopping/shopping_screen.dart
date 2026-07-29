import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/models/recipe.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import 'shopping_provider.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});
  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShoppingProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingProvider>(
      builder: (ctx, provider, _) {
        if (provider.loading) return const AppLoader();

        final grouped = provider.grouped;
        final checked = provider.items.where((i) => i.checked).length;
        final total = provider.items.length;

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: CustomScrollView(
            slivers: [
              GradientAppBar(
                title: 'Compras',
                subtitle: provider.weekKey,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.copy_outlined, color: AppColors.textMid),
                    tooltip: 'Copiar lista',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: provider.copyList()));
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Lista copiada al portapapeles')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.textMid),
                    tooltip: 'Resetear semana',
                    onPressed: () => _confirmReset(ctx, provider),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProgressCard(checked: checked, total: total),
                      Gap.l,
                      ...grouped.entries.map((entry) => _CategorySection(
                            category: entry.key,
                            items: entry.value,
                            onToggle: provider.toggleItem,
                          )),
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

  void _confirmReset(BuildContext ctx, ShoppingProvider provider) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Resetear semana', style: TextStyle(color: AppColors.textHi)),
        content: const Text('¿Borrar todos los ticks de la semana actual?',
            style: TextStyle(color: AppColors.textMid)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMid)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.resetWeek();
            },
            child: const Text('Resetear', style: TextStyle(color: AppColors.blue)),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int checked;
  final int total;
  const _ProgressCard({required this.checked, required this.total});
  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : checked / total;
    final done = total > 0 && checked == total;
    return AppCard(
      child: Row(
        children: [
          ProgressRing(
            value: pct,
            size: 56,
            stroke: 6,
            center: Text('${(pct * 100).round()}',
                style: const TextStyle(color: AppColors.textHi, fontSize: 15, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(done ? '¡Compra completa! 🎉' : 'Lista de la compra',
                    style: const TextStyle(color: AppColors.textHi, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('$checked de $total artículos',
                    style: const TextStyle(color: AppColors.textMid, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String category;
  final List<ShoppingItem> items;
  final Function(ShoppingItem) onToggle;
  const _CategorySection({required this.category, required this.items, required this.onToggle});

  IconData get _icon {
    final c = category.toLowerCase();
    if (c.contains('prote')) return Icons.set_meal;
    if (c.contains('verdura') || c.contains('verde')) return Icons.eco;
    if (c.contains('fruta')) return Icons.apple;
    if (c.contains('lácteo') || c.contains('lacteo')) return Icons.egg;
    if (c.contains('despensa') || c.contains('seco')) return Icons.kitchen;
    if (c.contains('suplemento')) return Icons.medication;
    return Icons.label_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_icon, size: 15, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(category.toUpperCase(),
                  style: const TextStyle(
                      color: AppColors.textMid, fontSize: 11.5, letterSpacing: 1.4, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.hairline),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: AppColors.hairlineSoft),
                    _ItemRow(item: items[i], onToggle: () => onToggle(items[i])),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final ShoppingItem item;
  final VoidCallback onToggle;
  const _ItemRow({required this.item, required this.onToggle});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        color: item.checked ? AppColors.primary.withValues(alpha: 0.06) : Colors.transparent,
        child: Row(
          children: [
            Icon(
              item.checked ? Icons.check_circle : Icons.radio_button_unchecked,
              color: item.checked ? AppColors.primary : AppColors.textLo,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(item.name,
                  style: TextStyle(
                    color: item.checked ? AppColors.textMid : AppColors.textHi,
                    fontSize: 14.5,
                    decoration: item.checked ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.textLo,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
