import '../entities/dashboard_entities.dart';

/// Dependency Inversion Principle — Presentation y Data dependen de esta
/// abstracción; nunca al revés.
abstract class DashboardRepository {
  Future<DashboardData> getDashboardData(String sectorId);
  Stream<DashboardData> watchDashboardData(String sectorId);
}
