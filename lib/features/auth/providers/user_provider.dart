import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserState {
  final List<UserModel> users;
  final bool isLoading;
  final String? errorMessage;

  UserState({
    required this.users,
    required this.isLoading,
    this.errorMessage,
  });

  factory UserState.initial() {
    return UserState(
      users: [],
      isLoading: false,
      errorMessage: null,
    );
  }

  UserState copyWith({
    List<UserModel>? users,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UserState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final UserRepository _repository;

  UserNotifier(this._repository) : super(UserState.initial()) {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final response = await _repository.getUsers();

    if (response.success && response.data != null) {
      state = state.copyWith(
        users: response.data!,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message,
      );
    }
  }

  Future<bool> createUser({
    required String username,
    required String password,
    required String role,
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
  }) async {
    final response = await _repository.createUser(
      username: username,
      password: password,
      role: role,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
    );
    if (response.success) {
      await fetchUsers();
      return true;
    }
    return false;
  }

  Future<bool> updateUser(int id, Map<String, dynamic> data) async {
    final response = await _repository.updateUser(id: id, data: data);
    if (response.success) {
      await fetchUsers();
      return true;
    }
    return false;
  }

  Future<bool> deleteUser(int id) async {
    final response = await _repository.deleteUser(id);
    if (response.success) {
      await fetchUsers();
      return true;
    }
    return false;
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserNotifier(repository);
});
