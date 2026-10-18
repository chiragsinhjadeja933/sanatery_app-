import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/department_model.dart';

class DepartmentRepository {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<List<DepartmentModel>>> getDepartments({bool? isActive}) async {
    final queryParams = <String, dynamic>{};
    if (isActive != null) {
      queryParams['is_active'] = isActive.toString();
    }

    final response = await _apiClient.get<dynamic>(
      ApiEndpoints.departments,
      queryParameters: queryParams,
    );

    if (response.success && response.data != null) {
      List<dynamic> listData = [];
      if (response.data is List) {
        listData = response.data as List;
      } else if (response.data is Map<String, dynamic> && response.data['results'] != null) {
        listData = response.data['results'] as List;
      }

      final departments = listData
          .map((item) => DepartmentModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(departments);
    }

    return ApiResponse.error(response.message, errors: response.errors);
  }

  Future<ApiResponse<DepartmentModel>> createDepartment({
    required String name,
    required String description,
    bool isActive = true,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.departments,
      data: {
        'name': name,
        'description': description,
        'is_active': isActive,
      },
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(DepartmentModel.fromJson(response.data!));
    }
    return ApiResponse.error(response.message, errors: response.errors);
  }

  Future<ApiResponse<DepartmentModel>> updateDepartment({
    required int id,
    required String name,
    required String description,
    required bool isActive,
  }) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '${ApiEndpoints.departments}$id/',
      data: {
        'name': name,
        'description': description,
        'is_active': isActive,
      },
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(DepartmentModel.fromJson(response.data!));
    }
    return ApiResponse.error(response.message, errors: response.errors);
  }

  Future<ApiResponse<void>> deleteDepartment(int id) async {
    final response = await _apiClient.delete('${ApiEndpoints.departments}$id/');
    return response;
  }
}
