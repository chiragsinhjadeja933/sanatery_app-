import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/payroll_model.dart';

class PayrollRepository {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<List<PayrollModel>>> getPayrolls({
    required int month,
    required int year,
    int? departmentId,
    String? status,
    int pageSize = 100,
  }) async {
    final queryParams = <String, dynamic>{
      'month': month,
      'year': year,
      'page_size': pageSize,
    };
    if (departmentId != null) queryParams['department'] = departmentId;
    if (status != null) queryParams['status'] = status;

    final response = await _apiClient.get<dynamic>(
      ApiEndpoints.payroll,
      queryParameters: queryParams,
    );

    if (response.success && response.data != null) {
      List<dynamic> listData = [];
      if (response.data is List) {
        listData = response.data as List;
      } else if (response.data is Map<String, dynamic> && response.data['results'] != null) {
        listData = response.data['results'] as List;
      }

      final payrolls = listData
          .map((item) => PayrollModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(payrolls);
    }

    return ApiResponse.error(response.message, errors: response.errors);
  }

  Future<ApiResponse<PayrollSummaryModel>> getPayrollSummary({
    required int month,
    required int year,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.payrollSummary,
      queryParameters: {'month': month, 'year': year},
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(PayrollSummaryModel.fromJson(response.data!));
    }

    return ApiResponse.error(response.message, errors: response.errors);
  }

  Future<ApiResponse<dynamic>> generatePayroll({
    required int month,
    required int year,
    int? departmentId,
  }) async {
    final payload = <String, dynamic>{'month': month, 'year': year};
    if (departmentId != null) payload['department_id'] = departmentId;

    final response = await _apiClient.post<dynamic>(
      ApiEndpoints.generatePayroll,
      data: payload,
    );

    return response;
  }

  Future<ApiResponse<dynamic>> finalizePayroll(int id) async {
    final response = await _apiClient.post<dynamic>(
      ApiEndpoints.finalizePayroll(id),
    );
    return response;
  }

  Future<ApiResponse<dynamic>> finalizeAllPayrolls({
    required int month,
    required int year,
    int? departmentId,
  }) async {
    final payload = <String, dynamic>{'month': month, 'year': year};
    if (departmentId != null) payload['department_id'] = departmentId;

    final response = await _apiClient.post<dynamic>(
      ApiEndpoints.finalizeAllPayroll,
      data: payload,
    );

    return response;
  }
}
