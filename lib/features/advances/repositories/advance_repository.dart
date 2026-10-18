import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/advance_model.dart';

class AdvanceRepository {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<List<AdvanceSalaryModel>>> getAdvances({
    int? month,
    int? year,
    int? staffId,
    String? status,
    int pageSize = 100,
  }) async {
    final queryParams = <String, dynamic>{
      'page_size': pageSize,
    };
    if (month != null) queryParams['month'] = month;
    if (year != null) queryParams['year'] = year;
    if (staffId != null) queryParams['staff'] = staffId;
    if (status != null) queryParams['status'] = status;

    final response = await _apiClient.get<dynamic>(
      ApiEndpoints.advances,
      queryParameters: queryParams,
    );

    if (response.success && response.data != null) {
      List<dynamic> listData = [];
      if (response.data is List) {
        listData = response.data as List;
      } else if (response.data is Map<String, dynamic> && response.data['results'] != null) {
        listData = response.data['results'] as List;
      }

      final advances = listData
          .map((item) => AdvanceSalaryModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(advances);
    }

    return ApiResponse.error(response.message, errors: response.errors);
  }

  Future<ApiResponse<AdvanceSalaryModel>> createAdvance(AdvanceSalaryModel model) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.advances,
      data: model.toJson(),
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(AdvanceSalaryModel.fromJson(response.data!));
    }
    return ApiResponse.error(response.message, errors: response.errors);
  }

  Future<ApiResponse<AdvanceSalaryModel>> updateAdvanceStatus(int id, String status) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.advanceDetail(id),
      data: {'status': status},
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(AdvanceSalaryModel.fromJson(response.data!));
    }
    return ApiResponse.error(response.message, errors: response.errors);
  }
}
