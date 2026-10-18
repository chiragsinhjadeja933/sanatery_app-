import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanatery_app/app.dart';
import 'package:sanatery_app/features/auth/models/user_model.dart';
import 'package:sanatery_app/features/departments/models/department_model.dart';
import 'package:sanatery_app/features/shifts/models/shift_model.dart';
import 'package:sanatery_app/features/staff/models/staff_model.dart';
import 'package:sanatery_app/features/attendance/models/attendance_model.dart';
import 'package:sanatery_app/features/payroll/models/payroll_model.dart';
import 'package:sanatery_app/core/utils/formatters.dart';

void main() {
  group('Sanitary ERP Unit & Model Tests', () {
    test('Formatters test', () {
      expect(Formatters.formatCurrency(25000), '₹25,000');
      expect(Formatters.formatOvertime(2.5), '2.5 hrs');
      expect(Formatters.formatOvertime(3.0), '3 hrs');
    });

    test('User model parsing test', () {
      final user = UserModel.fromJson({
        'id': 1,
        'username': 'admin',
        'email': 'admin@factory.com',
        'first_name': 'System',
        'last_name': 'Admin',
        'role': 'ADMIN',
        'phone': '9876543210',
      });
      expect(user.isAdmin, true);
      expect(user.fullName, 'System Admin');
      expect(user.role, UserRole.admin);
    });

    test('Department and Shift models test', () {
      final dept = DepartmentModel.fromJson({
        'id': 1,
        'name': 'Production',
        'description': 'Main plant floor',
        'is_active': true,
      });
      expect(dept.name, 'Production');

      final shift = ShiftModel.fromJson({
        'id': 1,
        'name': 'Morning Shift',
        'start_time': '08:00:00',
        'end_time': '16:00:00',
        'is_active': true,
      });
      expect(shift.formattedSchedule, '08:00 - 16:00');
    });

    test('Staff and Attendance models test', () {
      final staff = StaffModel.fromJson({
        'id': 1,
        'employee_code': 'EMP001',
        'full_name': 'Rahul Patel',
        'phone': '9876500001',
        'joining_date': '2024-01-15',
        'department': 1,
        'department_name': 'Production',
        'designation': 'Senior Operator',
        'monthly_salary': '32000.00',
        'overtime_rate': '150.00',
        'daily_salary': '1066.67',
        'status': 'ACTIVE',
      });
      expect(staff.isActive, true);
      expect(staff.monthlySalary, 32000.0);

      final att = AttendanceRosterItem.fromJson({
        'staff_id': 1,
        'employee_code': 'EMP001',
        'full_name': 'Rahul Patel',
        'department_id': 1,
        'department_name': 'Production',
        'shift_name': 'Morning Shift',
        'overtime_rate': '150.00',
        'is_marked': true,
        'status': 'PRESENT',
        'overtime_hours': '2.00',
        'remarks': 'Floor overtime',
      });
      expect(att.status, 'PRESENT');
      expect(att.overtimeHours, 2.0);

      final record = AttendanceRecordModel.fromJson({
        'id': 101,
        'staff': 1,
        'employee_code': 'EMP001',
        'staff_name': 'Rahul Patel',
        'department_name': 'Production',
        'date': '2026-09-08',
        'status': 'PRESENT',
        'overtime_hours': '1.50',
        'overtime_rate': '150.00',
        'overtime_amount': '225.00',
        'paid_day_weight': '1.0',
        'remarks': 'Machine maintenance OT',
      });
      expect(record.status, 'PRESENT');
      expect(record.overtimeAmount, 225.0);
      expect(record.dateTime?.day, 8);
    });

    test('Payroll model test', () {
      final payroll = PayrollModel.fromJson({
        'id': 1,
        'staff': 1,
        'employee_code': 'EMP001',
        'staff_name': 'Rahul Patel',
        'department_name': 'Production',
        'shift_name': 'Morning Shift',
        'month': 9,
        'year': 2026,
        'total_working_days': 30,
        'days_present': '26.0',
        'days_half_day': '1.0',
        'days_absent': '1.0',
        'days_leave': '2.0',
        'overtime_hours': '10.0',
        'overtime_rate': '150.00',
        'overtime_amount': '1500.00',
        'base_salary': '32000.00',
        'calculated_earned_salary': '28266.67',
        'advance_deduction': '2000.00',
        'other_deductions': '0.00',
        'other_bonuses': '0.00',
        'gross_salary': '29766.67',
        'net_salary': '27766.67',
        'status': 'DRAFT',
        'is_finalized': false,
      });
      expect(payroll.netSalary, 27766.67);
      expect(payroll.isFinalized, false);
    });
  });

  testWidgets('SanitaryApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SanitaryApp(),
      ),
    );

    // Initial pump shows CircularProgressIndicator while checking auth or renders login
    expect(find.byType(SanitaryApp), findsOneWidget);
  });
}
