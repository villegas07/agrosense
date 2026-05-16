import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/dashboard_entities.dart';
import 'section_header.dart';

class Last24HoursCard extends StatelessWidget {
  const Last24HoursCard({
    super.key,
    required this.readings,
    this.alertMessage,
  });

  final List<HourlyReading> readings;
  final String? alertMessage;

  // Only plot entries where we have actual data (API returns 0.0 for null hours)
  List<FlSpot> _ambientSpots() => readings
      .asMap()
      .entries
      .where((e) => e.value.ambientTemp != 0.0)
      .map((e) => FlSpot(e.key.toDouble(), e.value.ambientTemp))
      .toList();

  List<FlSpot> _soilSpots() => readings
      .asMap()
      .entries
      .where((e) => e.value.soilTemp != 0.0)
      .map((e) => FlSpot(e.key.toDouble(), e.value.soilTemp))
      .toList();

  double _minY() {
    final temps = readings.expand((r) => [
          if (r.ambientTemp != 0.0) r.ambientTemp,
          if (r.soilTemp != 0.0) r.soilTemp,
        ]).toList();
    if (temps.isEmpty) return 15.0;
    final min = temps.reduce((a, b) => a < b ? a : b);
    return (min - 2).floorToDouble();
  }

  double _maxY() {
    final temps = readings.expand((r) => [
          if (r.ambientTemp != 0.0) r.ambientTemp,
          if (r.soilTemp != 0.0) r.soilTemp,
        ]).toList();
    if (temps.isEmpty) return 40.0;
    final max = temps.reduce((a, b) => a > b ? a : b);
    return (max + 2).ceilToDouble();
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
    final interval = _yInterval();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          icon: Icons.show_chart,
          title: 'Últimas 24 Horas',
          trailing: Text(
            'Comparación térmica por hora',
            style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
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
              children: [
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
                SizedBox(
                  height: 160,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: interval,
                        getDrawingHorizontalLine: (value) => const FlLine(
                          color: AppColors.divider,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: interval,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}°',
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 20,
                            interval: 6,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= readings.length) {
                                return const SizedBox.shrink();
                              }
                              final t = readings[idx].time;
                              final hh = t.hour.toString().padLeft(2, '0');
                              final mm = t.minute.toString().padLeft(2, '0');
                              return Text(
                                '$hh:$mm',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.textTertiary,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: readings.isEmpty ? 23 : (readings.length - 1).toDouble(),
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
                  ),
                ),
                if (alertMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: AppColors.warning, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            alertMessage!,
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
