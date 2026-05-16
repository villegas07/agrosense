import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../datasources/dashboard_local_datasource.dart';
import '../models/dashboard_models.dart';

class DashboardRemoteDataSourceImpl implements DashboardLocalDataSource {
  const DashboardRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<DashboardData> getDashboardData(String sectorId) async {
    try {
      final response = await _dio.get('/api/dashboard/$sectorId');
      return DashboardDataModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const ServerFailure('Sector no encontrado');
      }
      if (e.response?.statusCode == 401) {
        throw const AuthFailure('Sesión expirada');
      }
      throw NetworkFailure(
          'No se pudo conectar al servidor: ${e.message ?? 'sin respuesta'}');
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Error inesperado al cargar datos: $e');
    }
  }

  @override
  Stream<DashboardData> watchDashboardData(String sectorId) async* {
    while (true) {
      yield await getDashboardData(sectorId);
      await Future.delayed(const Duration(seconds: 30));
    }
  }

  @override
  void dispose() {}
}
