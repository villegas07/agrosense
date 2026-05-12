import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/dashboard_entities.dart';
import 'section_header.dart';

class SoilHumidityCard extends StatelessWidget {
  const SoilHumidityCard({super.key, required this.zones});

  final List<SoilZone> zones;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          icon: Icons.water_drop_outlined,
          title: 'Humedad del Suelo',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (int i = 0; i < zones.length; i++) ...[
                _SoilZoneTile(zone: zones[i]),
                if (i < zones.length - 1) const SizedBox(height: 10),
              ],
              const SizedBox(height: 14),
              const _HumidityLegend(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Single Zone Tile ──────────────────────────────────────────────────────────
class _SoilZoneTile extends StatelessWidget {
  const _SoilZoneTile({required this.zone});

  final SoilZone zone;

  Color get _statusColor {
    switch (zone.status) {
      case SoilHumidityStatus.optimal:
        return AppColors.optimal;
      case SoilHumidityStatus.warning:
        return AppColors.warning;
      case SoilHumidityStatus.danger:
        return AppColors.danger;
    }
  }

  String get _statusLabel {
    switch (zone.status) {
      case SoilHumidityStatus.optimal:
        return 'Óptimo';
      case SoilHumidityStatus.warning:
        return 'Alerta';
      case SoilHumidityStatus.danger:
        return 'Riesgo urgente';
    }
  }

  bool get _isDanger => zone.status == SoilHumidityStatus.danger;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isDanger
            ? AppColors.danger.withValues(alpha: 0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isDanger
              ? AppColors.danger.withValues(alpha: 0.3)
              : AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      zone.depthLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Percentage
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${zone.humidityPercent}',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: color,
                            letterSpacing: -0.5,
                            height: 1,
                          ),
                        ),
                        const TextSpan(
                          text: '%',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          LayoutBuilder(
            builder: (context, constraints) {
              final total = constraints.maxWidth;
              final filled = total * (zone.humidityPercent / 100);
              final optStart = total * 0.40;
              final optWidth = total * 0.35;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Track
                  Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Optimal range highlight (40–75%)
                  Positioned(
                    left: optStart,
                    child: Container(
                      height: 7,
                      width: optWidth,
                      decoration: BoxDecoration(
                        color: AppColors.optimal.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // Filled bar
                  Container(
                    height: 7,
                    width: filled,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 5),

          // Range labels
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0%',
                  style: TextStyle(
                      fontSize: 9, color: AppColors.textTertiary)),
              Text('40–75% rango óptimo',
                  style: TextStyle(
                      fontSize: 9, color: AppColors.textTertiary)),
              Text('100%',
                  style: TextStyle(
                      fontSize: 9, color: AppColors.textTertiary)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Legend ────────────────────────────────────────────────────────────────────
class _HumidityLegend extends StatelessWidget {
  const _HumidityLegend();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 4,
      children: [
        _LegendItem(color: AppColors.optimal, label: 'Óptimo (40–75%)'),
        _LegendItem(color: AppColors.warning, label: 'Alerta'),
        _LegendItem(color: AppColors.danger, label: 'Riesgo urgente'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style:
              const TextStyle(fontSize: 10, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
