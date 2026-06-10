import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../providers/dashboard_providers.dart';
import 'section_header.dart';

class _AggPoint {
  const _AggPoint(this.time, this.ambient, this.soil);

  final DateTime time;
  final double ambient;
  final double soil;
}

class Last24HoursCard extends ConsumerStatefulWidget {
  const Last24HoursCard({
    super.key,
    required this.sectorId,
    this.alertMessage,
  });

  final String sectorId;
  final String? alertMessage;

  @override
  ConsumerState<Last24HoursCard> createState() => _Last24HoursCardState();
}

class _Last24HoursCardState extends ConsumerState<Last24HoursCard> {
  TemperatureFilter _filter = TemperatureFilter.hours;

  List<_AggPoint> _aggregateToDaily(List<HourlyReading> readings) {
    final Map<String, List<HourlyReading>> groups = {};
    for (final r in readings) {
      if (r.ambientTemp == 0.0 && r.soilTemp == 0.0) continue;
      final local = r.time.toLocal();
      final key = '${local.year}-${local.month}-${local.day}';
      groups.putIfAbsent(key, () => []).add(r);
    }
    final sortedKeys = groups.keys.toList()..sort();
    return sortedKeys.map((key) {
      final group = groups[key]!;
      final ambient = group.where((r) => r.ambientTemp != 0.0).map((r) => r.ambientTemp).toList();
      final soil = group.where((r) => r.soilTemp != 0.0).map((r) => r.soilTemp).toList();
      final avgA = ambient.isEmpty ? 0.0 : ambient.reduce((a, b) => a + b) / ambient.length;
      final avgS = soil.isEmpty ? 0.0 : soil.reduce((a, b) => a + b) / soil.length;
      return _AggPoint(group.first.time.toLocal(), avgA, avgS);
    }).toList();
  }

  List<_AggPoint> _aggregateToWeekly(List<HourlyReading> readings) {
    final Map<int, List<HourlyReading>> groups = {};
    for (final r in readings) {
      if (r.ambientTemp == 0.0 && r.soilTemp == 0.0) continue;
      final bucket = r.time.millisecondsSinceEpoch ~/ (7 * 24 * 3600 * 1000);
      groups.putIfAbsent(bucket, () => []).add(r);
    }
    final sortedKeys = groups.keys.toList()..sort();
    return sortedKeys.map((key) {
      final group = groups[key]!;
      final ambient = group.where((r) => r.ambientTemp != 0.0).map((r) => r.ambientTemp).toList();
      final soil = group.where((r) => r.soilTemp != 0.0).map((r) => r.soilTemp).toList();
      final avgA = ambient.isEmpty ? 0.0 : ambient.reduce((a, b) => a + b) / ambient.length;
      final avgS = soil.isEmpty ? 0.0 : soil.reduce((a, b) => a + b) / soil.length;
      return _AggPoint(group.first.time.toLocal(), avgA, avgS);
    }).toList();
  }

  List<_AggPoint> _toPoints(List<HourlyReading> readings) => switch (_filter) {
        TemperatureFilter.hours => readings
            .map((r) => _AggPoint(r.time.toLocal(), r.ambientTemp, r.soilTemp))
            .toList(),
        TemperatureFilter.days => _aggregateToDaily(readings),
        TemperatureFilter.week => _aggregateToWeekly(readings),
      };

  String _filterLabel() => switch (_filter) {
        TemperatureFilter.hours => 'Últimas 24 horas',
        TemperatureFilter.days => 'Últimos 7 días',
        TemperatureFilter.week => 'Últimas 4 semanas',
      };

  void _setFilter(TemperatureFilter f) => setState(() => _filter = f);

