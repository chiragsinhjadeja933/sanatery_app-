import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/shift_model.dart';

class ShiftRepository {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<List<ShiftModel>>> getShifts({bool? isActive}) async {
    final queryParams = <String, dynamic>{};
    if (isActive != null) {
      queryParams['is_active'] = isActive.toString();
    }

    final response = await _apiClient.get<dynamic>(
      ApiEndpoints.shifts,
      queryParameters: queryParams,
    );

    if (response.success && response.data != null) {
      List<dynamic> listData = [];
      if (response.data is List) {
        listData = response.data as List;
      } else if (response.data is Map<String, dynamic> && response.data['results'] != null) {
        listData = response.data['results'] as List;
      }

      final shifts = listData
          .map((item) => ShiftModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(shifts);
    }

    return ApiResponse.error(response.message, errors: response.errors);
  }

  Future<ApiResponse<ShiftModel>> createShift({
    required String name,
    required String startTime,
    required String endTime,
    bool isActive = true,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.shifts,
      data: {
        'name': name,
        'start_time': startTime,
        'end_time': endTime,
        'is_active': isActive,
      },
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(ShiftModel.fromJson(response.data!));
    }
    return ApiResponse.error(response.message, errors: response.errors);
  }

  Future<ApiResponse<ShiftModel>> updateShift({
    required int id,
    required String name,
    required String startTime,
    required String endTime,
    required bool isActive,
  }) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '${ApiEndpoints.shifts}$id/',
      data: {
        'name': name,
        'start_time': startTime,
        'end_time': endTime,
        'is_active': isActive,
      },
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(ShiftModel.fromJson(response.data!));
    }
    return ApiResponse.error(response.message, errors: response.errors);
  }

  Future<ApiResponse<void>> deleteShift(int id) async {
    final response = await _apiClient.delete('${ApiEndpoints.shifts}$id/');
    return response;
  }
}
