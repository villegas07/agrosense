import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String username,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AuthResponseModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'username': username, 'password': password},
      );
      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final msg =
            (e.response?.data as Map<String, dynamic>?)?['error'] as String? ??
                'Credenciales incorrectas';
        throw AuthFailure(msg);
      }
      throw NetworkFailure(
          'Error de conexión: ${e.message ?? 'sin respuesta'}');
    }
  }
}
