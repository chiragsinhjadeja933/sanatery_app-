class AdvanceSalaryModel {
  final int id;
  final int staffId;
  final String staffName;
  final String employeeCode;
  final String departmentName;
  final double amount;
  final String date;
  final String reason;
  final String status;

  AdvanceSalaryModel({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.employeeCode,
    required this.departmentName,
    required this.amount,
    required this.date,
    required this.reason,
    required this.status,
  });

  factory AdvanceSalaryModel.fromJson(Map<String, dynamic> json) {
    return AdvanceSalaryModel(
      id: json['id'] as int? ?? 0,
      staffId: json['staff'] as int? ?? 0,
      staffName: json['staff_name'] as String? ?? 'Employee',
      employeeCode: json['employee_code'] as String? ?? '',
      departmentName: json['department_name'] as String? ?? 'General',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      date: json['date'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staff': staffId,
      'amount': amount.toStringAsFixed(2),
      'date': date,
      'reason': reason,
      'status': status,
    };
  }
}
