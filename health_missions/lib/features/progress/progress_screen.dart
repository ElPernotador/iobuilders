import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/date_utils.dart';
import '../../core/models/body_metric.dart';
import 'progress_provider.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (ctx, provider, _) {
        if (provider.loading) return const Center(child: CircularProgressIndicator());
        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0xFF1E1E1E),
                title: const Text('Progreso', style: TextStyle(color: Colors.white)),
                floating: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () => _showAddMetric(ctx, provider),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatsRow(provider: provider),
                      const SizedBox(height: 20),
                      if (provider.metrics.length >= 2) ...[
                        _ChartCard(
                          title: 'Peso (kg)',
                          metrics: provider.metrics,
                          getValue: (m) => m.weight,
                        ),
                        const SizedBox(height: 16),
                        _ChartCard(
                          title: 'Cintura (cm)',
                          metrics: provider.metrics,
                          getValue: (m) => m.waist,
                        ),
                        const SizedBox(height: 16),
                      ],
                      _PhotosCard(metrics: provider.metrics),
                      const SizedBox(height: 16),
                      _LiverRiskCard(direction: provider.liverRiskDirection),
                      const SizedBox(height: 16),
                      _WeeklyTrainingCard(provider: provider),
                      const SizedBox(height: 16),
                      _HeatmapCard(heatmap: provider.habitHeatmap),
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

  void _showAddMetric(BuildContext ctx, ProgressProvider provider) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      builder: (_) => _AddMetricSheet(provider: provider),
    );
  }
}

// ─────────────────────────────── Bottom Sheet ────────────────────────────────

class _AddMetricSheet extends StatefulWidget {
  final ProgressProvider provider;
  const _AddMetricSheet({required this.provider});

  @override
  State<_AddMetricSheet> createState() => _AddMetricSheetState();
}

class _AddMetricSheetState extends State<_AddMetricSheet> {
  final _weightCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  String? _frontPath;
  String? _sidePath;
  final _picker = ImagePicker();

