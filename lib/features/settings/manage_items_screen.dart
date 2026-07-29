import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/custom_item.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../today/today_provider.dart';

/// Add / rename / delete the user's custom trackable items (e.g. Minoxidil).
/// On Hoy these appear as plain check rows; all editing happens here.
class ManageItemsScreen extends StatelessWidget {
  const ManageItemsScreen({super.key});

  static const _sections = [
    ('supplement', 'Suplementos', 'Ej: Minoxidil, Magnesio…'),
    ('food', 'Alimentación', 'Ej: Kéfir, Té verde…'),
    ('training', 'Otros hábitos', 'Ej: Estiramiento, Meditar…'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Consumer<TodayProvider>(
        builder: (ctx, provider, _) => CustomScrollView(
          slivers: [
            const GradientAppBar(
              title: 'Mis ítems',
              subtitle: 'Añade lo que quieras seguir cada día',
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (key, title, hint) in _sections) ...[
                      SectionLabel(title),
                      _SectionEditor(
                        sectionKey: key,
                        hint: hint,
                        items: provider.customItemsFor(key),
                        provider: provider,
                      ),
                      Gap.xl,
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionEditor extends StatelessWidget {
  final String sectionKey;
  final String hint;
  final List<CustomItem> items;
  final TodayProvider provider;
  const _SectionEditor({
    required this.sectionKey,
    required this.hint,
    required this.items,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
              _ItemEditRow(
                key: ValueKey('item_${items[i].id}'),
                item: items[i],
                onRename: (name) => provider.renameCustomItem(items[i], name),
                onDelete: () => provider.deleteCustomItem(items[i].id!),
              ),
            ],
            if (items.isNotEmpty) const Divider(height: 1, color: AppColors.hairlineSoft),
            _AddRow(hint: hint, onAdd: (n) => provider.addCustomItem(n, sectionKey)),
          ],
        ),
      ),
    );
  }
}

class _ItemEditRow extends StatefulWidget {
  final CustomItem item;
  final ValueChanged<String> onRename;
  final VoidCallback onDelete;
  const _ItemEditRow({super.key, required this.item, required this.onRename, required this.onDelete});
  @override
  State<_ItemEditRow> createState() => _ItemEditRowState();
}

class _ItemEditRowState extends State<_ItemEditRow> {
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
    if (_editing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                onSubmitted: (_) => _commit(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.check, color: AppColors.primary, size: 22),
              onPressed: _commit,
            ),
          ],
        ),
      );
    }
    return ListTile(
      leading: const Icon(Icons.star_outline, color: AppColors.textMid, size: 20),
      title: Text(widget.item.name, style: const TextStyle(color: AppColors.textHi, fontSize: 15)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textMid, size: 20),
            onPressed: () {
              _ctrl.text = widget.item.name;
              setState(() => _editing = true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }
}

class _AddRow extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onAdd;
  const _AddRow({required this.hint, required this.onAdd});
  @override
  State<_AddRow> createState() => _AddRowState();
}

class _AddRowState extends State<_AddRow> {
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.add, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _ctrl,
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
            icon: const Icon(Icons.check, color: AppColors.primary, size: 22),
            tooltip: 'Añadir',
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
