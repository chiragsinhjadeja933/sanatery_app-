import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/staff_model.dart';
import '../repositories/staff_repository.dart';

class StaffFilterState {
  final String search;
  final int? departmentId;
  final int? shiftId;
  final String? status;

  StaffFilterState({
    this.search = '',
    this.departmentId,
    this.shiftId,
    this.status,
  });

  StaffFilterState copyWith({
    String? search,
    int? departmentId,
    bool clearDepartment = false,
    int? shiftId,
    bool clearShift = false,
    String? status,
    bool clearStatus = false,
  }) {
    return StaffFilterState(
      search: search ?? this.search,
      departmentId: clearDepartment ? null : (departmentId ?? this.departmentId),
      shiftId: clearShift ? null : (shiftId ?? this.shiftId),
      status: clearStatus ? null : (status ?? this.status),
    );
  }
}

class StaffState {
  final List<StaffModel> staffList;
  final StaffFilterState filter;
  final bool isLoading;
  final String? errorMessage;

  StaffState({
    required this.staffList,
    required this.filter,
    required this.isLoading,
    this.errorMessage,
  });

  factory StaffState.initial() {
    return StaffState(
      staffList: [],
      filter: StaffFilterState(),
      isLoading: false,
      errorMessage: null,
    );
  }

  StaffState copyWith({
    List<StaffModel>? staffList,
    StaffFilterState? filter,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StaffState(
      staffList: staffList ?? this.staffList,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class StaffNotifier extends StateNotifier<StaffState> {
  final StaffRepository _repository;

  StaffNotifier(this._repository) : super(StaffState.initial()) {
    fetchStaffList();
  }

  Future<void> fetchStaffList() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final response = await _repository.getStaffList(
      search: state.filter.search,
      departmentId: state.filter.departmentId,
      shiftId: state.filter.shiftId,
      status: state.filter.status,
    );

    if (response.success && response.data != null) {
      state = state.copyWith(
        staffList: response.data!,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message,
      );
    }
  }

  void updateSearch(String query) {
    state = state.copyWith(
      filter: state.filter.copyWith(search: query),
    );
    fetchStaffList();
  }

  void updateDepartmentFilter(int? deptId) {
    state = state.copyWith(
      filter: state.filter.copyWith(
        departmentId: deptId,
        clearDepartment: deptId == null,
      ),
    );
    fetchStaffList();
  }

  void updateStatusFilter(String? status) {
    state = state.copyWith(
      filter: state.filter.copyWith(
        status: status,
        clearStatus: status == null,
      ),
    );
    fetchStaffList();
  }

  Future<bool> createStaff(StaffModel staff) async {
    final response = await _repository.createStaff(staff);
    if (response.success) {
      await fetchStaffList();
      return true;
    }
    return false;
  }

  Future<bool> updateStaff(int id, Map<String, dynamic> data) async {
    final response = await _repository.updateStaff(id, data);
    if (response.success) {
      await fetchStaffList();
      return true;
    }
    return false;
  }

  Future<bool> toggleStaffStatus(StaffModel staff) async {
    final response = staff.isActive
        ? await _repository.deactivateStaff(staff.id)
        : await _repository.activateStaff(staff.id);
    if (response.success) {
      await fetchStaffList();
      return true;
    }
    return false;
  }
}

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  return StaffRepository();
});

final staffProvider = StateNotifierProvider<StaffNotifier, StaffState>((ref) {
  final repository = ref.watch(staffRepositoryProvider);
  return StaffNotifier(repository);
});
