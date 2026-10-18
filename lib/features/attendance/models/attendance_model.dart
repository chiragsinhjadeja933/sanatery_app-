class AttendanceRosterItem {
  final int staffId;
  final String employeeCode;
  final String fullName;
  final int departmentId;
  final String departmentName;
  final String shiftName;
  final double overtimeRate;
  bool isMarked;
  int? attendanceId;
  String? status; // 'PRESENT', 'HALF_DAY', 'ABSENT', 'LEAVE'
  double overtimeHours;
  String remarks;
  bool isDirty; // Locally modified

  AttendanceRosterItem({
    required this.staffId,
    required this.employeeCode,
    required this.fullName,
    required this.departmentId,
    required this.departmentName,
    required this.shiftName,
    required this.overtimeRate,
    required this.isMarked,
    this.attendanceId,
    this.status,
    required this.overtimeHours,
    required this.remarks,
    this.isDirty = false,
  });

  factory AttendanceRosterItem.fromJson(Map<String, dynamic> json) {
    return AttendanceRosterItem(
      staffId: json['staff_id'] as int? ?? 0,
      employeeCode: json['employee_code'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      departmentId: json['department_id'] as int? ?? 0,
      departmentName: json['department_name'] as String? ?? 'General',
      shiftName: json['shift_name'] as String? ?? 'None',
      overtimeRate: double.tryParse(json['overtime_rate']?.toString() ?? '0') ?? 0.0,
      isMarked: json['is_marked'] as bool? ?? false,
      attendanceId: json['attendance_id'] as int?,
      status: json['status'] as String?,
      overtimeHours: double.tryParse(json['overtime_hours']?.toString() ?? '0') ?? 0.0,
      remarks: json['remarks'] as String? ?? '',
      isDirty: false,
    );
  }

  Map<String, dynamic> toSubmissionJson() {
    return {
      'staff_id': staffId,
      'status': status ?? 'PRESENT',
      'overtime_hours': overtimeHours.toStringAsFixed(2),
      'remarks': remarks,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'staff_id': staffId,
      'employee_code': employeeCode,
      'full_name': fullName,
      'department_id': departmentId,
      'department_name': departmentName,
      'shift_name': shiftName,
      'overtime_rate': overtimeRate,
      'is_marked': isMarked,
      'attendance_id': attendanceId,
      'status': status,
      'overtime_hours': overtimeHours,
      'remarks': remarks,
    };
  }

  AttendanceRosterItem copyWith({
    String? status,
    double? overtimeHours,
    String? remarks,
    bool? isDirty,
    bool? isMarked,
  }) {
    return AttendanceRosterItem(
      staffId: staffId,
      employeeCode: employeeCode,
      fullName: fullName,
      departmentId: departmentId,
      departmentName: departmentName,
      shiftName: shiftName,
      overtimeRate: overtimeRate,
      isMarked: isMarked ?? this.isMarked,
      attendanceId: attendanceId,
      status: status ?? this.status,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      remarks: remarks ?? this.remarks,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}

class AttendanceSummaryModel {
  final String date;
  final int totalActiveStaff;
  final int presentCount;
  final int halfDayCount;
  final int absentCount;
  final int leaveCount;
  final int unmarkedCount;
  final double totalOvertimeHours;

  AttendanceSummaryModel({
    required this.date,
    required this.totalActiveStaff,
    required this.presentCount,
    required this.halfDayCount,
    required this.absentCount,
    required this.leaveCount,
    required this.unmarkedCount,
    required this.totalOvertimeHours,
  });

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryModel(
      date: json['date'] as String? ?? '',
      totalActiveStaff: json['total_active_staff'] as int? ?? 0,
      presentCount: json['present_count'] as int? ?? 0,
      halfDayCount: json['half_day_count'] as int? ?? 0,
      absentCount: json['absent_count'] as int? ?? 0,
      leaveCount: json['leave_count'] as int? ?? 0,
      unmarkedCount: json['unmarked_count'] as int? ?? 0,
      totalOvertimeHours: double.tryParse(json['total_overtime_hours']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class AttendanceRecordModel {
  final int id;
  final int staffId;
  final String employeeCode;
  final String staffName;
  final String departmentName;
  final String date;
  final String status;
  final double overtimeHours;
  final double overtimeRate;
  final double overtimeAmount;
  final double paidDayWeight;
  final String remarks;

  AttendanceRecordModel({
    required this.id,
    required this.staffId,
    required this.employeeCode,
    required this.staffName,
    required this.departmentName,
    required this.date,
    required this.status,
    required this.overtimeHours,
    required this.overtimeRate,
    required this.overtimeAmount,
    required this.paidDayWeight,
    required this.remarks,
  });

  DateTime? get dateTime {
    try {
      return DateTime.parse(date);
    } catch (_) {
      return null;
    }
  }

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['id'] as int? ?? 0,
      staffId: json['staff'] as int? ?? 0,
      employeeCode: json['employee_code'] as String? ?? '',
      staffName: json['staff_name'] as String? ?? '',
      departmentName: json['department_name'] as String? ?? '',
      date: json['date'] as String? ?? '',
      status: json['status'] as String? ?? 'PRESENT',
      overtimeHours: double.tryParse(json['overtime_hours']?.toString() ?? '0') ?? 0.0,
      overtimeRate: double.tryParse(json['overtime_rate']?.toString() ?? '0') ?? 0.0,
      overtimeAmount: double.tryParse(json['overtime_amount']?.toString() ?? '0') ?? 0.0,
      paidDayWeight: double.tryParse(json['paid_day_weight']?.toString() ?? '1.0') ?? 1.0,
      remarks: json['remarks'] as String? ?? '',
    );
  }
}
