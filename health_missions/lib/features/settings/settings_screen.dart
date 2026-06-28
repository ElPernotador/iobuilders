import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/app_settings.dart';
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
        if (provider.loading) return const Center(child: CircularProgressIndicator());
        final s = provider.settings;
        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: CustomScrollView(
            slivers: [
              const SliverAppBar(
                backgroundColor: Color(0xFF1E1E1E),
                title: Text('Ajustes', style: TextStyle(color: Colors.white)),
                floating: true,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('NOTIFICACIONES'),
                      if (!provider.notificationsGranted)
                        _WarningCard(
                          'Las notificaciones están desactivadas',
                          onTap: () => provider.requestNotificationPermission(),
                        ),
                      _SwitchTile(
                        'Recordatorio mañana',
                        s.morningReminderEnabled,
                        (v) => provider.update(AppSettings.fromMap({...s.toMap(), 'morningReminderEnabled': v ? 1 : 0})),
                      ),
                      _TimeTile('Hora mínima mañana', s.morningMinHour, s.morningMinMinute,
                          (h, m) => provider.update(AppSettings.fromMap({...s.toMap(), 'morningMinHour': h, 'morningMinMinute': m}))),
                      _IntTile('Delay tras desbloqueo (min)', s.morningDelayMinutes, (v) =>
                          provider.update(AppSettings.fromMap({...s.toMap(), 'morningDelayMinutes': v}))),
                      _SwitchTile(
                        'Recordatorios de comida',
                        s.mealRemindersEnabled,
                        (v) => provider.update(AppSettings.fromMap({...s.toMap(), 'mealRemindersEnabled': v ? 1 : 0})),
                      ),
                      _TimeTile('Hora almuerzo objetivo', s.lunchHour, s.lunchMinute,
                          (h, m) => provider.update(AppSettings.fromMap({...s.toMap(), 'lunchHour': h, 'lunchMinute': m}))),
                      _TimeTile('Hora cena objetivo', s.dinnerHour, s.dinnerMinute,
                          (h, m) => provider.update(AppSettings.fromMap({...s.toMap(), 'dinnerHour': h, 'dinnerMinute': m}))),
                      _SwitchTile(
                        'Recordatorio feria sábado',
                        s.saturdayReminderEnabled,
                        (v) => provider.update(AppSettings.fromMap({...s.toMap(), 'saturdayReminderEnabled': v ? 1 : 0})),
                      ),
                      _SwitchTile(
                        'Recordatorio peso dominical',
                        s.weeklyWeightReminderEnabled,
                        (v) => provider.update(AppSettings.fromMap({...s.toMap(), 'weeklyWeightReminderEnabled': v ? 1 : 0})),
                      ),
                      const SizedBox(height: 16),
                      _SectionLabel('DATOS'),
                      _ActionTile(Icons.upload, 'Exportar datos', Colors.blueAccent,
                          () => _exportData(ctx, provider)),
                      _ActionTile(Icons.delete_forever, 'Resetear todos los datos', Colors.redAccent,
                          () => _confirmReset(ctx, provider)),
                      const SizedBox(height: 16),
                      _SectionLabel('ACERCA DE'),
                      _AboutCard(),
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
        backgroundColor: const Color(0xFF2A1A1A),
        title: const Text('Resetear datos', style: TextStyle(color: Colors.redAccent)),
        content: const Text('¿Borrar TODOS los datos registrados? Esta acción no se puede deshacer.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.resetAllData();
            },
            child: const Text('Borrar todo', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5)),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SwitchListTile(
        title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        value: value,
        activeColor: Colors.blueAccent,
        onChanged: onChanged,
      ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        trailing: Text('${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.blueAccent, fontSize: 16)),
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: hour, minute: minute),
            builder: (ctx, child) => Theme(
              data: ThemeData.dark(),
              child: child!,
            ),
          );
          if (picked != null) onChanged(picked.hour, picked.minute);
        },
      ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.white54),
              onPressed: () { if (value > 1) onChanged(value - 1); },
            ),
            Text('$value', style: const TextStyle(color: Colors.white, fontSize: 16)),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white54),
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: TextStyle(color: color, fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white24),
        onTap: onTap,
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  final String message;
  final VoidCallback onTap;
  const _WarningCard(this.message, {required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A1A00),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.orangeAccent, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.orangeAccent, fontSize: 13))),
            const Text('Activar', style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Misiones de Salud v1.0', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          Text(
            'App personal offline para reducción de grasa abdominal, '
            'mejora de hígado graso y mantenimiento muscular.\n\n'
            'AVISO MÉDICO: Esta app no es consejo médico. Para hígado graso, '
            'glucosa, colesterol, dolor o medicación, consulta con tu médico.',
            style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }
}
