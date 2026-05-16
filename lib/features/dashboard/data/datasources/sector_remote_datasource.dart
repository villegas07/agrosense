import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/sector_entity.dart';
import '../models/sector_model.dart';

class SectorRemoteDataSource {
  const SectorRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Sector>> getSectors() async {
    try {
      final response = await _dio.get('/api/dashboard/sectors');
      final list = response.data as List<dynamic>;
      return list
          .map((e) => SectorModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkFailure(
          'No se pudieron cargar los sectores: ${e.message ?? 'sin respuesta'}');
    } catch (e) {
      throw ServerFailure('Error inesperado al cargar sectores: $e');
    }
  }
}
