import 'dart:async';
import '../../domain/entities/dashboard_entities.dart';
import '../models/dashboard_models.dart';

/// Interface — Interface Segregation Principle: solo expone lo necesario.
abstract class DashboardLocalDataSource {
  Future<DashboardData> getDashboardData(String sectorId);
  Stream<DashboardData> watchDashboardData(String sectorId);
  Future<List<HourlyReading>> getTemperatureHistory(
    String sectorId, {
    int hours = 24,
  });
  Future<void> exportAndOpenSectorData(String sectorId, {int hours = 168});
  void dispose();
}

/// Implementación con datos mock que simulan un sensor en tiempo real.
/// Para conectar una API real, crea DashboardRemoteDataSourceImpl
/// implementando la misma interfaz sin tocar nada más.
class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  DashboardLocalDataSourceImpl() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_controller.isClosed) {
        _controller.add(_buildMockData());
      }
    });
  }

  final StreamController<DashboardData> _controller =
      StreamController<DashboardData>.broadcast();

  Timer? _timer;

  DashboardData _buildMockData() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');

    return DashboardDataModel(
      sectorName: 'Parcela Norte — Sector 3',
      lastUpdated: 'Hoy, $h:$m',
      isLive: true,
      temperature: const TemperatureReadingModel(
        ambientCelsius: 28.4,
        soilCelsius: 22.1,
        ambientDelta: 2.1,
        soilDelta: -0.8,
      ),
      soilZones: const [
        SoilZoneModel(
          name: 'Zona A — Invernadero',
          depthLabel: 'Profundidad: 20 cm',
          humidityPercent: 61,
          status: SoilHumidityStatus.optimal,
        ),
        SoilZoneModel(
          name: 'Zona B — Campo abierto',
          depthLabel: 'Profundidad: 30 cm',
          humidityPercent: 42,
          status: SoilHumidityStatus.optimal,
        ),
        SoilZoneModel(
          name: 'Zona C — Perímetro',
          depthLabel: 'Profundidad: 15 cm',
          humidityPercent: 29,
          status: SoilHumidityStatus.warning,
        ),
      ],
      rainState: const RainState(
        isRaining: false,
        label: 'Sin lluvia',
        lastEventDescription: 'Hace 13h (3.2 mm)',
        lastHours: 13,
        lastMm: 3.2,
        last7Days: 7,
        last7DaysMm: 21.8,
        last30Days: 30,
        last30DaysMm: 68.4,
      ),
      last24Hours: _buildHourlyReadings(now),
      alertMessage:
          'Patrón detectado: la temperatura ambiente supera al suelo '
          'en 6.3°C de manera persistente. Riesgo de estrés térmico entre 12:00–14:00.',
      weeklyRain: const [
        DailyRain(day: 'Sam', mm: 5),
        DailyRain(day: 'Dom', mm: 0),
        DailyRain(day: 'Mar', mm: 12),
        DailyRain(day: 'Mié', mm: 3),
        DailyRain(day: 'Jue', mm: 18),
        DailyRain(day: 'Vie', mm: 7),
        DailyRain(day: 'Hoy', mm: 2),
      ],
      monthlyRain: _buildMonthlyRain(now),
      heatmapData: _buildHeatmapData(),
    );
  }

  List<HourlyReading> _buildHourlyReadings(DateTime base) {
    final baseDate = DateTime(base.year, base.month, base.day);
    const ambientValues = [
      24.0, 23.5, 23.0, 22.8, 22.5, 23.0, 24.5, 26.0,
      27.5, 28.4, 29.0, 29.5, 30.0, 29.8, 29.2, 28.8,
      28.4, 27.9, 27.2, 26.5, 26.0, 25.5, 25.0, 24.5,
    ];
    const soilValues = [
      21.0, 20.8, 20.6, 20.4, 20.2, 20.3, 20.8, 21.2,
      21.6, 22.0, 22.1, 22.3, 22.5, 22.4, 22.3, 22.2,
      22.1, 22.0, 21.8, 21.6, 21.4, 21.2, 21.0, 20.8,
    ];

    return List.generate(
      24,
      (i) => HourlyReading(
        time: baseDate.add(Duration(hours: i)),
        ambientTemp: ambientValues[i],
        soilTemp: soilValues[i],
      ),
    );
  }

  List<HeatmapCell> _buildHeatmapData() {
    const labels = [
      'L', 'M', 'X', 'J', 'V', 'S', 'D',
      'L', 'M', 'X', 'J', 'V', 'S', 'D',
      'L', 'M', 'X', 'J', 'V', 'S', 'D',
      'L', 'M', 'X', 'J', 'V', 'S', 'D',
    ];
    const values = [
      26, 27, 28, 29, 30, 28, 25,
      27, 28, 30, 31, 32, 29, 26,
      25, 26, 27, 28, 29, 27, 24,
      28, 29, 30, 28, 27, 26, 25,
    ];
    return List.generate(
      labels.length,
      (i) => HeatmapCell(label: labels[i], value: values[i].toDouble()),
    );
  }

  List<DailyRain> _buildMonthlyRain(DateTime base) {
    const values = [
      2.0, 0.0, 5.0, 3.0, 0.0, 8.0, 1.0,
      0.0, 4.0, 12.0, 0.0, 6.0, 3.0, 0.0,
      0.0, 9.0, 0.0, 2.0, 18.0, 7.0, 0.0,
      5.0, 0.0, 12.0, 3.0, 18.0, 7.0, 2.0,
      0.0, 4.0,
    ];
    return List.generate(values.length, (i) {
      final day = base.subtract(Duration(days: values.length - 1 - i));
      final label = '${day.day}/${day.month}';
      return DailyRain(day: label, mm: values[i]);
    });
  }

  @override
  Future<List<HourlyReading>> getTemperatureHistory(
    String sectorId, {
    int hours = 24,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _buildExtendedReadings(hours);
  }

  @override
  Future<void> exportAndOpenSectorData(String sectorId, {int hours = 168}) async {}

  List<HourlyReading> _buildExtendedReadings(int hours) {
    final now = DateTime.now();
    const ambientPattern = [
      24.0, 23.5, 23.0, 22.8, 22.5, 23.0, 24.5, 26.0,
      27.5, 28.4, 29.0, 29.5, 30.0, 29.8, 29.2, 28.8,
      28.4, 27.9, 27.2, 26.5, 26.0, 25.5, 25.0, 24.5,
    ];
    const soilPattern = [
      21.0, 20.8, 20.6, 20.4, 20.2, 20.3, 20.8, 21.2,
      21.6, 22.0, 22.1, 22.3, 22.5, 22.4, 22.3, 22.2,
      22.1, 22.0, 21.8, 21.6, 21.4, 21.2, 21.0, 20.8,
    ];
    return List.generate(hours, (i) {
      final t = now.subtract(Duration(hours: hours - 1 - i));
      return HourlyReading(
        time: t,
        ambientTemp: ambientPattern[i % 24] + (i % 7) * 0.2,
        soilTemp: soilPattern[i % 24] + (i % 5) * 0.1,
      );
    });
  }

  @override
  Future<DashboardData> getDashboardData(String sectorId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _buildMockData();
  }

  @override
  Stream<DashboardData> watchDashboardData(String sectorId) async* {
    yield _buildMockData();
    yield* _controller.stream;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
