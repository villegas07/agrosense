import '../../../../core/errors/failures.dart';
import '../../../../core/network/token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
  })  : _remoteDataSource = remoteDataSource,
        _tokenStorage = tokenStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  @override
  Future<User> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        username: username,
        password: password,
      );
      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      return response.user;
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error inesperado durante el login: $e');
    }
  }

  @override
  Future<void> logout() => _tokenStorage.clearTokens();
}
