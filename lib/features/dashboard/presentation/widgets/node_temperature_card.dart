import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/dashboard_entities.dart';
import 'section_header.dart';

class NodeTemperatureCard extends StatelessWidget {
  const NodeTemperatureCard({super.key, required this.zones});

  final List<SoilZone> zones;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          icon: Icons.thermostat_outlined,
          title: 'Temperatura por nodo',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (int i = 0; i < zones.length; i++) ...[
                _NodeTempRow(zone: zones[i]),
                if (i < zones.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _NodeTempRow extends StatelessWidget {
  const _NodeTempRow({required this.zone});

  final SoilZone zone;

  @override
  Widget build(BuildContext context) {
    final hasData = zone.tempAmb != null || zone.tempSuelo != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco_rounded, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  zone.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                zone.depthLabel,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (!hasData)
            const Text(
              'Sin datos de temperatura',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _TempChip(
                    icon: Icons.wb_sunny_outlined,
                    label: 'Ambiente',
                    value: zone.tempAmb,
                    color: AppColors.tempAmbient,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TempChip(
                    icon: Icons.grass_outlined,
                    label: 'Suelo',
                    value: zone.tempSuelo,
                    color: AppColors.tempSoil,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TempChip extends StatelessWidget {
  const _TempChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final double? value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          value != null
              ? RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value!.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.8,
                          height: 1,
                        ),
                      ),
                      const TextSpan(
                        text: ' °C',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : const Text(
                  '— °C',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                    height: 1,
                  ),
                ),
        ],
      ),
    );
  }
}
