import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/advance_model.dart';
import '../providers/advance_provider.dart';
import 'add_advance_modal.dart';

class AdvancesListScreen extends ConsumerWidget {
  const AdvancesListScreen({super.key});

  void _showAddAdvanceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const AddAdvanceModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final advState = ref.watch(advanceProvider);
    final authState = ref.watch(authProvider);
    final isManagerOrAdmin = authState.user?.isManagerOrAdmin ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Salary Advances'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(advanceProvider.notifier).fetchAdvances(),
          ),
        ],
      ),
      floatingActionButton: isManagerOrAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New Advance'),
              onPressed: () => _showAddAdvanceModal(context),
            )
          : null,
      body: Column(
        children: [
          // 1. Month / Year Selector Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, size: 28),
                  onPressed: () {
                    var m = advState.month - 1;
                    var y = advState.year;
                    if (m < 1) {
                      m = 12;
                      y -= 1;
                    }
                    ref.read(advanceProvider.notifier).changeMonth(m, y);
                  },
                ),
                Text(
                  Formatters.formatMonthYear(advState.month, advState.year),
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, size: 28),
                  onPressed: () {
                    var m = advState.month + 1;
                    var y = advState.year;
                    if (m > 12) {
                      m = 1;
                      y += 1;
                    }
                    ref.read(advanceProvider.notifier).changeMonth(m, y);
                  },
                ),
              ],
            ),
          ),

          // 2. Total Disbursed Summary Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(40),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Approved Advances',
                      style: TextStyle(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      Formatters.formatCurrency(advState.totalDisbursed),
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.receipt_long_outlined, color: AppColors.accent, size: 26),
                ),
              ],
            ),
          ),

          // 3. Advances Records List
          Expanded(
            child: Builder(
              builder: (context) {
                if (advState.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (advState.errorMessage != null && advState.advances.isEmpty) {
                  return ErrorView(
                    message: advState.errorMessage!,
                    onRetry: () => ref.read(advanceProvider.notifier).fetchAdvances(),
                  );
                }

                if (advState.advances.isEmpty) {
                  return EmptyStateView(
                    title: 'No Advances Recorded',
                    message: 'No employee advance salary requests for ${Formatters.formatMonthYear(advState.month, advState.year)}.',
                    buttonText: isManagerOrAdmin ? 'Record Advance' : null,
                    onButtonPressed: isManagerOrAdmin ? () => _showAddAdvanceModal(context) : null,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: advState.advances.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final advance = advState.advances[index];
                    return _buildAdvanceCard(context, ref, advance, isManagerOrAdmin);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvanceCard(
    BuildContext context,
    WidgetRef ref,
    AdvanceSalaryModel advance,
    bool isManagerOrAdmin,
  ) {
    final isPending = advance.status.toUpperCase() == 'PENDING';

    return Container(
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
                      advance.staffName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${advance.employeeCode} • ${advance.departmentName}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.formatCurrency(advance.amount),
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StatusBadge.fromAdvanceStatus(advance.status),
                ],
              ),
            ],
          ),
          if (advance.reason.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Reason: ${advance.reason}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date: ${Formatters.formatDate(advance.date)}',
                style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
              if (isPending && isManagerOrAdmin)
                Row(
                  children: [
                    TextButton(
                      onPressed: () => ref.read(advanceProvider.notifier).updateStatus(advance.id, 'APPROVED'),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.successLight,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      child: const Text('Approve', style: TextStyle(fontSize: 12, color: AppColors.successDark, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => ref.read(advanceProvider.notifier).updateStatus(advance.id, 'REJECTED'),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.dangerLight,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      child: const Text('Reject', style: TextStyle(fontSize: 12, color: AppColors.dangerDark, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
