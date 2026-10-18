import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_kpi_model.dart';
import '../repositories/dashboard_repository.dart';

class DashboardState {
  final DashboardKpiModel? kpis;
  final bool isLoading;
  final String? errorMessage;

  DashboardState({
    this.kpis,
    required this.isLoading,
    this.errorMessage,
  });

  factory DashboardState.initial() {
    return DashboardState(
      kpis: null,
      isLoading: false,
      errorMessage: null,
    );
  }

  DashboardState copyWith({
    DashboardKpiModel? kpis,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DashboardState(
      kpis: kpis ?? this.kpis,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;

  DashboardNotifier(this._repository) : super(DashboardState.initial()) {
    fetchKpis();
  }

  Future<void> fetchKpis() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final response = await _repository.getKpis();

    if (response.success && response.data != null) {
      state = state.copyWith(
        kpis: response.data,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message,
      );
    }
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return DashboardNotifier(repository);
});
