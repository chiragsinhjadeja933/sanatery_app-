import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import 'api_interceptor.dart';
import 'api_response.dart';

class ApiClient {
  late final Dio _dio;
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    _dio.interceptors.add(ApiInterceptor());
  }

  Dio get rawDio => _dio;

  Future<void> updateBaseUrl() async {
    final baseUrl = await TokenStorage.getBaseUrl();
    _dio.options.baseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    await updateBaseUrl();
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _processResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _processDioError<T>(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred: $e');
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    await updateBaseUrl();
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters);
      return _processResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _processDioError<T>(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred: $e');
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    await updateBaseUrl();
    try {
      final response = await _dio.put(path, data: data, queryParameters: queryParameters);
      return _processResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _processDioError<T>(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred: $e');
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    await updateBaseUrl();
    try {
      final response = await _dio.patch(path, data: data, queryParameters: queryParameters);
      return _processResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _processDioError<T>(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred: $e');
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    await updateBaseUrl();
    try {
      final response = await _dio.delete(path, queryParameters: queryParameters);
      return _processResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _processDioError<T>(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred: $e');
    }
  }

  ApiResponse<T> _processResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) {
      // If backend returned StandardJSONRenderer wrapper {success, message, data}
      if (data.containsKey('success') || data.containsKey('data')) {
        return ApiResponse.fromJson(data, fromJson);
      }
      // If direct payload
      return ApiResponse.success(
        fromJson != null ? fromJson(data) : data as T,
      );
    } else if (data is List) {
      return ApiResponse.success(
        fromJson != null ? fromJson(data) : data as T,
      );
    }
    return ApiResponse.success(data as T);
  }

  ApiResponse<T> _processDioError<T>(DioException e) {
    String errorMsg = 'Network request failed';
    dynamic errorDetails;

    if (e.response != null && e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        if (data['message'] != null) {
          errorMsg = data['message'].toString();
        } else if (data['detail'] != null) {
          errorMsg = data['detail'].toString();
        }
        errorDetails = data['errors'] ?? data;
      } else if (data is String) {
        if (data.contains('<!DOCTYPE html>') || data.contains('<html')) {
          final statusCode = e.response?.statusCode;
          if (statusCode == 404) {
            errorMsg = 'API endpoint not found (404). Please check backend routes.';
          } else if (statusCode == 500) {
            errorMsg = 'Internal server error (500). Check Django logs.';
          } else {
            errorMsg = 'Server responded with status $statusCode.';
          }
        } else {
          errorMsg = data;
        }
      } else {
        errorMsg = data.toString();
      }
    } else {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMsg = 'Connection timed out. Check your server status or network.';
          break;
        case DioExceptionType.connectionError:
          errorMsg = 'Cannot connect to server. Ensure Django backend is running at the configured URL.';
          break;
        default:
          errorMsg = e.message ?? 'An unexpected network error occurred';
      }
    }

    return ApiResponse.error(errorMsg, errors: errorDetails);
  }
}
