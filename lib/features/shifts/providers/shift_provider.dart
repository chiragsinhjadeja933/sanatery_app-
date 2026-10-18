import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shift_model.dart';
import '../repositories/shift_repository.dart';

class ShiftState {
  final List<ShiftModel> shifts;
  final bool isLoading;
  final String? errorMessage;

  ShiftState({
    required this.shifts,
    required this.isLoading,
    this.errorMessage,
  });

  factory ShiftState.initial() {
    return ShiftState(
      shifts: [],
      isLoading: false,
      errorMessage: null,
    );
  }

  ShiftState copyWith({
    List<ShiftModel>? shifts,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ShiftState(
      shifts: shifts ?? this.shifts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ShiftNotifier extends StateNotifier<ShiftState> {
  final ShiftRepository _repository;

  ShiftNotifier(this._repository) : super(ShiftState.initial()) {
    fetchShifts();
  }

  Future<void> fetchShifts() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final response = await _repository.getShifts();

    if (response.success && response.data != null) {
      state = state.copyWith(
        shifts: response.data!,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message,
      );
    }
  }

  Future<bool> createShift({
    required String name,
    required String startTime,
    required String endTime,
  }) async {
    final response = await _repository.createShift(
      name: name,
      startTime: startTime,
      endTime: endTime,
    );
    if (response.success) {
      await fetchShifts();
      return true;
    }
    return false;
  }

  Future<bool> updateShift({
    required int id,
    required String name,
    required String startTime,
    required String endTime,
    required bool isActive,
  }) async {
    final response = await _repository.updateShift(
      id: id,
      name: name,
      startTime: startTime,
      endTime: endTime,
      isActive: isActive,
    );
    if (response.success) {
      await fetchShifts();
      return true;
    }
    return false;
  }

  Future<bool> deleteShift(int id) async {
    final response = await _repository.deleteShift(id);
    if (response.success) {
      await fetchShifts();
      return true;
    }
    return false;
  }
}

final shiftRepositoryProvider = Provider<ShiftRepository>((ref) {
  return ShiftRepository();
});

final shiftProvider =
    StateNotifierProvider<ShiftNotifier, ShiftState>((ref) {
  final repository = ref.watch(shiftRepositoryProvider);
  return ShiftNotifier(repository);
});
