import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/user_model.dart';

class UserRepository {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<List<UserModel>>> getUsers() async {
    final response = await _apiClient.get<dynamic>(
      ApiEndpoints.users,
    );

    if (response.success && response.data != null) {
      List<dynamic> listData = [];
      if (response.data is List) {
        listData = response.data as List;
      } else if (response.data is Map<String, dynamic> && response.data['results'] != null) {
        listData = response.data['results'] as List;
      }

      final users = listData
          .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(users);
    }

    return ApiResponse.error(response.message, errors: response.errors);
  }

  Future<ApiResponse<UserModel>> createUser({
    required String username,
    required String password,
    required String role,
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.users,
      data: {
        'username': username,
        'password': password,
        'role': role,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'email': email ?? '',
        'is_active': true,
      },
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(UserModel.fromJson(response.data!));
    }
    return ApiResponse.error(response.message, errors: response.errors);
  }

  Future<ApiResponse<UserModel>> updateUser({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '${ApiEndpoints.users}$id/',
      data: data,
    );

    if (response.success && response.data != null) {
      return ApiResponse.success(UserModel.fromJson(response.data!));
    }
    return ApiResponse.error(response.message, errors: response.errors);
  }

  Future<ApiResponse<void>> deleteUser(int id) async {
    final response = await _apiClient.delete('${ApiEndpoints.users}$id/');
    return response;
  }
}
