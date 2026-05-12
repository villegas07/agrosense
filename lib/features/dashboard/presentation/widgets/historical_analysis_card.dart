import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/dashboard_entities.dart';
import 'section_header.dart';

class HistoricalAnalysisCard extends StatefulWidget {
  const HistoricalAnalysisCard({
    super.key,
    required this.weeklyRain,
    required this.monthlyRain,
    required this.heatmapData,
  });

  final List<DailyRain> weeklyRain;
  final List<DailyRain> monthlyRain;
  final List<HeatmapCell> heatmapData;

  @override
  State<HistoricalAnalysisCard> createState() => _HistoricalAnalysisCardState();
}

class _HistoricalAnalysisCardState extends State<HistoricalAnalysisCard> {
  bool _showMonthly = false;

  List<DailyRain> get _activeRain =>
      _showMonthly ? widget.monthlyRain : widget.weeklyRain;

  double get _maxY {
    final max = _activeRain.map((r) => r.mm).fold(0.0, (a, b) => a > b ? a : b);
    return (max * 1.3).ceilToDouble().clamp(10.0, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          icon: Icons.analytics_outlined,
          title: 'Análisis Histórico',
          trailing: _TabToggle(
            isMonthly: _showMonthly,
            onToggle: (v) => setState(() => _showMonthly = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bar chart
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lluvia Diaria Acumulada',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _maxY,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 5,
                            getDrawingHorizontalLine: (v) => const FlLine(
                              color: AppColors.divider,
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                interval: 5,
                                getTitlesWidget: (v, m) => Text(
                                  '${v.toInt()}',
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
                                getTitlesWidget: (v, m) {
                                  final i = v.toInt();
                                  if (i < 0 || i >= _activeRain.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Text(
                                    _activeRain[i].day,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: AppColors.textTertiary,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: _activeRain
                              .asMap()
                              .entries
                              .map(
                                (e) => BarChartGroupData(
                                  x: e.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: e.value.mm,
                                      color: AppColors.chartBar,
                                      width: 14,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Heatmap
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Heatmap — Temp. Suelo',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _HeatmapGrid(cells: widget.heatmapData),
                    const SizedBox(height: 12),
                    const _HeatmapLegend(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeatmapGrid extends StatelessWidget {
  const _HeatmapGrid({required this.cells});

  final List<HeatmapCell> cells;

  Color _colorFor(double value) {
    if (value < 24) return AppColors.heatLow;
    if (value < 28) return AppColors.heatMid;
    if (value < 30) return AppColors.warning;
    return AppColors.heatHigh;
  }

  @override
  Widget build(BuildContext context) {
    const cols = 7;
    final rows = (cells.length / cols).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: List.generate(cols, (col) {
              final i = row * cols + col;
              if (i >= cells.length) return const Expanded(child: SizedBox());
              final cell = cells[i];
              final color = _colorFor(cell.value);
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${cell.value.toInt()}°',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

class _HeatmapLegend extends StatelessWidget {
  const _HeatmapLegend();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _HeatmapLegendItem(color: AppColors.heatLow, label: '<24°'),
        SizedBox(width: 8),
        _HeatmapLegendItem(color: AppColors.heatMid, label: '24–28°'),
        SizedBox(width: 8),
        _HeatmapLegendItem(color: AppColors.warning, label: '28–30°'),
        SizedBox(width: 8),
        _HeatmapLegendItem(color: AppColors.heatHigh, label: '>30°'),
      ],
    );
  }
}

class _HeatmapLegendItem extends StatelessWidget {
  const _HeatmapLegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style:
                const TextStyle(fontSize: 9, color: AppColors.textTertiary)),
      ],
    );
  }
}

class _TabToggle extends StatelessWidget {
  const _TabToggle({required this.isMonthly, required this.onToggle});

  final bool isMonthly;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _Tab(
            label: 'Semana',
            active: !isMonthly,
            onTap: () => onToggle(false),
          ),
          _Tab(
            label: 'Mes',
            active: isMonthly,
            onTap: () => onToggle(true),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.primary : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
