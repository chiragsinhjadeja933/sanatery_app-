class ApiEndpoints {
  // Default base URL. For Android Emulator: 'http://10.0.2.2:8000/api/'
  // For Windows/Localhost: 'http://127.0.0.1:8000/api/'
  static const String defaultBaseUrl = 'http://127.0.0.1:8000/api/';

  // Auth & Accounts
  static const String login = 'login/';
  static const String tokenRefresh = 'token/refresh/';
  static const String currentUser = 'me/';
  static const String users = 'users/';

  // Departments & Shifts
  static const String departments = 'departments/';
  static const String shifts = 'shifts/';

  // Staff
  static const String staff = 'staff/';
  static String staffDetail(int id) => 'staff/$id/';
  static String activateStaff(int id) => 'staff/$id/activate/';
  static String deactivateStaff(int id) => 'staff/$id/deactivate/';

  // Attendance
  static const String attendance = 'attendance/';
  static const String attendanceSummary = 'attendance/summary/';
  static const String dailyRoster = 'attendance/daily_roster/';
  static const String bulkMarkAttendance = 'attendance/bulk_mark/';

  // Advances
  static const String advances = 'advances/';
  static String advanceDetail(int id) => 'advances/$id/';

  // Payroll
  static const String payroll = 'payroll/';
  static String payrollDetail(int id) => 'payroll/$id/';
  static const String payrollSummary = 'payroll/summary/';
  static const String generatePayroll = 'payroll/generate/';
  static String finalizePayroll(int id) => 'payroll/$id/finalize/';
  static const String finalizeAllPayroll = 'payroll/finalize_all/';

  // Dashboard
  static const String dashboardKpi = 'dashboard/kpi/';
}
