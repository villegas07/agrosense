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
    super.tempAmb,
    super.tempSuelo,
  });

  factory SoilZoneModel.fromJson(Map<String, dynamic> json) {
    final pct = json['humidity_percent'] as int;
    return SoilZoneModel(
      name: json['name'] as String,
      depthLabel: json['depth_label'] as String,
      humidityPercent: pct,
      status: _statusFromPercent(pct),
      tempAmb:   (json['temp_amb'] as num?)?.toDouble(),
      tempSuelo: (json['temp_suelo'] as num?)?.toDouble(),
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

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) =>
      DashboardDataModel(
        sectorName: json['sector_name'] as String,
        lastUpdated: json['last_updated'] as String,
        isLive: json['is_live'] as bool,
        temperature: TemperatureReadingModel.fromJson(
            json['temperature'] as Map<String, dynamic>),
        soilZones: (json['soil_zones'] as List<dynamic>)
            .map((e) => SoilZoneModel.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name)),
        rainState: RainStateModel.fromJson(
            json['rain_state'] as Map<String, dynamic>),
        last24Hours: (json['last_24_hours'] as List<dynamic>)
            .map((e) => HourlyReadingModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        alertMessage: json['alert_message'] as String?,
        weeklyRain: (json['weekly_rain'] as List<dynamic>)
            .map((e) => DailyRainModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        monthlyRain: (json['monthly_rain'] as List<dynamic>)
            .map((e) => DailyRainModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        heatmapData: (json['heatmap_data'] as List<dynamic>)
            .map((e) => HeatmapCellModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class RainStateModel extends RainState {
  const RainStateModel({
    required super.isRaining,
    required super.label,
    required super.lastEventDescription,
    required super.lastHours,
    required super.lastMm,
    required super.last7Days,
    required super.last7DaysMm,
    required super.last30Days,
    required super.last30DaysMm,
  });

  factory RainStateModel.fromJson(Map<String, dynamic> json) => RainStateModel(
        isRaining: json['is_raining'] as bool,
        label: json['label'] as String,
        lastEventDescription: json['last_event_description'] as String,
        lastHours: (json['last_hours'] as num).toDouble(),
        lastMm: (json['last_mm'] as num).toDouble(),
        last7Days: (json['last_7_days'] as num).toDouble(),
        last7DaysMm: (json['last_7_days_mm'] as num).toDouble(),
        last30Days: (json['last_30_days'] as num).toDouble(),
        last30DaysMm: (json['last_30_days_mm'] as num).toDouble(),
      );
}

class HourlyReadingModel extends HourlyReading {
  const HourlyReadingModel({
    required super.time,
    required super.ambientTemp,
    required super.soilTemp,
  });

  factory HourlyReadingModel.fromJson(Map<String, dynamic> json) =>
      HourlyReadingModel(
        time: DateTime.parse(json['time'] as String),
        ambientTemp: (json['ambient_temp'] as num?)?.toDouble() ?? 0.0,
        soilTemp: (json['soil_temp'] as num?)?.toDouble() ?? 0.0,
      );
}

class DailyRainModel extends DailyRain {
  const DailyRainModel({required super.day, required super.mm});

  factory DailyRainModel.fromJson(Map<String, dynamic> json) => DailyRainModel(
        day: json['day'] as String,
        mm: (json['mm'] as num).toDouble(),
      );
}

class HeatmapCellModel extends HeatmapCell {
  const HeatmapCellModel({required super.label, required super.value});

  factory HeatmapCellModel.fromJson(Map<String, dynamic> json) =>
      HeatmapCellModel(
        label: json['label'] as String,
        value: (json['value'] as num).toDouble(),
      );
}
