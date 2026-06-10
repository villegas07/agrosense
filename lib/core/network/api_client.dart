import 'dart:async';
import 'package:dio/dio.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    required String baseUrl,
  }) : _tokenStorage = tokenStorage {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(
      _AuthInterceptor(tokenStorage: _tokenStorage, dio: _dio),
    );
  }

  late final Dio _dio;
  final TokenStorage _tokenStorage;

  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor({required this.tokenStorage, required this.dio});

  final TokenStorage tokenStorage;
  final Dio dio;

  bool _isRefreshing = false;
  Completer<String>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final is401 = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['_retry'] == true;

    if (!is401 || alreadyRetried) {
      return handler.next(err);
    }

    try {
      final newToken = await _acquireNewAccessToken();
      final opts = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newToken'
        ..extra['_retry'] = true;
      final retryResponse = await dio.fetch(opts);
      return handler.resolve(retryResponse);
    } catch (_) {
      await tokenStorage.clearTokens();
      return handler.next(err);
    }
  }

  Future<String> _acquireNewAccessToken() async {
    if (_isRefreshing) {
      return _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<String>();

    try {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken == null) throw Exception('No refresh token stored');

      // Separate Dio instance to avoid recursion through this interceptor
      final plainDio = Dio(BaseOptions(
        baseUrl: dio.options.baseUrl,
        headers: {'Content-Type': 'application/json'},
      ));
      final resp = await plainDio.post(
        '/api/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final newAccess = resp.data['access_token'] as String;
      final newRefresh = resp.data['refresh_token'] as String;
      await tokenStorage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );

      _refreshCompleter!.complete(newAccess);
      return newAccess;
    } catch (e) {
      _refreshCompleter!.completeError(e);
      rethrow;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }
}
