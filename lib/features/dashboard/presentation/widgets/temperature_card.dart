import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/dashboard_entities.dart';
import 'section_header.dart';

class TemperatureCard extends StatelessWidget {
  const TemperatureCard({super.key, required this.temperature});

  final TemperatureReading temperature;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          icon: Icons.thermostat_outlined,
          title: 'Temperatura',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _TempTile(
                  label: 'Ambiente',
                  value: temperature.ambientCelsius,
                  delta: temperature.ambientDelta,
                  color: AppColors.tempAmbient,
                  icon: Icons.wb_sunny_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TempTile(
                  label: 'Suelo',
                  value: temperature.soilCelsius,
                  delta: temperature.soilDelta,
                  color: AppColors.tempSoil,
                  icon: Icons.grass_outlined,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TempTile extends StatelessWidget {
  const _TempTile({
    required this.label,
    required this.value,
    required this.delta,
    required this.color,
    required this.icon,
  });

  final String label;
  final double value;
  final double delta;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isPositiveDelta = delta >= 0;
    final deltaColor = isPositiveDelta ? AppColors.danger : AppColors.optimal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Main value
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -1.0,
                    height: 1,
                  ),
                ),
                const TextSpan(
                  text: ' °C',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Delta vs yesterday
          Row(
            children: [
              Icon(
                isPositiveDelta
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 12,
                color: deltaColor,
              ),
              const SizedBox(width: 2),
              Text(
                '${delta.abs().toStringAsFixed(1)}° vs ayer',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: deltaColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
