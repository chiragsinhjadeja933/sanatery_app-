import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../auth/providers/auth_provider.dart';
import '../../departments/providers/department_provider.dart';
import '../../shifts/providers/shift_provider.dart';
import '../models/staff_model.dart';
import '../providers/staff_provider.dart';

class StaffFormScreen extends ConsumerStatefulWidget {
  final StaffModel? staff;

  const StaffFormScreen({super.key, this.staff});

  @override
  ConsumerState<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends ConsumerState<StaffFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _desigController;
  late final TextEditingController _salaryController;
  late final TextEditingController _otRateController;
  
  DateTime _joiningDate = DateTime.now();
  int? _selectedDepartmentId;
  int? _selectedShiftId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.staff;
    _codeController = TextEditingController(text: s?.employeeCode ?? '');
    _nameController = TextEditingController(text: s?.fullName ?? '');
    _phoneController = TextEditingController(text: s?.phone ?? '');
    _desigController = TextEditingController(text: s?.designation ?? '');
    _salaryController = TextEditingController(
      text: s != null ? s.monthlySalary.toStringAsFixed(0) : '25000',
    );
    _otRateController = TextEditingController(
      text: s != null ? s.overtimeRate.toStringAsFixed(0) : '100',
    );

    if (s != null) {
      _selectedDepartmentId = s.departmentId;
      _selectedShiftId = s.shiftId;
      try {
        _joiningDate = DateTime.parse(s.joiningDate);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _desigController.dispose();
    _salaryController.dispose();
    _otRateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _joiningDate = picked);
    }
  }

  void _autoSet15xOtRate(List<dynamic> shifts) {
    final salary = double.tryParse(_salaryController.text.trim()) ?? 0;
    if (salary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid monthly salary first')),
      );
      return;
    }
    double shiftHours = 8.0;
    if (_selectedShiftId != null) {
      final s = shifts.where((e) => e.id == _selectedShiftId).firstOrNull;
      if (s != null && s.durationHours > 0) {
        shiftHours = s.durationHours;
      }
    }
    final hourlyRate = salary / (30.0 * shiftHours);
    final ot15x = hourlyRate * 1.5;
    setState(() {
      _otRateController.text = ot15x.toStringAsFixed(2);
    });
  }

  Future<void> _saveStaff() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedDepartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a department')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final isEditing = widget.staff != null;
    bool ok = false;

    if (isEditing) {
      final updateData = <String, dynamic>{
        'employee_code': _codeController.text.trim(),
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'designation': _desigController.text.trim(),
        'department': _selectedDepartmentId,
        'shift': _selectedShiftId,
        'joining_date': Formatters.formatApiDate(_joiningDate),
        'monthly_salary': double.tryParse(_salaryController.text.trim()) ?? 0,
        'overtime_rate': double.tryParse(_otRateController.text.trim()) ?? 0,
      };
      ok = await ref.read(staffProvider.notifier).updateStaff(
            widget.staff!.id,
            updateData,
          );
    } else {
      final newStaff = StaffModel(
        id: 0,
        employeeCode: _codeController.text.trim(),
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        joiningDate: Formatters.formatApiDate(_joiningDate),
        departmentId: _selectedDepartmentId!,
        departmentName: '',
        designation: _desigController.text.trim(),
        shiftId: _selectedShiftId,
        salaryType: 'MONTHLY',
        monthlySalary: double.tryParse(_salaryController.text.trim()) ?? 0,
        overtimeRate: double.tryParse(_otRateController.text.trim()) ?? 0,
        dailySalary: 0,
        status: 'ACTIVE',
      );
      ok = await ref.read(staffProvider.notifier).createStaff(newStaff);
    }

    setState(() => _isSaving = false);

    if (ok && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Employee updated' : 'Employee registered successfully'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deptState = ref.watch(departmentProvider);
    final shiftState = ref.watch(shiftProvider);
    final authState = ref.watch(authProvider);
    final isAdmin = authState.user?.isAdmin ?? false;
    final isEditing = widget.staff != null;

    // Auto select first department if none selected
    if (_selectedDepartmentId == null && deptState.departments.isNotEmpty) {
      _selectedDepartmentId = deptState.departments.first.id;
    }
    if (_selectedShiftId == null && shiftState.shifts.isNotEmpty) {
      _selectedShiftId = shiftState.shifts.first.id;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Employee' : 'Register New Staff'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // General Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal & Employment Info',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: CustomTextField(
                            label: 'Employee Code',
                            controller: _codeController,
                            hint: 'EMP007',
                            validator: (v) => Validators.requiredField(v, 'Employee Code'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: CustomTextField(
                            label: 'Contact Phone',
                            controller: _phoneController,
                            hint: '9876543210',
                            keyboardType: TextInputType.phone,
                            validator: Validators.phoneField,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Full Name',
                      controller: _nameController,
                      hint: 'e.g. Ramesh Patel',
                      validator: (v) => Validators.requiredField(v, 'Full Name'),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Designation / Role',
                      controller: _desigController,
                      hint: 'e.g. Machine Operator, Helper, QC Lead',
                      validator: (v) => Validators.requiredField(v, 'Designation'),
                    ),
                    const SizedBox(height: 16),

                    // Joining Date Picker
                    const Text(
                      'Joining Date',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Formatters.formatDate(_joiningDate),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Deployment & Shift Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Department & Work Shift',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Department Dropdown
                    const Text(
                      'Department',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedDepartmentId,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                      items: deptState.departments.map((dept) {
                        return DropdownMenuItem<int>(
                          value: dept.id,
                          child: Text(dept.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedDepartmentId = val),
                    ),

                    const SizedBox(height: 16),

                    // Shift Dropdown
                    const Text(
                      'Work Shift',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int?>(
                      initialValue: _selectedShiftId,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                      items: [
                        const DropdownMenuItem<int?>(value: null, child: Text('No Specific Shift')),
                        ...shiftState.shifts.map((shift) {
                          return DropdownMenuItem<int?>(
                            value: shift.id,
                            child: Text('${shift.name} (${shift.formattedSchedule})'),
                          );
                        }),
                      ],
                      onChanged: (val) => setState(() => _selectedShiftId = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Compensation & Overtime Card (Admin only edit)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Compensation & Rates',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (!isAdmin)
                          const Text(
                            '(Admin restricted)',
                            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Monthly Base Salary (₹)',
                            controller: _salaryController,
                            keyboardType: TextInputType.number,
                            readOnly: !isAdmin,
                            validator: (v) => Validators.numericField(v, 'Monthly Salary'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            label: 'Overtime Rate / hr (₹)',
                            controller: _otRateController,
                            keyboardType: TextInputType.number,
                            readOnly: !isAdmin,
                            validator: (v) => Validators.numericField(v, 'Overtime Rate'),
                          ),
                        ),
                      ],
                    ),
                    if (isAdmin) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _autoSet15xOtRate(shiftState.shifts),
                          icon: const Icon(Icons.calculate_outlined, size: 16, color: AppColors.primary),
                          label: const Text(
                            'Auto-calculate 1.5× OT Rate',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              CustomButton(
                text: isEditing ? 'Update Employee' : 'Register Employee',
                isLoading: _isSaving,
                icon: Icons.check_circle_outline,
                onPressed: _saveStaff,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
