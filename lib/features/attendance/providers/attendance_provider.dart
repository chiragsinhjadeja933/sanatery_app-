import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../models/attendance_model.dart';
import '../repositories/attendance_repository.dart';

class AttendanceState {
  final DateTime selectedDate;
  final int? selectedDepartmentId;
  final List<AttendanceRosterItem> roster;
  final AttendanceSummaryModel? summary;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final bool hasUnsavedChanges;

  AttendanceState({
    required this.selectedDate,
    this.selectedDepartmentId,
    required this.roster,
    this.summary,
    required this.isLoading,
    required this.isSaving,
    this.errorMessage,
    required this.hasUnsavedChanges,
  });

  factory AttendanceState.initial() {
    return AttendanceState(
      selectedDate: DateTime.now(),
      selectedDepartmentId: null,
      roster: [],
      summary: null,
      isLoading: false,
      isSaving: false,
      errorMessage: null,
      hasUnsavedChanges: false,
    );
  }

  AttendanceState copyWith({
    DateTime? selectedDate,
    int? selectedDepartmentId,
    bool clearDepartment = false,
    List<AttendanceRosterItem>? roster,
    AttendanceSummaryModel? summary,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
    bool? hasUnsavedChanges,
  }) {
    return AttendanceState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedDepartmentId: clearDepartment ? null : (selectedDepartmentId ?? this.selectedDepartmentId),
      roster: roster ?? this.roster,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final AttendanceRepository _repository;

  AttendanceNotifier(this._repository) : super(AttendanceState.initial()) {
    loadRosterAndSummary();
  }

  Future<void> loadRosterAndSummary() async {
    state = state.copyWith(isLoading: true, clearError: true, hasUnsavedChanges: false);
    final dateStr = Formatters.formatApiDate(state.selectedDate);

    final rosterFuture = _repository.getDailyRoster(
      date: dateStr,
      departmentId: state.selectedDepartmentId,
    );
    final summaryFuture = _repository.getAttendanceSummary(dateStr);

    final results = await Future.wait([rosterFuture, summaryFuture]);
    final rosterRes = results[0] as dynamic;
    final summaryRes = results[1] as dynamic;

    if (rosterRes.success) {
      List<AttendanceRosterItem> rosterList = List.from(rosterRes.data as List<AttendanceRosterItem>);
      bool draftRestored = false;
      try {
        final prefs = await SharedPreferences.getInstance();
        final draftStr = prefs.getString('attendance_draft_$dateStr');
        if (draftStr != null && draftStr.isNotEmpty) {
          final List<dynamic> draftJson = jsonDecode(draftStr);
          final draftMap = {
            for (var d in draftJson) (d['staff_id'] as int): d
          };
          rosterList = rosterList.map((item) {
            if (draftMap.containsKey(item.staffId)) {
              final d = draftMap[item.staffId];
              draftRestored = true;
              return item.copyWith(
                status: d['status'] as String?,
                overtimeHours: double.tryParse(d['overtime_hours']?.toString() ?? '0') ?? item.overtimeHours,
                remarks: d['remarks'] as String? ?? item.remarks,
                isMarked: true,
                isDirty: true,
              );
            }
            return item;
          }).toList();
        }
      } catch (_) {}

      state = state.copyWith(
        roster: rosterList,
        summary: summaryRes.success ? summaryRes.data as AttendanceSummaryModel : state.summary,
        isLoading: false,
        hasUnsavedChanges: draftRestored ? true : state.hasUnsavedChanges,
        errorMessage: draftRestored ? 'Restored unsaved offline attendance draft.' : null,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: rosterRes.message,
      );
    }
  }

  void changeDate(DateTime newDate) {
    state = state.copyWith(selectedDate: newDate);
    loadRosterAndSummary();
  }

  void changeDepartment(int? deptId) {
    state = state.copyWith(
      selectedDepartmentId: deptId,
      clearDepartment: deptId == null,
    );
    loadRosterAndSummary();
  }

  void setStaffStatus(int staffId, String status) {
    final updatedList = state.roster.map((item) {
      if (item.staffId == staffId) {
        return item.copyWith(
          status: status,
          isMarked: true,
          isDirty: true,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(
      roster: updatedList,
      hasUnsavedChanges: true,
    );
  }

  void addOvertimeHours(int staffId, double hours) {
    final updatedList = state.roster.map((item) {
      if (item.staffId == staffId) {
        final newOt = (item.overtimeHours + hours).clamp(0.0, 16.0);
        return item.copyWith(
          overtimeHours: newOt,
          isDirty: true,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(
      roster: updatedList,
      hasUnsavedChanges: true,
    );
  }

  void setRemarks(int staffId, String remarks) {
    final updatedList = state.roster.map((item) {
      if (item.staffId == staffId) {
        return item.copyWith(
          remarks: remarks,
          isDirty: true,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(
      roster: updatedList,
      hasUnsavedChanges: true,
    );
  }

  void markAllPresent() {
    final updatedList = state.roster.map((item) {
      return item.copyWith(
        status: 'PRESENT',
        isMarked: true,
        isDirty: true,
      );
    }).toList();

    state = state.copyWith(
      roster: updatedList,
      hasUnsavedChanges: true,
    );
  }

  Future<bool> saveAttendance() async {
    final markedItems = state.roster.where((e) => e.status != null).toList();
    if (markedItems.isEmpty) return true;

    state = state.copyWith(isSaving: true, clearError: true);
    final dateStr = Formatters.formatApiDate(state.selectedDate);

    final response = await _repository.submitBulkAttendance(
      date: dateStr,
      items: markedItems,
    );

    state = state.copyWith(isSaving: false);

    if (response.success) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('attendance_draft_$dateStr');
      } catch (_) {}
      await loadRosterAndSummary();
      return true;
    } else {
      try {
        final prefs = await SharedPreferences.getInstance();
        final draftJson = jsonEncode(markedItems.map((e) => e.toJson()).toList());
        await prefs.setString('attendance_draft_$dateStr', draftJson);
      } catch (_) {}
      state = state.copyWith(errorMessage: '${response.message} (Draft saved offline)');
      return false;
    }
  }
}

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository();
});

final attendanceProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  final repository = ref.watch(attendanceRepositoryProvider);
  return AttendanceNotifier(repository);
});
