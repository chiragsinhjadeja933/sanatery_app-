import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/token_storage.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { initial, unauthenticated, authenticated, loading }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final String baseUrl;

  AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    required this.baseUrl,
  });

  factory AuthState.initial() {
    return AuthState(
      status: AuthStatus.initial,
      user: null,
      errorMessage: null,
      baseUrl: '',
    );
  }

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    bool clearError = false,
    String? baseUrl,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      baseUrl: baseUrl ?? this.baseUrl,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState.initial()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    final baseUrl = await TokenStorage.getBaseUrl();
    final hasToken = await TokenStorage.hasToken();

    if (!hasToken) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        baseUrl: baseUrl,
      );
      return;
    }

    final userJson = await TokenStorage.getUser();
    if (userJson != null) {
      final user = UserModel.fromJson(userJson);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        baseUrl: baseUrl,
      );
    } else {
      // Fetch fresh profile
      final response = await _authRepository.getCurrentUser();
      if (response.success && response.data != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.data,
          baseUrl: baseUrl,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          baseUrl: baseUrl,
        );
      }
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    final response = await _authRepository.login(
      username: username,
      password: password,
    );

    if (response.success && response.data != null) {
      final baseUrl = await TokenStorage.getBaseUrl();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.data,
        baseUrl: baseUrl,
      );
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: response.message,
      );
      return false;
    }
  }

  Future<void> updateBaseUrl(String newUrl) async {
    await TokenStorage.saveBaseUrl(newUrl);
    state = state.copyWith(baseUrl: newUrl);
  }

  Future<void> logout() async {
    await _authRepository.logout();
    final baseUrl = await TokenStorage.getBaseUrl();
    state = AuthState(
      status: AuthStatus.unauthenticated,
      user: null,
      errorMessage: null,
      baseUrl: baseUrl,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
