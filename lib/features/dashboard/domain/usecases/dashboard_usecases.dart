import '../entities/dashboard_entities.dart';
import '../repositories/dashboard_repository.dart';

/// SRP: cada use-case tiene exactamente una razón para cambiar.
/// OCP: nuevos casos de uso se agregan como nuevas clases, sin modificar existentes.

class GetDashboardDataUseCase {
  const GetDashboardDataUseCase(this._repository);

  final DashboardRepository _repository;

  Future<DashboardData> call(String sectorId) =>
      _repository.getDashboardData(sectorId);
}

class WatchDashboardDataUseCase {
  const WatchDashboardDataUseCase(this._repository);

  final DashboardRepository _repository;

  Stream<DashboardData> call(String sectorId) =>
      _repository.watchDashboardData(sectorId);
}
