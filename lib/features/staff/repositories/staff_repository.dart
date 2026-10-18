import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/staff_model.dart';

class StaffRepository {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<List<StaffModel>>> getStaffList({
    String? search,
    int? departmentId,
    int? shiftId,
    String? status,
    int? page,
    int pageSize = 100,
  }) async {
    final queryParams = <String, dynamic>{
      'page_size': pageSize,
    };
    if (page != null) queryParams['page'] = page;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (departmentId != null) queryParams['department'] = departmentId;
    if (shiftId != null) queryParams['shift'] = shiftId;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    final response = await _apiClient.get<dynamic>(
      ApiEndpoints.staff,
      queryParameters: queryParams,
    );

    if (response.success && response.data != null) {
      List<dynamic> listData = [];
      if (response.data is List) {
        listData = response.data as List;
      } else if (response.data is Map<String, dynamic> && response.data['results'] != null) {
        listData = response.data['results'] as List;
      }

      final staffList = listData
          .map((item) => StaffModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(staffList);
    }

    return ApiResponse.error(response.message, errors: response.errors);
  }

  Future<ApiResponse<StaffModel>> getStaffDetail(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.staffDetail(id),
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(StaffModel.fromJson(response.data!));
    }
    return ApiResponse.error(response.message, errors: response.errors);
  }

  Future<ApiResponse<StaffModel>> createStaff(StaffModel staff) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.staff,
      data: staff.toJson(),
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(StaffModel.fromJson(response.data!));
    }
    return ApiResponse.error(response.message, errors: response.errors);
  }

  Future<ApiResponse<StaffModel>> updateStaff(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.staffDetail(id),
      data: data,
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(StaffModel.fromJson(response.data!));
    }
    return ApiResponse.error(response.message, errors: response.errors);
  }

  Future<ApiResponse<StaffModel>> activateStaff(int id) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.activateStaff(id),
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(StaffModel.fromJson(response.data!));
    }
    return ApiResponse.error(response.message, errors: response.errors);
  }

  Future<ApiResponse<StaffModel>> deactivateStaff(int id) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.deactivateStaff(id),
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(StaffModel.fromJson(response.data!));
    }
    return ApiResponse.error(response.message, errors: response.errors);
  }
}
