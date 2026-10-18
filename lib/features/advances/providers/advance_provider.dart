import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/advance_model.dart';
import '../repositories/advance_repository.dart';

class AdvanceState {
  final int month;
  final int year;
  final List<AdvanceSalaryModel> advances;
  final bool isLoading;
  final String? errorMessage;

  AdvanceState({
    required this.month,
    required this.year,
    required this.advances,
    required this.isLoading,
    this.errorMessage,
  });

  factory AdvanceState.initial() {
    final now = DateTime.now();
    return AdvanceState(
      month: now.month,
      year: now.year,
      advances: [],
      isLoading: false,
      errorMessage: null,
    );
  }

  double get totalDisbursed => advances
      .where((a) => a.status.toUpperCase() == 'APPROVED')
      .fold(0.0, (sum, item) => sum + item.amount);

  AdvanceState copyWith({
    int? month,
    int? year,
    List<AdvanceSalaryModel>? advances,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdvanceState(
      month: month ?? this.month,
      year: year ?? this.year,
      advances: advances ?? this.advances,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AdvanceNotifier extends StateNotifier<AdvanceState> {
  final AdvanceRepository _repository;

  AdvanceNotifier(this._repository) : super(AdvanceState.initial()) {
    fetchAdvances();
  }

  Future<void> fetchAdvances() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final response = await _repository.getAdvances(
      month: state.month,
      year: state.year,
    );

    if (response.success && response.data != null) {
      state = state.copyWith(
        advances: response.data!,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message,
      );
    }
  }

  void changeMonth(int month, int year) {
    state = state.copyWith(month: month, year: year);
    fetchAdvances();
  }

  Future<bool> createAdvance(AdvanceSalaryModel model) async {
    final response = await _repository.createAdvance(model);
    if (response.success) {
      await fetchAdvances();
      return true;
    }
    return false;
  }

  Future<bool> updateStatus(int id, String status) async {
    final response = await _repository.updateAdvanceStatus(id, status);
    if (response.success) {
      await fetchAdvances();
      return true;
    }
    return false;
  }
}

final advanceRepositoryProvider = Provider<AdvanceRepository>((ref) {
  return AdvanceRepository();
});

final advanceProvider =
    StateNotifierProvider<AdvanceNotifier, AdvanceState>((ref) {
  final repository = ref.watch(advanceRepositoryProvider);
  return AdvanceNotifier(repository);
});
