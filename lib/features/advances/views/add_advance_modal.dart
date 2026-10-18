import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../staff/providers/staff_provider.dart';
import '../models/advance_model.dart';
import '../providers/advance_provider.dart';

class AddAdvanceModal extends ConsumerStatefulWidget {
  const AddAdvanceModal({super.key});

  @override
  ConsumerState<AddAdvanceModal> createState() => _AddAdvanceModalState();
}

class _AddAdvanceModalState extends ConsumerState<AddAdvanceModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  int? _selectedStaffId;
  DateTime _advanceDate = DateTime.now();
  String _status = 'APPROVED';
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _advanceDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _advanceDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedStaffId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an employee')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final model = AdvanceSalaryModel(
      id: 0,
      staffId: _selectedStaffId!,
      staffName: '',
      employeeCode: '',
      departmentName: '',
      amount: double.tryParse(_amountController.text.trim()) ?? 0,
      date: Formatters.formatApiDate(_advanceDate),
      reason: _reasonController.text.trim(),
      status: _status,
    );

    final ok = await ref.read(advanceProvider.notifier).createAdvance(model);
    setState(() => _isLoading = false);

    if (ok && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salary advance recorded successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffState = ref.watch(staffProvider);

    // Default to first active staff
    if (_selectedStaffId == null && staffState.staffList.isNotEmpty) {
      _selectedStaffId = staffState.staffList.first.id;
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Record Salary Advance',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Staff Selector
              const Text(
                'Select Employee',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                initialValue: _selectedStaffId,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: staffState.staffList.map((s) {
                  return DropdownMenuItem<int>(
                    value: s.id,
                    child: Text('${s.fullName} (${s.employeeCode})'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedStaffId = val),
              ),
              const SizedBox(height: 16),

              // Amount & Date
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Advance Amount (₹)',
                      controller: _amountController,
                      hint: '2000',
                      keyboardType: TextInputType.number,
                      validator: (v) => Validators.numericField(v, 'Amount'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Disbursement Date',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  Formatters.formatShortDate(_advanceDate),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Reason / Purpose',
                controller: _reasonController,
                hint: 'e.g. Medical emergency, festival advance, personal loan',
                maxLines: 2,
                validator: (v) => Validators.requiredField(v, 'Reason'),
              ),
              const SizedBox(height: 16),

              // Approval Status
              const Text(
                'Approval Status',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'APPROVED', child: Text('Approved (Deduct from payroll)')),
                  DropdownMenuItem(value: 'PENDING', child: Text('Pending Review')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Record Advance',
                isLoading: _isLoading,
                icon: Icons.check,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
