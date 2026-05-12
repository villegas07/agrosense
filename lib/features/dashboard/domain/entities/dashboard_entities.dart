import 'package:equatable/equatable.dart';

// ── Temperature ──────────────────────────────────────────────────────────────
class TemperatureReading extends Equatable {
  const TemperatureReading({
    required this.ambientCelsius,
    required this.soilCelsius,
    required this.ambientDelta,
    required this.soilDelta,
  });

  final double ambientCelsius;
  final double soilCelsius;
  final double ambientDelta;
  final double soilDelta;

  @override
  List<Object?> get props =>
      [ambientCelsius, soilCelsius, ambientDelta, soilDelta];
}

// ── Soil Zone ────────────────────────────────────────────────────────────────
enum SoilHumidityStatus { optimal, warning, danger }

class SoilZone extends Equatable {
  const SoilZone({
    required this.name,
    required this.depthLabel,
    required this.humidityPercent,
    required this.status,
  });

  final String name;
  final String depthLabel;
  final int humidityPercent;
  final SoilHumidityStatus status;

  @override
  List<Object?> get props => [name, depthLabel, humidityPercent, status];
}

// ── Rain State ───────────────────────────────────────────────────────────────
class RainState extends Equatable {
  const RainState({
    required this.isRaining,
    required this.label,
    required this.lastEventDescription,
    required this.lastHours,
    required this.lastMm,
    required this.last7Days,
    required this.last7DaysMm,
    required this.last30Days,
    required this.last30DaysMm,
  });

  final bool isRaining;
  final String label;
  final String lastEventDescription;
  final double lastHours;
  final double lastMm;
  final double last7Days;
  final double last7DaysMm;
  final double last30Days;
  final double last30DaysMm;

  @override
  List<Object?> get props => [
        isRaining,
        label,
        lastEventDescription,
        lastHours,
        lastMm,
        last7Days,
        last7DaysMm,
        last30Days,
        last30DaysMm,
      ];
}

// ── Hourly Reading ───────────────────────────────────────────────────────────
class HourlyReading extends Equatable {
  const HourlyReading({
    required this.time,
    required this.ambientTemp,
    required this.soilTemp,
  });

  final DateTime time;
  final double ambientTemp;
  final double soilTemp;

  @override
  List<Object?> get props => [time, ambientTemp, soilTemp];
}

// ── Daily Rain ───────────────────────────────────────────────────────────────
class DailyRain extends Equatable {
  const DailyRain({required this.day, required this.mm});

  final String day;
  final double mm;

  @override
  List<Object?> get props => [day, mm];
}

// ── Heatmap Cell ─────────────────────────────────────────────────────────────
class HeatmapCell extends Equatable {
  const HeatmapCell({required this.label, required this.value});

  final String label;
  final double value;

  @override
  List<Object?> get props => [label, value];
}

// ── Dashboard Aggregate ──────────────────────────────────────────────────────
class DashboardData extends Equatable {
  const DashboardData({
    required this.sectorName,
    required this.lastUpdated,
    required this.isLive,
    required this.temperature,
    required this.soilZones,
    required this.rainState,
    required this.last24Hours,
    this.alertMessage,
    required this.weeklyRain,
    required this.monthlyRain,
    required this.heatmapData,
  });

  final String sectorName;
  final String lastUpdated;
  final bool isLive;
  final TemperatureReading temperature;
  final List<SoilZone> soilZones;
  final RainState rainState;
  final List<HourlyReading> last24Hours;
  final String? alertMessage;
  final List<DailyRain> weeklyRain;
  final List<DailyRain> monthlyRain;
  final List<HeatmapCell> heatmapData;

  @override
  List<Object?> get props => [
        sectorName,
        lastUpdated,
        isLive,
        temperature,
        soilZones,
        rainState,
        last24Hours,
        alertMessage,
        weeklyRain,
        monthlyRain,
        heatmapData,
      ];
}
