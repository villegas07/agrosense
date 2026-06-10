import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/datasources/dashboard_local_datasource.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../data/datasources/sector_remote_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../../domain/entities/sector_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/dashboard_usecases.dart';

// ── Sectors ───────────────────────────────────────────────────────────────────
final sectorDataSourceProvider = Provider<SectorRemoteDataSource>((ref) {
  return SectorRemoteDataSource(ref.watch(apiClientProvider).dio);
});

final sectorsProvider = FutureProvider<List<Sector>>((ref) {
  return ref.watch(sectorDataSourceProvider).getSectors();
});

// ID del sector seleccionado por el usuario (vacío = usar el primero disponible)
final selectedSectorIdProvider = StateProvider<String>((ref) => '');

// Sector efectivo: usa la selección del usuario o el primero de la lista
final effectiveSectorIdProvider = Provider<String>((ref) {
  final selected = ref.watch(selectedSectorIdProvider);
  if (selected.isNotEmpty) return selected;
  final sectors = ref.watch(sectorsProvider);
  return sectors.valueOrNull?.firstOrNull?.sectorId ?? '';
});

// ── Data Sources ──────────────────────────────────────────────────────────────
final dashboardLocalDataSourceProvider =
    Provider<DashboardLocalDataSource>((ref) {
  final ds = DashboardLocalDataSourceImpl();
  ref.onDispose(ds.dispose);
  return ds;
});

final dashboardRemoteDataSourceProvider =
    Provider<DashboardLocalDataSource>((ref) {
  return DashboardRemoteDataSourceImpl(ref.watch(apiClientProvider).dio);
});

// ── Repositories ──────────────────────────────────────────────────────────────
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(
    ref.watch(dashboardRemoteDataSourceProvider),
  );
});

// ── Use Cases ─────────────────────────────────────────────────────────────────
final getDashboardDataUseCaseProvider =
    Provider<GetDashboardDataUseCase>((ref) {
  return GetDashboardDataUseCase(ref.watch(dashboardRepositoryProvider));
});

final watchDashboardDataUseCaseProvider =
    Provider<WatchDashboardDataUseCase>((ref) {
  return WatchDashboardDataUseCase(ref.watch(dashboardRepositoryProvider));
});

// ── Dashboard Stream ──────────────────────────────────────────────────────────
final dashboardDataProvider =
    StreamProvider.family<DashboardData, String>((ref, sectorId) {
  final useCase = ref.watch(watchDashboardDataUseCaseProvider);
  return useCase(sectorId);
});

// ── Temperature History ───────────────────────────────────────────────────────
final temperatureHistoryProvider = FutureProvider.family<
    List<HourlyReading>,
    ({String sectorId, TemperatureFilter filter})>((ref, args) {
  final hours = switch (args.filter) {
    TemperatureFilter.hours => 24,
    TemperatureFilter.days => 168,
    TemperatureFilter.week => 672,
  };
  final ds = ref.watch(dashboardRemoteDataSourceProvider);
  return ds.getTemperatureHistory(args.sectorId, hours: hours);
});
