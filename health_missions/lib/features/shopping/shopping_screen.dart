import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/models/recipe.dart';
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
        if (provider.loading) return const Center(child: CircularProgressIndicator());

        final grouped = provider.grouped;
        final checked = provider.items.where((i) => i.checked).length;
        final total = provider.items.length;

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0xFF1E1E1E),
                title: Text('Compras (${provider.weekKey})',
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                floating: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.white54),
                    tooltip: 'Copiar lista',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: provider.copyList()));
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Lista copiada')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white54),
                    tooltip: 'Resetear semana',
                    onPressed: () => _confirmReset(ctx, provider),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProgressBar(checked: checked, total: total),
                      const SizedBox(height: 16),
                      ...grouped.entries.map((entry) => _CategorySection(
                            category: entry.key,
                            items: entry.value,
                            onToggle: provider.toggleItem,
                          )),
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

  void _confirmReset(BuildContext ctx, ShoppingProvider provider) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Resetear semana', style: TextStyle(color: Colors.white)),
        content: const Text('¿Borrar todos los ticks de la semana actual?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.resetWeek();
            },
            child: const Text('Resetear', style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int checked;
  final int total;
  const _ProgressBar({required this.checked, required this.total});
  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : checked / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$checked de $total artículos', style: const TextStyle(color: Colors.white70, fontSize: 13)),
            Text('${(pct * 100).round()}%', style: const TextStyle(color: Colors.blueAccent, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: pct,
          backgroundColor: Colors.white12,
          valueColor: const AlwaysStoppedAnimation(Colors.blueAccent),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String category;
  final List<ShoppingItem> items;
  final Function(ShoppingItem) onToggle;
  const _CategorySection({required this.category, required this.items, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(category.toUpperCase(),
              style: const TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5)),
        ),
        ...items.map((item) => InkWell(
              onTap: () => onToggle(item),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: item.checked ? const Color(0xFF1A2A1A) : const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.checked ? Icons.check_box : Icons.check_box_outline_blank,
                      color: item.checked ? Colors.greenAccent : Colors.white38,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(item.name,
                          style: TextStyle(
                            color: item.checked ? Colors.white38 : Colors.white,
                            fontSize: 14,
                            decoration: item.checked ? TextDecoration.lineThrough : null,
                            decorationColor: Colors.white38,
                          )),
                    ),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 8),
      ],
    );
  }
}
