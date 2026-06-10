import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'api_config.dart';
import 'token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return SecureTokenStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    tokenStorage: ref.watch(tokenStorageProvider),
    baseUrl: ApiConfig.baseUrl,
  );
});
