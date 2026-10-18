import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payroll_model.dart';
import '../repositories/payroll_repository.dart';

class PayrollState {
  final int month;
  final int year;
  final int? departmentId;
  final List<PayrollModel> payrolls;
  final PayrollSummaryModel? summary;
  final bool isLoading;
  final bool isGenerating;
  final String? errorMessage;

  PayrollState({
    required this.month,
    required this.year,
    this.departmentId,
    required this.payrolls,
    this.summary,
    required this.isLoading,
    required this.isGenerating,
    this.errorMessage,
  });

  factory PayrollState.initial() {
    final now = DateTime.now();
    return PayrollState(
      month: now.month,
      year: now.year,
      departmentId: null,
      payrolls: [],
      summary: null,
      isLoading: false,
      isGenerating: false,
      errorMessage: null,
    );
  }

  PayrollState copyWith({
    int? month,
    int? year,
    int? departmentId,
    bool clearDepartment = false,
    List<PayrollModel>? payrolls,
    PayrollSummaryModel? summary,
    bool? isLoading,
    bool? isGenerating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PayrollState(
      month: month ?? this.month,
      year: year ?? this.year,
      departmentId: clearDepartment ? null : (departmentId ?? this.departmentId),
      payrolls: payrolls ?? this.payrolls,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class PayrollNotifier extends StateNotifier<PayrollState> {
  final PayrollRepository _repository;

  PayrollNotifier(this._repository) : super(PayrollState.initial()) {
    loadPayrollData();
  }

  Future<void> loadPayrollData() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final payrollsFuture = _repository.getPayrolls(
      month: state.month,
      year: state.year,
      departmentId: state.departmentId,
    );
    final summaryFuture = _repository.getPayrollSummary(
      month: state.month,
      year: state.year,
    );

    final results = await Future.wait([payrollsFuture, summaryFuture]);
    final payrollRes = results[0] as dynamic;
    final summaryRes = results[1] as dynamic;

    if (payrollRes.success) {
      state = state.copyWith(
        payrolls: payrollRes.data as List<PayrollModel>,
        summary: summaryRes.success ? summaryRes.data as PayrollSummaryModel : state.summary,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: payrollRes.message,
      );
    }
  }

  void changeMonth(int month, int year) {
    state = state.copyWith(month: month, year: year);
    loadPayrollData();
  }

  void changeDepartment(int? deptId) {
    state = state.copyWith(
      departmentId: deptId,
      clearDepartment: deptId == null,
    );
    loadPayrollData();
  }

  Future<bool> generatePayroll() async {
    state = state.copyWith(isGenerating: true, clearError: true);
    final response = await _repository.generatePayroll(
      month: state.month,
      year: state.year,
      departmentId: state.departmentId,
    );

    state = state.copyWith(isGenerating: false);

    if (response.success) {
      await loadPayrollData();
      return true;
    } else {
      state = state.copyWith(errorMessage: response.message);
      return false;
    }
  }

  Future<bool> finalizeSinglePayroll(int id) async {
    final response = await _repository.finalizePayroll(id);
    if (response.success) {
      await loadPayrollData();
      return true;
    }
    return false;
  }

  Future<bool> finalizeAllPayrolls() async {
    state = state.copyWith(isGenerating: true);
    final response = await _repository.finalizeAllPayrolls(
      month: state.month,
      year: state.year,
      departmentId: state.departmentId,
    );
    state = state.copyWith(isGenerating: false);

    if (response.success) {
      await loadPayrollData();
      return true;
    }
    return false;
  }
}

final payrollRepositoryProvider = Provider<PayrollRepository>((ref) {
  return PayrollRepository();
});

final payrollProvider =
    StateNotifierProvider<PayrollNotifier, PayrollState>((ref) {
  final repository = ref.watch(payrollRepositoryProvider);
  return PayrollNotifier(repository);
});
