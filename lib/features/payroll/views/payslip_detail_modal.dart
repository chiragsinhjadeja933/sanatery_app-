import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/payroll_model.dart';

class PayslipDetailModal extends StatelessWidget {
  final PayrollModel payroll;

  const PayslipDetailModal({super.key, required this.payroll});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Factory Logo & Company Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FACTORY PAYSLIP',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Formatters.formatMonthYear(payroll.month, payroll.year),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  StatusBadge.fromPayrollStatus(payroll.status),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Employee Info Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildRow('Employee Name', payroll.staffName, isBold: true),
                    const SizedBox(height: 6),
                    _buildRow('Employee Code', payroll.employeeCode),
                    const SizedBox(height: 6),
                    _buildRow('Department', payroll.departmentName),
                    const SizedBox(height: 6),
                    _buildRow('Shift Schedule', payroll.shiftName),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Attendance Breakdown
              Text(
                'Attendance & Days Summary',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    _buildRow('Working Days in Month', '${payroll.totalWorkingDays} days'),
                    const Divider(height: 12),
                    _buildRow('Present Days', '${payroll.daysPresent} days'),
                    const SizedBox(height: 4),
                    _buildRow('Half Days', '${payroll.daysHalfDay} days'),
                    const SizedBox(height: 4),
                    _buildRow('Absent Days', '${payroll.daysAbsent} days'),
                    const SizedBox(height: 4),
                    _buildRow('Approved Leave', '${payroll.daysLeave} days'),
                    const Divider(height: 12),
                    _buildRow(
                      'Overtime Logged',
                      '${payroll.overtimeHours.toStringAsFixed(1)} hrs @ ${Formatters.formatCurrency(payroll.overtimeRate)}/hr',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Earnings & Deductions Table
              Text(
                'Earnings & Deductions',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    _buildAmountRow('Base Monthly Wage', payroll.baseSalary),
                    const SizedBox(height: 6),
                    _buildAmountRow('Earned Wage (Attendance Adjusted)', payroll.calculatedEarnedSalary, color: AppColors.primary),
                    const SizedBox(height: 6),
                    _buildAmountRow('Overtime Allowance (+)', payroll.overtimeAmount, color: AppColors.successDark),
                    if (payroll.otherBonuses > 0) ...[
                      const SizedBox(height: 6),
                      _buildAmountRow('Bonuses & Incentives (+)', payroll.otherBonuses, color: AppColors.successDark),
                    ],
                    const Divider(height: 14),
                    _buildAmountRow('Gross Earnings', payroll.grossSalary, isBold: true),
                    const Divider(height: 14),
                    _buildAmountRow('Advance Salary Recovery (-)', -payroll.advanceDeduction, color: AppColors.danger),
                    if (payroll.otherDeductions > 0) ...[
                      const SizedBox(height: 6),
                      _buildAmountRow('Other Deductions (-)', -payroll.otherDeductions, color: AppColors.danger),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Net Take-Home Salary Total Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NET TAKE-HOME PAYABLE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textTertiary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Transferred / Disbursed',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                    Text(
                      Formatters.formatCurrency(payroll.netSalary, showDecimals: true),
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Copy Text',
                      icon: Icons.copy_rounded,
                      isOutlined: true,
                      onPressed: () {
                        final slipText = '''
==============================
FACTORY PAYSLIP - ${Formatters.formatMonthYear(payroll.month, payroll.year)}
==============================
Employee: ${payroll.staffName} (${payroll.employeeCode})
Department: ${payroll.departmentName}
Working Days: ${payroll.totalWorkingDays}
Present: ${payroll.daysPresent} | Half-Day: ${payroll.daysHalfDay} | Absent: ${payroll.daysAbsent} | Leave: ${payroll.daysLeave}
Overtime: ${payroll.overtimeHours.toStringAsFixed(1)} hrs (+${Formatters.formatCurrency(payroll.overtimeAmount)})
------------------------------
Base Wage: ${Formatters.formatCurrency(payroll.baseSalary)}
Earned Wage: ${Formatters.formatCurrency(payroll.calculatedEarnedSalary)}
Gross Salary: ${Formatters.formatCurrency(payroll.grossSalary)}
Advance Deduction: -${Formatters.formatCurrency(payroll.advanceDeduction)}
------------------------------
NET PAYABLE: ${Formatters.formatCurrency(payroll.netSalary, showDecimals: true)}
Status: ${payroll.status}
==============================''';
                        Clipboard.setData(ClipboardData(text: slipText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payslip summary copied to clipboard!')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Close',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(String label, double amount, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          Formatters.formatCurrency(amount.abs()),
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
