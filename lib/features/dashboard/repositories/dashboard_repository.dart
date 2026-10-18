import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/dashboard_kpi_model.dart';

class DashboardRepository {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<DashboardKpiModel>> getKpis() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.dashboardKpi,
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(DashboardKpiModel.fromJson(response.data!));
    }

    return ApiResponse.error(response.message, errors: response.errors);
  }
}
