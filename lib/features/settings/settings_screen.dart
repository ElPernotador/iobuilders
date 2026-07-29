import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/app_settings.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import 'manage_items_screen.dart';
import 'settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (ctx, provider, _) {
        if (provider.loading) return const AppLoader();
        final s = provider.settings;
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: CustomScrollView(
            slivers: [
              const GradientAppBar(title: 'Ajustes'),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Notificaciones'),
                      if (!provider.notificationsGranted)
                        _WarningCard(
                          'Las notificaciones están desactivadas',
                          onTap: () => provider.requestNotificationPermission(),
                        ),
                      _Group(children: [
                        _SwitchTile('Recordatorio mañana', s.morningReminderEnabled,
                            (v) => provider.update(AppSettings.fromMap({...s.toMap(), 'morningReminderEnabled': v ? 1 : 0}))),
                        _TimeTile('Hora mínima mañana', s.morningMinHour, s.morningMinMinute,
                            (h, m) => provider.update(AppSettings.fromMap({...s.toMap(), 'morningMinHour': h, 'morningMinMinute': m}))),
                        _IntTile('Delay tras desbloqueo (min)', s.morningDelayMinutes,
                            (v) => provider.update(AppSettings.fromMap({...s.toMap(), 'morningDelayMinutes': v}))),
                      ]),
                      Gap.m,
                      _Group(children: [
                        _SwitchTile('Recordatorios de comida', s.mealRemindersEnabled,
                            (v) => provider.update(AppSettings.fromMap({...s.toMap(), 'mealRemindersEnabled': v ? 1 : 0}))),
                        _TimeTile('Hora almuerzo objetivo', s.lunchHour, s.lunchMinute,
                            (h, m) => provider.update(AppSettings.fromMap({...s.toMap(), 'lunchHour': h, 'lunchMinute': m}))),
                        _TimeTile('Hora cena objetivo', s.dinnerHour, s.dinnerMinute,
                            (h, m) => provider.update(AppSettings.fromMap({...s.toMap(), 'dinnerHour': h, 'dinnerMinute': m}))),
                      ]),
                      Gap.m,
                      _Group(children: [
                        _SwitchTile('Recordatorio peso dominical', s.weeklyWeightReminderEnabled,
                            (v) => provider.update(AppSettings.fromMap({...s.toMap(), 'weeklyWeightReminderEnabled': v ? 1 : 0}))),
                      ]),
                      Gap.xl,
                      const SectionLabel('Días de compra'),
                      _Group(children: [
                        _SwitchTile('Recordatorio de compras', s.saturdayReminderEnabled,
                            (v) => provider.update(AppSettings.fromMap({...s.toMap(), 'saturdayReminderEnabled': v ? 1 : 0}))),
                        if (s.saturdayReminderEnabled) ...[
                          _WeekdayPicker(
                            selected: s.shoppingDays,
                            onChanged: (days) => provider.update(AppSettings.fromMap(
                                {...s.toMap(), 'shoppingDays': (days.toList()..sort()).join(',')})),
                          ),
                          _TimeTile('Hora del aviso', s.shoppingHour, s.shoppingMinute,
                              (h, m) => provider.update(AppSettings.fromMap(
                                  {...s.toMap(), 'shoppingHour': h, 'shoppingMinute': m}))),
                        ],
                      ]),
                      Gap.xl,
                      const SectionLabel('Personalización'),
                      _Group(children: [
                        _ActionTile(Icons.tune, 'Mis ítems personalizados', AppColors.primary,
                            () => Navigator.of(ctx).push(MaterialPageRoute(
                                builder: (_) => const ManageItemsScreen()))),
                      ]),
                      Gap.xl,
                      const SectionLabel('Datos'),
                      _Group(children: [
                        _ActionTile(Icons.upload_outlined, 'Exportar datos', AppColors.blue,
                            () => _exportData(ctx, provider)),
                        _ActionTile(Icons.delete_forever_outlined, 'Resetear todos los datos', AppColors.danger,
                            () => _confirmReset(ctx, provider)),
                      ]),
                      Gap.xl,
                      const SectionLabel('Acerca de'),
                      const _AboutCard(),
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

  void _exportData(BuildContext ctx, SettingsProvider provider) async {
    final path = await provider.exportToFile();
    if (!mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(path != null ? 'Exportado: $path' : 'Error al exportar')),
    );
  }

  void _confirmReset(BuildContext ctx, SettingsProvider provider) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Resetear datos', style: TextStyle(color: AppColors.danger)),
        content: const Text('¿Borrar TODOS los datos registrados? Esta acción no se puede deshacer.',
            style: TextStyle(color: AppColors.textMid)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textMid))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.resetAllData();
            },
            child: const Text('Borrar todo', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final List<Widget> children;
  const _Group({required this.children});
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

class _WeekdayPicker extends StatelessWidget {
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;
  const _WeekdayPicker({required this.selected, required this.onChanged});

  static const _labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D']; // Mon..Sun

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final wd = i + 1; // 1=Mon..7=Sun
          final on = selected.contains(wd);
          return GestureDetector(
            onTap: () {
              final next = {...selected};
              if (on) {
                next.remove(wd);
              } else {
                next.add(wd);
              }
              onChanged(next);
            },
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? AppColors.primary : AppColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Text(_labels[i],
                  style: TextStyle(
                      color: on ? const Color(0xFF06251A) : AppColors.textMid,
                      fontWeight: FontWeight.w800)),
            ),
          );
        }),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile(this.label, this.value, this.onChanged);
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(color: AppColors.textHi, fontSize: 14.5)),
      value: value,
      activeColor: AppColors.primary,
      onChanged: onChanged,
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final int hour;
  final int minute;
  final Function(int, int) onChanged;
  const _TimeTile(this.label, this.hour, this.minute, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: AppColors.textHi, fontSize: 14.5)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.blue.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text('${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
            style: const TextStyle(color: AppColors.blue, fontSize: 15, fontWeight: FontWeight.w700)),
      ),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: hour, minute: minute),
          builder: (ctx, child) => Theme(data: ThemeData.dark(), child: child!),
        );
        if (picked != null) onChanged(picked.hour, picked.minute);
      },
    );
  }
}

class _IntTile extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  const _IntTile(this.label, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: AppColors.textHi, fontSize: 14.5)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: AppColors.textMid),
            onPressed: () { if (value > 1) onChanged(value - 1); },
          ),
          SizedBox(width: 24, child: Text('$value', textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textHi, fontSize: 16, fontWeight: FontWeight.w700))),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.textMid),
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color, fontSize: 14.5)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textLo),
      onTap: onTap,
    );
  }
}

class _WarningCard extends StatelessWidget {
  final String message;
  final VoidCallback onTap;
  const _WarningCard(this.message, {required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        color: AppColors.orange.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.4)),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.orange, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(color: AppColors.orange, fontSize: 13))),
            const Text('Activar', style: TextStyle(color: AppColors.blue, fontSize: 12.5, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.favorite, color: Color(0xFF06251A), size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Dieter v1.0.6',
                  style: TextStyle(color: AppColors.textHi, fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'App personal offline para reducción de grasa abdominal, '
            'mejora de hígado graso y mantenimiento muscular.',
            style: TextStyle(color: AppColors.textMid, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'AVISO MÉDICO: Esta app no es consejo médico. Para hígado graso, '
              'glucosa, colesterol, dolor o medicación, consulta con tu médico.',
              style: TextStyle(color: AppColors.orange, fontSize: 11.5, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
