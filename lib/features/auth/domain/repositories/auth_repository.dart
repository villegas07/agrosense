import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<User> login({
    required String username,
    required String password,
  });

  Future<void> logout();
}
