import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/dashboard_local_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/dashboard_usecases.dart';

// ── Data Sources ─────────────────────────────────────────────────────────────
final dashboardLocalDataSourceProvider =
    Provider<DashboardLocalDataSource>((ref) {
  final ds = DashboardLocalDataSourceImpl();
  ref.onDispose(ds.dispose);
  return ds;
});

// ── Repositories ─────────────────────────────────────────────────────────────
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(
    ref.watch(dashboardLocalDataSourceProvider),
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

// ── State ─────────────────────────────────────────────────────────────────────
final selectedSectorIdProvider = StateProvider<String>((ref) => 'sector_3');

final dashboardDataProvider =
    StreamProvider.family<DashboardData, String>((ref, sectorId) {
  final useCase = ref.watch(watchDashboardDataUseCaseProvider);
  return useCase(sectorId);
});
