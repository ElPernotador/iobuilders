import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/models/recipe.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../meals/meals_provider.dart';
import 'shopping_provider.dart';

class ShoppingScreen extends StatefulWidget {
  /// Week to show; defaults to the current one. Comidas passes the week the meal
  /// planner is on so the list always matches the plan you just generated.
  final DateTime? weekOf;
  const ShoppingScreen({super.key, this.weekOf});
  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShoppingProvider>().load(widget.weekOf);
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
                    icon: Icon(_editing ? Icons.check : Icons.edit_outlined,
                        color: _editing ? AppColors.primary : AppColors.textMid),
                    tooltip: _editing ? 'Listo' : 'Editar lista',
                    onPressed: () => setState(() => _editing = !_editing),
                  ),
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
                    tooltip: 'Desmarcar todo',
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
                            editing: _editing,
                            onToggle: provider.toggleItem,
                            onRename: provider.renameItem,
                            onDelete: provider.deleteItem,
                            onAdd: (name) => provider.addItem(name, entry.key),
                          )),
                      if (_editing) ...[
                        Gap.s,
                        _NewCategoryCard(provider: provider),
                      ],
                      Gap.m,
                      Center(
                        child: TextButton.icon(
                          onPressed: () async {
                            final meals = ctx.read<MealsProvider>();
                            final count = await meals.generateShoppingList();
                            await provider.load(widget.weekOf);
                            if (!ctx.mounted) return;
                            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                              content: Text(count == 0
                                  ? 'No hay comidas planificadas esta semana'
                                  : 'Lista regenerada: $count artículos'),
                            ));
                          },
                          icon: const Icon(Icons.sync, size: 16, color: AppColors.blue),
                          label: const Text('Regenerar desde el plan de comidas',
                              style: TextStyle(color: AppColors.blue, fontSize: 13)),
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
  final bool editing;
  final Function(ShoppingItem) onToggle;
  final void Function(ShoppingItem, String) onRename;
  final Function(ShoppingItem) onDelete;
  final ValueChanged<String> onAdd;
  const _CategorySection({
    required this.category,
    required this.items,
    required this.editing,
    required this.onToggle,
    required this.onRename,
    required this.onDelete,
    required this.onAdd,
  });

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
                    editing
                        ? _EditItemRow(
                            key: ValueKey('sh_${items[i].id}'),
                            item: items[i],
                            onRename: (n) => onRename(items[i], n),
                            onDelete: () => onDelete(items[i]),
                          )
                        : _ItemRow(item: items[i], onToggle: () => onToggle(items[i])),
                  ],
                  if (editing) ...[
                    const Divider(height: 1, color: AppColors.hairlineSoft),
                    _ShoppingAddRow(onAdd: onAdd),
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

// ─────────────────────────── Editing the list ─────────────────────────────

/// A shopping item in edit mode: rename inline or delete.
class _EditItemRow extends StatefulWidget {
  final ShoppingItem item;
  final ValueChanged<String> onRename;
  final VoidCallback onDelete;
  const _EditItemRow({
    super.key,
    required this.item,
    required this.onRename,
    required this.onDelete,
  });
  @override
  State<_EditItemRow> createState() => _EditItemRowState();
}

class _EditItemRowState extends State<_EditItemRow> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.item.name);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              style: const TextStyle(color: AppColors.textHi, fontSize: 14.5),
              cursorColor: AppColors.primary,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: widget.onRename,
              onTapOutside: (_) {
                if (_ctrl.text.trim() != widget.item.name) {
                  widget.onRename(_ctrl.text);
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
            tooltip: 'Eliminar',
            visualDensity: VisualDensity.compact,
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }
}

/// Inline add row inside a category.
class _ShoppingAddRow extends StatefulWidget {
  final ValueChanged<String> onAdd;
  const _ShoppingAddRow({required this.onAdd});
  @override
  State<_ShoppingAddRow> createState() => _ShoppingAddRowState();
}

class _ShoppingAddRowState extends State<_ShoppingAddRow> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    widget.onAdd(t);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceAlt,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.add, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _ctrl,
              style: const TextStyle(color: AppColors.textHi, fontSize: 14.5),
              cursorColor: AppColors.primary,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Añadir artículo',
                hintStyle: TextStyle(color: AppColors.textLo),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.primary, size: 20),
            tooltip: 'Añadir',
            visualDensity: VisualDensity.compact,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

/// Creates an item in a brand-new category.
class _NewCategoryCard extends StatefulWidget {
  final ShoppingProvider provider;
  const _NewCategoryCard({required this.provider});
  @override
  State<_NewCategoryCard> createState() => _NewCategoryCardState();
}

class _NewCategoryCardState extends State<_NewCategoryCard> {
  final _name = TextEditingController();
  final _category = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    super.dispose();
  }

  void _submit() {
    final n = _name.text.trim();
    final c = _category.text.trim();
    if (n.isEmpty || c.isEmpty) return;
    widget.provider.addItem(n, c);
    _name.clear();
    _category.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Nueva categoría', padding: EdgeInsets.only(bottom: 8)),
          Row(
            children: [
              Expanded(
                child: _MiniInput(controller: _category, hint: 'Categoría'),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _MiniInput(controller: _name, hint: 'Artículo'),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: _submit,
                style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                icon: const Icon(Icons.add, color: Color(0xFF06251A)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const _MiniInput({required this.controller, required this.hint});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.textHi, fontSize: 14),
      cursorColor: AppColors.primary,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textLo, fontSize: 13),
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
