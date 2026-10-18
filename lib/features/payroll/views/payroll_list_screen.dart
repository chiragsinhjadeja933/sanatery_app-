import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/payroll_model.dart';
import '../providers/payroll_provider.dart';
import 'payslip_detail_modal.dart';

class PayrollListScreen extends ConsumerWidget {
  const PayrollListScreen({super.key});

  void _showPayslip(BuildContext context, PayrollModel payroll) {
    showDialog(
      context: context,
      builder: (_) => PayslipDetailModal(payroll: payroll),
    );
  }

  Future<void> _confirmGenerate(BuildContext context, WidgetRef ref, int month, int year) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Generate Payroll for ${Formatters.formatMonthYear(month, year)}?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This will recalculate monthly salary for all employees based on their logged attendance, overtime hours, and approved salary advances.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Run Calculation'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final ok = await ref.read(payrollProvider.notifier).generatePayroll();
      if (ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payroll draft calculated and generated!')),
        );
      }
    }
  }

  Future<void> _confirmFinalizeAll(BuildContext context, WidgetRef ref, int month, int year) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Finalize All Payrolls for ${Formatters.formatMonthYear(month, year)}?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Finalizing locks all salary calculations for disbursement and prevents further automatic recalculations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.successDark),
            child: const Text('Finalize All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final ok = await ref.read(payrollProvider.notifier).finalizeAllPayrolls();
      if (ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All draft payroll records finalized successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payrollState = ref.watch(payrollProvider);
    final authState = ref.watch(authProvider);
    final isAdmin = authState.user?.isAdmin ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Factory Payroll'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(payrollProvider.notifier).loadPayrollData(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Month / Year Selector Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, size: 28),
                  onPressed: () {
                    var m = payrollState.month - 1;
                    var y = payrollState.year;
                    if (m < 1) {
                      m = 12;
                      y -= 1;
                    }
                    ref.read(payrollProvider.notifier).changeMonth(m, y);
                  },
                ),
                Text(
                  Formatters.formatMonthYear(payrollState.month, payrollState.year),
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, size: 28),
                  onPressed: () {
                    var m = payrollState.month + 1;
                    var y = payrollState.year;
                    if (m > 12) {
                      m = 1;
                      y += 1;
                    }
                    ref.read(payrollProvider.notifier).changeMonth(m, y);
                  },
                ),
              ],
            ),
          ),

          // 2. Summary KPI Ribbon
          if (payrollState.summary != null) ...[
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  _buildSummaryCard(
                    title: 'Net Payable',
                    value: Formatters.formatCurrency(payrollState.summary!.totalNetSalary),
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryCard(
                    title: 'Advances Rec.',
                    value: Formatters.formatCurrency(payrollState.summary!.totalAdvanceDeductions),
                    color: AppColors.warningDark,
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryCard(
                    title: 'OT Amount',
                    value: Formatters.formatCurrency(payrollState.summary!.totalOvertimeAmount),
                    color: AppColors.purple,
                  ),
                ],
              ),
            ),
          ],

          // 3. Action Toolbar (Generate & Finalize All)
          if (isAdmin)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Calculate / Recalculate',
                      icon: Icons.calculate_outlined,
                      height: 38,
                      isLoading: payrollState.isGenerating,
                      onPressed: () => _confirmGenerate(context, ref, payrollState.month, payrollState.year),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (payrollState.summary != null && payrollState.summary!.draftCount > 0) ...[
                    CustomButton(
                      text: 'Finalize All (${payrollState.summary!.draftCount})',
                      icon: Icons.lock_outline,
                      height: 38,
                      backgroundColor: AppColors.successDark,
                      isLoading: payrollState.isGenerating,
                      onPressed: () => _confirmFinalizeAll(context, ref, payrollState.month, payrollState.year),
                    ),
                  ],
                ],
              ),
            ),

          const Divider(height: 1),

          // 4. Payroll Records List
          Expanded(
            child: Builder(
              builder: (context) {
                if (payrollState.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (payrollState.errorMessage != null && payrollState.payrolls.isEmpty) {
                  return ErrorView(
                    message: payrollState.errorMessage!,
                    onRetry: () => ref.read(payrollProvider.notifier).loadPayrollData(),
                  );
                }

                if (payrollState.payrolls.isEmpty) {
                  return EmptyStateView(
                    title: 'No Payroll Records',
                    message: 'No calculated salary records found for ${Formatters.formatMonthYear(payrollState.month, payrollState.year)}.',
                    buttonText: isAdmin ? 'Generate Payroll Drafts' : null,
                    onButtonPressed: isAdmin ? () => _confirmGenerate(context, ref, payrollState.month, payrollState.year) : null,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: payrollState.payrolls.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final payroll = payrollState.payrolls[index];
                    return _buildPayrollCard(context, ref, payroll, isAdmin);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required String value, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayrollCard(BuildContext context, WidgetRef ref, PayrollModel payroll, bool isAdmin) {
    return InkWell(
      onTap: () => _showPayslip(context, payroll),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payroll.staffName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${payroll.employeeCode} • ${payroll.departmentName}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.formatCurrency(payroll.netSalary),
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    StatusBadge.fromPayrollStatus(payroll.status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem('Present', '${payroll.daysPresent}d'),
                  _buildStatItem('OT Hrs', '${payroll.overtimeHours.toStringAsFixed(1)}h'),
                  _buildStatItem('Gross', Formatters.formatCurrency(payroll.grossSalary)),
                  _buildStatItem('Adv. Ded', Formatters.formatCurrency(payroll.advanceDeduction)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.visibility_outlined, size: 14, color: AppColors.accentDark),
                    SizedBox(width: 4),
                    Text(
                      'Tap to view payslip',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accentDark),
                    ),
                  ],
                ),
                if (!payroll.isFinalized && isAdmin)
                  TextButton(
                    onPressed: () => ref.read(payrollProvider.notifier).finalizeSinglePayroll(payroll.id),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      backgroundColor: AppColors.successLight,
                    ),
                    child: const Text(
                      'Finalize',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.successDark),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
