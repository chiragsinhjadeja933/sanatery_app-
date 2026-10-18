class DashboardKpiModel {
  final int totalActiveStaff;
  final int totalInactiveStaff;
  final int totalDepartments;
  final int totalShifts;

  final String todayDate;
  final int presentToday;
  final int halfDayToday;
  final int absentToday;
  final int leaveToday;
  final int unmarkedToday;
  final double todayOtHours;

  final int payrollMonth;
  final int payrollYear;
  final int draftPayrollCount;
  final int finalizedPayrollCount;
  final double totalNetPayroll;
  final double totalAdvancesDisbursed;

  DashboardKpiModel({
    required this.totalActiveStaff,
    required this.totalInactiveStaff,
    required this.totalDepartments,
    required this.totalShifts,
    required this.todayDate,
    required this.presentToday,
    required this.halfDayToday,
    required this.absentToday,
    required this.leaveToday,
    required this.unmarkedToday,
    required this.todayOtHours,
    required this.payrollMonth,
    required this.payrollYear,
    required this.draftPayrollCount,
    required this.finalizedPayrollCount,
    required this.totalNetPayroll,
    required this.totalAdvancesDisbursed,
  });

  double get attendanceRate {
    if (totalActiveStaff == 0) return 0.0;
    return (presentToday + (halfDayToday * 0.5)) / totalActiveStaff;
  }

  factory DashboardKpiModel.fromJson(Map<String, dynamic> json) {
    final overview = json['factory_overview'] as Map<String, dynamic>? ?? {};
    final att = json['today_attendance'] as Map<String, dynamic>? ?? {};
    final payroll = json['current_month_payroll'] as Map<String, dynamic>? ?? {};

    return DashboardKpiModel(
      totalActiveStaff: overview['total_active_staff'] as int? ?? 0,
      totalInactiveStaff: overview['total_inactive_staff'] as int? ?? 0,
      totalDepartments: overview['total_departments'] as int? ?? 0,
      totalShifts: overview['total_shifts'] as int? ?? 0,
      todayDate: att['date'] as String? ?? '',
      presentToday: att['present'] as int? ?? 0,
      halfDayToday: att['half_day'] as int? ?? 0,
      absentToday: att['absent'] as int? ?? 0,
      leaveToday: att['leave'] as int? ?? 0,
      unmarkedToday: att['unmarked'] as int? ?? 0,
      todayOtHours: double.tryParse(att['total_overtime_hours']?.toString() ?? '0') ?? 0.0,
      payrollMonth: payroll['month'] as int? ?? 1,
      payrollYear: payroll['year'] as int? ?? 2026,
      draftPayrollCount: payroll['draft_count'] as int? ?? 0,
      finalizedPayrollCount: payroll['finalized_count'] as int? ?? 0,
      totalNetPayroll: double.tryParse(payroll['total_net_salary']?.toString() ?? '0') ?? 0.0,
      totalAdvancesDisbursed: double.tryParse(payroll['total_advances_disbursed']?.toString() ?? '0') ?? 0.0,
    );
  }
}
