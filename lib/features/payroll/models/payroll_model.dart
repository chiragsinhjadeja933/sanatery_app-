class PayrollModel {
  final int id;
  final int staffId;
  final String employeeCode;
  final String staffName;
  final String departmentName;
  final String shiftName;
  final int month;
  final int year;
  final int totalWorkingDays;
  final double daysPresent;
  final double daysHalfDay;
  final double daysAbsent;
  final double daysLeave;
  final double overtimeHours;
  final double overtimeRate;
  final double overtimeAmount;
  final double baseSalary;
  final double calculatedEarnedSalary;
  final double advanceDeduction;
  final double otherDeductions;
  final double otherBonuses;
  final double grossSalary;
  final double netSalary;
  final String status;
  final bool isFinalized;
  final String? finalizedAt;

  PayrollModel({
    required this.id,
    required this.staffId,
    required this.employeeCode,
    required this.staffName,
    required this.departmentName,
    required this.shiftName,
    required this.month,
    required this.year,
    required this.totalWorkingDays,
    required this.daysPresent,
    required this.daysHalfDay,
    required this.daysAbsent,
    required this.daysLeave,
    required this.overtimeHours,
    required this.overtimeRate,
    required this.overtimeAmount,
    required this.baseSalary,
    required this.calculatedEarnedSalary,
    required this.advanceDeduction,
    required this.otherDeductions,
    required this.otherBonuses,
    required this.grossSalary,
    required this.netSalary,
    required this.status,
    required this.isFinalized,
    this.finalizedAt,
  });

  factory PayrollModel.fromJson(Map<String, dynamic> json) {
    return PayrollModel(
      id: json['id'] as int? ?? 0,
      staffId: json['staff'] as int? ?? 0,
      employeeCode: json['employee_code'] as String? ?? '',
      staffName: json['staff_name'] as String? ?? 'Employee',
      departmentName: json['department_name'] as String? ?? 'General',
      shiftName: json['shift_name'] as String? ?? 'None',
      month: json['month'] as int? ?? 1,
      year: json['year'] as int? ?? 2026,
      totalWorkingDays: json['total_working_days'] as int? ?? 30,
      daysPresent: double.tryParse(json['days_present']?.toString() ?? '0') ?? 0.0,
      daysHalfDay: double.tryParse(json['days_half_day']?.toString() ?? '0') ?? 0.0,
      daysAbsent: double.tryParse(json['days_absent']?.toString() ?? '0') ?? 0.0,
      daysLeave: double.tryParse(json['days_leave']?.toString() ?? '0') ?? 0.0,
      overtimeHours: double.tryParse(json['overtime_hours']?.toString() ?? '0') ?? 0.0,
      overtimeRate: double.tryParse(json['overtime_rate']?.toString() ?? '0') ?? 0.0,
      overtimeAmount: double.tryParse(json['overtime_amount']?.toString() ?? '0') ?? 0.0,
      baseSalary: double.tryParse(json['base_salary']?.toString() ?? '0') ?? 0.0,
      calculatedEarnedSalary: double.tryParse(json['calculated_earned_salary']?.toString() ?? '0') ?? 0.0,
      advanceDeduction: double.tryParse(json['advance_deduction']?.toString() ?? '0') ?? 0.0,
      otherDeductions: double.tryParse(json['other_deductions']?.toString() ?? '0') ?? 0.0,
      otherBonuses: double.tryParse(json['other_bonuses']?.toString() ?? '0') ?? 0.0,
      grossSalary: double.tryParse(json['gross_salary']?.toString() ?? '0') ?? 0.0,
      netSalary: double.tryParse(json['net_salary']?.toString() ?? '0') ?? 0.0,
      status: json['status'] as String? ?? 'DRAFT',
      isFinalized: json['is_finalized'] as bool? ?? false,
      finalizedAt: json['finalized_at'] as String?,
    );
  }
}

class PayrollSummaryModel {
  final int month;
  final int year;
  final int totalRecords;
  final int draftCount;
  final int finalizedCount;
  final double totalNetSalary;
  final double totalGrossSalary;
  final double totalAdvanceDeductions;
  final double totalOvertimeAmount;

  PayrollSummaryModel({
    required this.month,
    required this.year,
    required this.totalRecords,
    required this.draftCount,
    required this.finalizedCount,
    required this.totalNetSalary,
    required this.totalGrossSalary,
    required this.totalAdvanceDeductions,
    required this.totalOvertimeAmount,
  });

  factory PayrollSummaryModel.fromJson(Map<String, dynamic> json) {
    return PayrollSummaryModel(
      month: json['month'] as int? ?? 1,
      year: json['year'] as int? ?? 2026,
      totalRecords: json['total_records'] as int? ?? 0,
      draftCount: json['draft_count'] as int? ?? 0,
      finalizedCount: json['finalized_count'] as int? ?? 0,
      totalNetSalary: double.tryParse(json['total_net_salary']?.toString() ?? '0') ?? 0.0,
      totalGrossSalary: double.tryParse(json['total_gross_salary']?.toString() ?? '0') ?? 0.0,
      totalAdvanceDeductions: double.tryParse(json['total_advance_deductions']?.toString() ?? '0') ?? 0.0,
      totalOvertimeAmount: double.tryParse(json['total_overtime_amount']?.toString() ?? '0') ?? 0.0,
    );
  }
}
