import '../../../../core/errors/failures.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_datasource.dart';

/// Liskov Substitution: sustituye completamente a DashboardRepository
/// sin alterar el comportamiento esperado por los consumidores.
class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._localDataSource);

  final DashboardLocalDataSource _localDataSource;

  @override
  Future<DashboardData> getDashboardData(String sectorId) async {
    try {
      return await _localDataSource.getDashboardData(sectorId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw CacheFailure('Error al obtener datos del sector: $e');
    }
  }

  @override
  Stream<DashboardData> watchDashboardData(String sectorId) {
    try {
      return _localDataSource.watchDashboardData(sectorId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw CacheFailure('Error al observar datos del sector: $e');
    }
  }
}
