import '../../departments/models/department_model.dart';
import '../../shifts/models/shift_model.dart';

class StaffModel {
  final int id;
  final String employeeCode;
  final String fullName;
  final String phone;
  final String joiningDate;
  final int departmentId;
  final String departmentName;
  final DepartmentModel? departmentDetail;
  final String designation;
  final int? shiftId;
  final String? shiftName;
  final ShiftModel? shiftDetail;
  final String salaryType;
  final double monthlySalary;
  final double overtimeRate;
  final double dailySalary;
  final double shiftHours;
  final double hourlySalary;
  final String status;

  StaffModel({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    required this.phone,
    required this.joiningDate,
    required this.departmentId,
    required this.departmentName,
    this.departmentDetail,
    required this.designation,
    this.shiftId,
    this.shiftName,
    this.shiftDetail,
    required this.salaryType,
    required this.monthlySalary,
    required this.overtimeRate,
    required this.dailySalary,
    this.shiftHours = 8.0,
    this.hourlySalary = 0.0,
    required this.status,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    DepartmentModel? deptDetail;
    if (json['department_detail'] != null && json['department_detail'] is Map<String, dynamic>) {
      deptDetail = DepartmentModel.fromJson(json['department_detail'] as Map<String, dynamic>);
    }

    ShiftModel? sDetail;
    if (json['shift_detail'] != null && json['shift_detail'] is Map<String, dynamic>) {
      sDetail = ShiftModel.fromJson(json['shift_detail'] as Map<String, dynamic>);
    }

    return StaffModel(
      id: json['id'] as int? ?? 0,
      employeeCode: json['employee_code'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      joiningDate: json['joining_date'] as String? ?? '',
      departmentId: json['department'] as int? ?? (deptDetail?.id ?? 0),
      departmentName: json['department_name'] as String? ?? (deptDetail?.name ?? 'General'),
      departmentDetail: deptDetail,
      designation: json['designation'] as String? ?? '',
      shiftId: json['shift'] as int?,
      shiftName: json['shift_name'] as String? ?? (sDetail?.name ?? 'None'),
      shiftDetail: sDetail,
      salaryType: json['salary_type'] as String? ?? 'MONTHLY',
      monthlySalary: double.tryParse(json['monthly_salary']?.toString() ?? '0') ?? 0.0,
      overtimeRate: double.tryParse(json['overtime_rate']?.toString() ?? '0') ?? 0.0,
      dailySalary: double.tryParse(json['daily_salary']?.toString() ?? '0') ?? 0.0,
      shiftHours: double.tryParse(json['shift_hours']?.toString() ?? (sDetail?.durationHours.toString() ?? '8.0')) ?? 8.0,
      hourlySalary: double.tryParse(json['hourly_salary']?.toString() ?? '0') ?? 0.0,
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_code': employeeCode,
      'full_name': fullName,
      'phone': phone,
      'joining_date': joiningDate,
      'department': departmentId,
      'designation': designation,
      'shift': shiftId,
      'salary_type': salaryType,
      'monthly_salary': monthlySalary.toStringAsFixed(2),
      'overtime_rate': overtimeRate.toStringAsFixed(2),
      'status': status,
    };
  }
}