  Future<void> _pickPhoto({required bool front, required bool fromCamera}) async {
    final source = fromCamera ? ImageSource.camera : ImageSource.gallery;
    final file = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 1200);
    if (file == null) return;
    setState(() {
      if (front) {
        _frontPath = file.path;
      } else {
        _sidePath = file.path;
      }
    });
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _waistCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Registrar medidas',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _MetricField('Peso (kg)', _weightCtrl, '84.5'),
            const SizedBox(height: 8),
            _MetricField('Cintura (cm)', _waistCtrl, '98'),
            const SizedBox(height: 20),
            const Text('FOTOS DE PROGRESO',
                style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _PhotoSlot(
                    label: 'Frontal',
                    path: _frontPath,
                    onCamera: () => _pickPhoto(front: true, fromCamera: true),
                    onGallery: () => _pickPhoto(front: true, fromCamera: false),
                    onClear: () => setState(() => _frontPath = null),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PhotoSlot(
                    label: 'Lateral',
                    path: _sidePath,
                    onCamera: () => _pickPhoto(front: false, fromCamera: true),
                    onGallery: () => _pickPhoto(front: false, fromCamera: false),
                    onClear: () => setState(() => _sidePath = null),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final weight = double.tryParse(_weightCtrl.text.replaceAll(',', '.'));
                final waist = double.tryParse(_waistCtrl.text.replaceAll(',', '.'));
                Navigator.pop(context);
                widget.provider.addMetric(BodyMetric(
                  date: AppDateUtils.todayString(),
                  weight: weight,
                  waist: waist,
                  frontPhotoPath: _frontPath,
                  sidePhotoPath: _sidePath,
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Guardar'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────── Photo Slot Widget ────────────────────────────

class _PhotoSlot extends StatelessWidget {
  final String label;
  final String? path;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onClear;

  const _PhotoSlot({
    required this.label,
    required this.path,
    required this.onCamera,
    required this.onGallery,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onCamera,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: path != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(File(path!), fit: BoxFit.cover,
                        width: double.infinity, height: double.infinity),
                  )
                : const Center(
                    child: Icon(Icons.camera_alt_outlined, color: Colors.white38, size: 36),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.camera_alt, size: 18, color: Colors.blueAccent),
              onPressed: onCamera,
              tooltip: 'Cámara',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.photo_library_outlined, size: 18, color: Colors.blueAccent),
              onPressed: onGallery,
              tooltip: 'Galería',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            if (path != null) ...[
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: Colors.white38),
                onPressed: onClear,
                tooltip: 'Quitar',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ────────────────────────────── Photos Timeline Card ─────────────────────────

class _PhotosCard extends StatelessWidget {
  final List<BodyMetric> metrics;
  const _PhotosCard({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final withPhotos = metrics
        .where((m) => m.frontPhotoPath != null || m.sidePhotoPath != null)
        .toList();

    if (withPhotos.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FOTOS DE PROGRESO',
              style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: withPhotos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final m = withPhotos[i];
                final path = m.frontPhotoPath ?? m.sidePhotoPath!;
                return GestureDetector(
                  onTap: () => _showFullPhoto(context, m),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(path),
                          width: 90,
                          height: 108,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(m.date,
                          style: const TextStyle(color: Colors.white38, fontSize: 9)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFullPhoto(BuildContext context, BodyMetric m) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Text(m.date, style: const TextStyle(color: Colors.white70)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (m.frontPhotoPath != null)
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Frontal',
                            style: TextStyle(color: Colors.white38, fontSize: 11)),
                        const SizedBox(height: 4),
                        Image.file(File(m.frontPhotoPath!), fit: BoxFit.contain),
                      ],
                    ),
                  ),
                if (m.frontPhotoPath != null && m.sidePhotoPath != null)
                  const SizedBox(width: 4),
                if (m.sidePhotoPath != null)
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Lateral',
                            style: TextStyle(color: Colors.white38, fontSize: 11)),
                        const SizedBox(height: 4),
                        Image.file(File(m.sidePhotoPath!), fit: BoxFit.contain),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────── Other Widgets ───────────────────────────────

class _StatsRow extends StatelessWidget {
  final ProgressProvider provider;
  const _StatsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final latest = provider.latestMetric;
    return Row(
      children: [
        Expanded(
            child: _StatCard(
                'Peso actual', latest?.weight != null ? '${latest!.weight} kg' : '–')),
        const SizedBox(width: 8),
        Expanded(
            child: _StatCard(
                'Cintura', latest?.waist != null ? '${latest!.waist} cm' : '–')),
        const SizedBox(width: 8),
        Expanded(
            child: _StatCard(
          'Cambio peso',
          provider.weightTrend != null
              ? '${provider.weightTrend!.toStringAsFixed(1)} kg'
              : '–',
          color: provider.weightTrend != null && provider.weightTrend! < 0
              ? Colors.greenAccent
              : null,
        )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _StatCard(this.label, this.value, {this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 10),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color ?? Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final List<BodyMetric> metrics;
  final double? Function(BodyMetric) getValue;
  const _ChartCard(
      {required this.title, required this.metrics, required this.getValue});

  @override
  Widget build(BuildContext context) {
    final points = metrics
        .asMap()
        .entries
        .where((e) => getValue(e.value) != null)
        .map((e) => FlSpot(e.key.toDouble(), getValue(e.value)!))
        .toList();

    if (points.length < 2) return const SizedBox.shrink();

    final minY =
        points.map((p) => p.y).reduce((a, b) => a < b ? a : b) - 2;
    final maxY =
        points.map((p) => p.y).reduce((a, b) => a > b ? a : b) + 2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: points,
                    isCurved: true,
                    color: Colors.blueAccent,
                    barWidth: 2,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blueAccent.withValues(alpha: 0.1),
                    ),
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

class _LiverRiskCard extends StatelessWidget {
  final String direction;
  const _LiverRiskCard({required this.direction});
  @override
  Widget build(BuildContext context) {
    final isImproving = direction.contains('↓');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isImproving ? const Color(0xFF1B3A2D) : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ESTIMACIÓN RIESGO HÍGADO GRASO',
              style: TextStyle(
                  color: Colors.white38, fontSize: 10, letterSpacing: 1.5)),
          const SizedBox(height: 6),
          Text(direction,
              style: TextStyle(
                color: isImproving ? Colors.greenAccent : Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 4),
          const Text(
              'Estimación no médica basada en tendencia de peso/cintura.',
              style: TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }
}

class _WeeklyTrainingCard extends StatelessWidget {
  final ProgressProvider provider;
  const _WeeklyTrainingCard({required this.provider});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.fitness_center, color: Colors.blueAccent),
                const SizedBox(height: 4),
                Text('${provider.strengthSessionsLast7Days}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const Text('sesiones fuerza\n(7 días)',
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.directions_bike, color: Colors.greenAccent),
                const SizedBox(height: 4),
                Text('${provider.bicycleMinutesLast7Days}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const Text('min bicicleta\n(7 días)',
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeatmapCard extends StatelessWidget {
  final Map<String, int> heatmap;
  const _HeatmapCard({required this.heatmap});

  @override
  Widget build(BuildContext context) {
    if (heatmap.isEmpty) return const SizedBox.shrink();

    final last30 = List.generate(30, (i) {
      final d = DateTime.now().subtract(Duration(days: 29 - i));
      final key = AppDateUtils.toDateString(d);
      return MapEntry(key, heatmap[key] ?? 0);
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('HÁBITOS (30 DÍAS)',
              style: TextStyle(
                  color: Colors.white38, fontSize: 11, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: last30.map((e) {
              final score = e.value;
              final opacity =
                  score == 0 ? 0.1 : (score / 15).clamp(0.2, 1.0);
              return Tooltip(
                message: '${e.key}: $score checks',
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: opacity),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MetricField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  const _MetricField(this.label, this.controller, this.hint);
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent)),
      ),
    );
  }
}