  @override
  Widget build(BuildContext context) {
    final histAsync = ref.watch(
      temperatureHistoryProvider((sectorId: widget.sectorId, filter: _filter)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          icon: Icons.show_chart,
          title: 'Temperatura por Período',
          trailing: Text(
            _filterLabel(),
            style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter chips
                Row(
                  children: [
                    _FilterChip(
                      label: 'Horas',
                      isSelected: _filter == TemperatureFilter.hours,
                      onTap: () => _setFilter(TemperatureFilter.hours),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Días',
                      isSelected: _filter == TemperatureFilter.days,
                      onTap: () => _setFilter(TemperatureFilter.days),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Semana',
                      isSelected: _filter == TemperatureFilter.week,
                      onTap: () => _setFilter(TemperatureFilter.week),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Legend
                const Row(
                  children: [
                    _ChartLegendItem(
                      color: AppColors.chartAmbient,
                      label: 'Temp. Ambiente',
                    ),
                    SizedBox(width: 16),
                    _ChartLegendItem(
                      color: AppColors.chartSoil,
                      label: 'Temp. Suelo',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Chart area
                SizedBox(
                  height: 160,
                  child: histAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.chartAmbient,
                        strokeWidth: 2,
                      ),
                    ),
                    error: (_, __) => _ErrorState(
                      onRetry: () => ref.invalidate(
                        temperatureHistoryProvider(
                          (sectorId: widget.sectorId, filter: _filter),
                        ),
                      ),
                    ),
                    data: (readings) {
                      final points = _toPoints(readings);
                      if (points.isEmpty) {
                        return const Center(
                          child: Text(
                            'Sin datos disponibles',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        );
                      }
                      return _TemperatureLineChart(
                        points: points,
                        filter: _filter,
                      );
                    },
                  ),
                ),
                // Alert banner
                if (widget.alertMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.warning,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.alertMessage!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Chart ─────────────────────────────────────────────────────────────────────

class _TemperatureLineChart extends StatelessWidget {
  const _TemperatureLineChart({
    required this.points,
    required this.filter,
  });

  final List<_AggPoint> points;
  final TemperatureFilter filter;

  double get _xInterval => switch (filter) {
        TemperatureFilter.hours => 6.0,
        TemperatureFilter.days => 1.0,
        TemperatureFilter.week => 1.0,
      };

  String _xLabel(int idx) {
    if (idx < 0 || idx >= points.length) return '';
    final t = points[idx].time;
    return switch (filter) {
      TemperatureFilter.hours =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
      TemperatureFilter.days => _dayName(t.weekday),
      TemperatureFilter.week => 'Sem ${idx + 1}',
    };
  }

  String _dayName(int weekday) => switch (weekday) {
        1 => 'Lun',
        2 => 'Mar',
        3 => 'Mié',
        4 => 'Jue',
        5 => 'Vie',
        6 => 'Sáb',
        _ => 'Dom',
      };

  List<FlSpot> _ambientSpots() => points
      .asMap()
      .entries
      .where((e) => e.value.ambient != 0.0)
      .map((e) => FlSpot(e.key.toDouble(), e.value.ambient))
      .toList();

  List<FlSpot> _soilSpots() => points
      .asMap()
      .entries
      .where((e) => e.value.soil != 0.0)
      .map((e) => FlSpot(e.key.toDouble(), e.value.soil))
      .toList();

  double _minY() {
    final temps = points
        .expand((p) => [
              if (p.ambient != 0.0) p.ambient,
              if (p.soil != 0.0) p.soil,
            ])
        .toList();
    if (temps.isEmpty) return 15.0;
    return (temps.reduce((a, b) => a < b ? a : b) - 2).floorToDouble();
  }

  double _maxY() {
    final temps = points
        .expand((p) => [
              if (p.ambient != 0.0) p.ambient,
              if (p.soil != 0.0) p.soil,
            ])
        .toList();
    if (temps.isEmpty) return 40.0;
    return (temps.reduce((a, b) => a > b ? a : b) + 2).ceilToDouble();
  }

  double _yInterval() {
    final range = _maxY() - _minY();
    if (range <= 8) return 2.0;
    if (range <= 20) return 4.0;
    return 5.0;
  }

  @override
  Widget build(BuildContext context) {
    final minY = _minY();
    final maxY = _maxY();
    final yInterval = _yInterval();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.divider,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: yInterval,
              getTitlesWidget: (value, _) => Text(
                '${value.toInt()}°',
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              interval: _xInterval,
              getTitlesWidget: (value, _) => Text(
                _xLabel(value.toInt()),
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: _ambientSpots(),
            isCurved: true,
            color: AppColors.chartAmbient,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.chartAmbient.withValues(alpha: 0.08),
            ),
          ),
          LineChartBarData(
            spots: _soilSpots(),
            isCurved: true,
            color: AppColors.chartSoil,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.chartSoil.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.chartAmbient : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.chartAmbient : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: AppColors.textTertiary,
            size: 28,
          ),
          const SizedBox(height: 8),
          const Text(
            'No se pudieron cargar los datos',
            style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.chartAmbient,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
            child: const Text('Reintentar', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _ChartLegendItem extends StatelessWidget {
  const _ChartLegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
