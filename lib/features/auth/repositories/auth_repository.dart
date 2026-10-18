import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/storage/token_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<UserModel>> login({
    required String username,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {
        'username': username,
        'password': password,
      },
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      final accessToken = data['access'] as String?;
      final refreshToken = data['refresh'] as String?;
      final userJson = data['user'] as Map<String, dynamic>?;

      if (accessToken != null && refreshToken != null) {
        await TokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }

      if (userJson != null) {
        await TokenStorage.saveUser(userJson);
        final user = UserModel.fromJson(userJson);
        return ApiResponse.success(user, message: response.message);
      }
    }

    return ApiResponse.error(
      response.message.isNotEmpty ? response.message : 'Invalid credentials',
      errors: response.errors,
    );
  }

  Future<ApiResponse<UserModel>> getCurrentUser() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.currentUser,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      final user = UserModel.fromJson(response.data!);
      await TokenStorage.saveUser(user.toJson());
      return ApiResponse.success(user);
    }

    return ApiResponse.error(response.message, errors: response.errors);
  }

  Future<void> logout() async {
    await TokenStorage.clearAll();
  }
}
