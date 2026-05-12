import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/dashboard_entities.dart';

/// Los modelos extienden las entidades y añaden capacidad de serialización.
/// La capa Domain no sabe nada de JSON.

class TemperatureReadingModel extends TemperatureReading {
  const TemperatureReadingModel({
    required super.ambientCelsius,
    required super.soilCelsius,
    required super.ambientDelta,
    required super.soilDelta,
  });

  factory TemperatureReadingModel.fromJson(Map<String, dynamic> json) =>
      TemperatureReadingModel(
        ambientCelsius: (json['ambient_celsius'] as num).toDouble(),
        soilCelsius: (json['soil_celsius'] as num).toDouble(),
        ambientDelta: (json['ambient_delta'] as num).toDouble(),
        soilDelta: (json['soil_delta'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'ambient_celsius': ambientCelsius,
        'soil_celsius': soilCelsius,
        'ambient_delta': ambientDelta,
        'soil_delta': soilDelta,
      };
}

class SoilZoneModel extends SoilZone {
  const SoilZoneModel({
    required super.name,
    required super.depthLabel,
    required super.humidityPercent,
    required super.status,
  });

  factory SoilZoneModel.fromJson(Map<String, dynamic> json) {
    final pct = json['humidity_percent'] as int;
    return SoilZoneModel(
      name: json['name'] as String,
      depthLabel: json['depth_label'] as String,
      humidityPercent: pct,
      status: _statusFromPercent(pct),
    );
  }

  static SoilHumidityStatus _statusFromPercent(int pct) {
    if (pct >= AppConstants.optimalMin && pct <= AppConstants.optimalMax) {
      return SoilHumidityStatus.optimal;
    }
    if (pct >= AppConstants.dangerThreshold) return SoilHumidityStatus.warning;
    return SoilHumidityStatus.danger;
  }
}

class DashboardDataModel extends DashboardData {
  const DashboardDataModel({
    required super.sectorName,
    required super.lastUpdated,
    required super.isLive,
    required super.temperature,
    required super.soilZones,
    required super.rainState,
    required super.last24Hours,
    super.alertMessage,
    required super.weeklyRain,
    required super.monthlyRain,
    required super.heatmapData,
  });
}
