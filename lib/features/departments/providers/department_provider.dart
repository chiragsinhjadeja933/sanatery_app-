import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/department_model.dart';
import '../repositories/department_repository.dart';

class DepartmentState {
  final List<DepartmentModel> departments;
  final bool isLoading;
  final String? errorMessage;

  DepartmentState({
    required this.departments,
    required this.isLoading,
    this.errorMessage,
  });

  factory DepartmentState.initial() {
    return DepartmentState(
      departments: [],
      isLoading: false,
      errorMessage: null,
    );
  }

  DepartmentState copyWith({
    List<DepartmentModel>? departments,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DepartmentState(
      departments: departments ?? this.departments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class DepartmentNotifier extends StateNotifier<DepartmentState> {
  final DepartmentRepository _repository;

  DepartmentNotifier(this._repository) : super(DepartmentState.initial()) {
    fetchDepartments();
  }

  Future<void> fetchDepartments() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final response = await _repository.getDepartments();

    if (response.success && response.data != null) {
      state = state.copyWith(
        departments: response.data!,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message,
      );
    }
  }

  Future<bool> createDepartment({
    required String name,
    required String description,
  }) async {
    final response = await _repository.createDepartment(
      name: name,
      description: description,
    );
    if (response.success) {
      await fetchDepartments();
      return true;
    }
    return false;
  }

  Future<bool> updateDepartment({
    required int id,
    required String name,
    required String description,
    required bool isActive,
  }) async {
    final response = await _repository.updateDepartment(
      id: id,
      name: name,
      description: description,
      isActive: isActive,
    );
    if (response.success) {
      await fetchDepartments();
      return true;
    }
    return false;
  }

  Future<bool> deleteDepartment(int id) async {
    final response = await _repository.deleteDepartment(id);
    if (response.success) {
      await fetchDepartments();
      return true;
    }
    return false;
  }
}

final departmentRepositoryProvider = Provider<DepartmentRepository>((ref) {
  return DepartmentRepository();
});

final departmentProvider =
    StateNotifierProvider<DepartmentNotifier, DepartmentState>((ref) {
  final repository = ref.watch(departmentRepositoryProvider);
  return DepartmentNotifier(repository);
});
