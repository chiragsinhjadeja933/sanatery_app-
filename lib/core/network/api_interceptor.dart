import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

class ApiInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Inject Bearer Authorization header if token exists
    final token = await TokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    return handler.next(response);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 Unauthorized handling: Token expiration & silent refresh
    if (err.response?.statusCode == 401) {
      final requestPath = err.requestOptions.path;
      // Do not attempt refresh if already on login or refresh endpoint
      if (!requestPath.contains('login') && !requestPath.contains('token/refresh')) {
        final refreshToken = await TokenStorage.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          try {
            final baseUrl = await TokenStorage.getBaseUrl();
            final refreshDio = Dio(
              BaseOptions(
                baseUrl: baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {'Content-Type': 'application/json'},
              ),
            );

            final refreshRes = await refreshDio.post(
              'token/refresh/',
              data: {'refresh': refreshToken},
            );

            if (refreshRes.statusCode == 200 && refreshRes.data != null) {
              final newAccess = refreshRes.data['access'] as String?;
              final newRefresh = refreshRes.data['refresh'] as String? ?? refreshToken;

              if (newAccess != null && newAccess.isNotEmpty) {
                await TokenStorage.saveTokens(
                  accessToken: newAccess,
                  refreshToken: newRefresh,
                );

                // Update original request with new access token and retry
                final options = err.requestOptions;
                options.headers['Authorization'] = 'Bearer $newAccess';

                final retryDio = Dio();
                final retryResponse = await retryDio.fetch(options);
                return handler.resolve(retryResponse);
              }
            }
          } catch (_) {
            // Refresh token has expired or is invalid
            await TokenStorage.clearAll();
          }
        } else {
          await TokenStorage.clearAll();
        }
      }
    }
    return handler.next(err);
  }
}
