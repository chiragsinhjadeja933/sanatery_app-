import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/attendance_model.dart';

class AttendanceRepository {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<List<AttendanceRosterItem>>> getDailyRoster({
    required String date,
    int? departmentId,
  }) async {
    final queryParams = <String, dynamic>{'date': date};
    if (departmentId != null) queryParams['department'] = departmentId;

    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.dailyRoster,
      queryParameters: queryParams,
    );

    if (response.success && response.data != null) {
      final rosterList = (response.data!['roster'] as List? ?? [])
          .map((item) => AttendanceRosterItem.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(rosterList);
    }

    return ApiResponse.error(response.message, errors: response.errors);
  }

  Future<ApiResponse<AttendanceSummaryModel>> getAttendanceSummary(String date) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.attendanceSummary,
      queryParameters: {'date': date},
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(AttendanceSummaryModel.fromJson(response.data!));
    }

    return ApiResponse.error(response.message, errors: response.errors);
  }

  Future<ApiResponse<dynamic>> submitBulkAttendance({
    required String date,
    required List<AttendanceRosterItem> items,
  }) async {
    final payload = {
      'date': date,
      'attendances': items.map((e) => e.toSubmissionJson()).toList(),
    };

    final response = await _apiClient.post<dynamic>(
      ApiEndpoints.bulkMarkAttendance,
      data: payload,
    );

    return response;
  }

  Future<ApiResponse<List<AttendanceRecordModel>>> getAttendanceRecords({
    int? staffId,
    int? month,
    int? year,
    String? date,
    int? departmentId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (staffId != null) queryParams['staff'] = staffId;
    if (month != null) queryParams['month'] = month;
    if (year != null) queryParams['year'] = year;
    if (date != null) queryParams['date'] = date;
    if (departmentId != null) queryParams['department'] = departmentId;

    final response = await _apiClient.get<dynamic>(
      ApiEndpoints.attendance,
      queryParameters: queryParams,
    );

    if (response.success && response.data != null) {
      List<dynamic> listData = [];
      if (response.data is List) {
        listData = response.data as List;
      } else if (response.data is Map<String, dynamic> && response.data['results'] != null) {
        listData = response.data['results'] as List;
      }

      final records = listData
          .map((item) => AttendanceRecordModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(records);
    }

    return ApiResponse.error(response.message, errors: response.errors);
  }
}
