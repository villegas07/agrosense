import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

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
  Future<List<HourlyReading>> getTemperatureHistory(
    String sectorId, {
    int hours = 24,
  }) async {
    try {
      final response = await _dio.get(
        '/api/dashboard/$sectorId/history',
        queryParameters: {'hours': hours},
      );
      final json = response.data as Map<String, dynamic>;
      return (json['hourly'] as List<dynamic>)
          .map((e) => HourlyReadingModel.fromJson(e as Map<String, dynamic>))
          .toList();
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
      throw ServerFailure('Error inesperado al cargar historial: $e');
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
  Future<void> exportAndOpenSectorData(
    String sectorId, {
    int hours = 168,
  }) async {
    try {
      final response = await _dio.get(
        '/api/dashboard/$sectorId/export',
        queryParameters: {'hours': hours},
        options: Options(responseType: ResponseType.bytes),
      );
      final dir = await getApplicationDocumentsDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/agrosense_${sectorId}_$ts.xlsx');
      await file.writeAsBytes(response.data as List<int>);
      await OpenFilex.open(file.path);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const ServerFailure('Sector no encontrado');
      }
      if (e.response?.statusCode == 401) {
        throw const AuthFailure('Sesión expirada');
      }
      throw NetworkFailure(
          'No se pudo descargar el archivo: ${e.message ?? 'sin respuesta'}');
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Error al exportar datos: $e');
    }
  }

  @override
  void dispose() {}
}
