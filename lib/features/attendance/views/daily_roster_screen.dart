import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../departments/providers/department_provider.dart';
import '../models/attendance_model.dart';
import '../providers/attendance_provider.dart';

class DailyRosterScreen extends ConsumerWidget {
  const DailyRosterScreen({super.key});

  Future<void> _pickDate(BuildContext context, WidgetRef ref, DateTime currentDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      ref.read(attendanceProvider.notifier).changeDate(picked);
    }
  }

  void _showRemarksDialog(BuildContext context, WidgetRef ref, AttendanceRosterItem item) {
    final controller = TextEditingController(text: item.remarks);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Remarks for ${item.fullName}',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'e.g. Late by 30 mins, machine breakdown OT, sick leave',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(attendanceProvider.notifier).setRemarks(item.staffId, controller.text.trim());
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attState = ref.watch(attendanceProvider);
    final deptState = ref.watch(departmentProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daily Roster Sheet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(attendanceProvider.notifier).loadRosterAndSummary(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Date Navigator Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, size: 28),
                  onPressed: () {
                    final prevDay = attState.selectedDate.subtract(const Duration(days: 1));
                    ref.read(attendanceProvider.notifier).changeDate(prevDay);
                  },
                ),
                InkWell(
                  onTap: () => _pickDate(context, ref, attState.selectedDate),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          Formatters.formatDate(attState.selectedDate),
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, size: 28),
                  onPressed: () {
                    final nextDay = attState.selectedDate.add(const Duration(days: 1));
                    ref.read(attendanceProvider.notifier).changeDate(nextDay);
                  },
                ),
              ],
            ),
          ),

          // 2. Summary KPI Quick Ribbon
          if (attState.summary != null)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  _buildSummaryPill(
                    label: 'Present',
                    count: attState.summary!.presentCount,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryPill(
                    label: 'Half-Day',
                    count: attState.summary!.halfDayCount,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryPill(
                    label: 'Absent',
                    count: attState.summary!.absentCount,
                    color: AppColors.danger,
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryPill(
                    label: 'Leave',
                    count: attState.summary!.leaveCount,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryPill(
                    label: 'OT Hrs',
                    count: attState.summary!.totalOvertimeHours.toInt(),
                    color: AppColors.purple,
                  ),
                ],
              ),
            ),

          // 3. Department Filter & Mark All Present Quick Action
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All Depts'),
                          selected: attState.selectedDepartmentId == null,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: attState.selectedDepartmentId == null ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                          onSelected: (_) => ref.read(attendanceProvider.notifier).changeDepartment(null),
                        ),
                        const SizedBox(width: 6),
                        ...deptState.departments.map((d) {
                          final isSel = attState.selectedDepartmentId == d.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              label: Text(d.name),
                              selected: isSel,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: isSel ? Colors.white : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                              onSelected: (_) => ref.read(attendanceProvider.notifier).changeDepartment(isSel ? null : d.id),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => ref.read(attendanceProvider.notifier).markAllPresent(),
                  icon: const Icon(Icons.done_all_rounded, size: 16, color: AppColors.successDark),
                  label: const Text(
                    'All Present',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.successDark),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.successLight,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 4. Roster List
          Expanded(
            child: Builder(
              builder: (context) {
                if (attState.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (attState.errorMessage != null && attState.roster.isEmpty) {
                  return ErrorView(
                    message: attState.errorMessage!,
                    onRetry: () => ref.read(attendanceProvider.notifier).loadRosterAndSummary(),
                  );
                }

                if (attState.roster.isEmpty) {
                  return const EmptyStateView(
                    title: 'No Active Staff',
                    message: 'No employees found for this department or roster date.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: attState.roster.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = attState.roster[index];
                    return _buildRosterCard(context, ref, item);
                  },
                );
              },
            ),
          ),
        ],
      ),

      // 5. Floating Bottom Save Bar
      bottomSheet: attState.hasUnsavedChanges
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.warningDark, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Unsaved Attendance Changes',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                    CustomButton(
                      text: 'Save Sheet',
                      isLoading: attState.isSaving,
                      icon: Icons.save_outlined,
                      backgroundColor: AppColors.primary,
                      height: 42,
                      width: 140,
                      onPressed: () async {
                        final ok = await ref.read(attendanceProvider.notifier).saveAttendance();
                        if (ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Attendance roster saved successfully!')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSummaryPill({required String label, required int count, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRosterCard(BuildContext context, WidgetRef ref, AttendanceRosterItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isDirty ? AppColors.accent : AppColors.cardBorder,
          width: item.isDirty ? 1.5 : 1,
        ),
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
          // Employee Info Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.fullName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.employeeCode} • ${item.departmentName} • ${item.shiftName}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  item.remarks.isNotEmpty ? Icons.chat_bubble : Icons.chat_bubble_outline,
                  color: item.remarks.isNotEmpty ? AppColors.accentDark : AppColors.textTertiary,
                  size: 20,
                ),
                tooltip: 'Add Remarks',
                onPressed: () => _showRemarksDialog(context, ref, item),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status Button Selector
          Row(
            children: [
              _buildStatusBtn(
                label: 'Present',
                statusKey: 'PRESENT',
                isSelected: item.status == 'PRESENT',
                activeColor: AppColors.success,
                onTap: () => ref.read(attendanceProvider.notifier).setStaffStatus(item.staffId, 'PRESENT'),
              ),
              const SizedBox(width: 6),
              _buildStatusBtn(
                label: 'Half-Day',
                statusKey: 'HALF_DAY',
                isSelected: item.status == 'HALF_DAY',
                activeColor: AppColors.warning,
                onTap: () => ref.read(attendanceProvider.notifier).setStaffStatus(item.staffId, 'HALF_DAY'),
              ),
              const SizedBox(width: 6),
              _buildStatusBtn(
                label: 'Absent',
                statusKey: 'ABSENT',
                isSelected: item.status == 'ABSENT',
                activeColor: AppColors.danger,
                onTap: () => ref.read(attendanceProvider.notifier).setStaffStatus(item.staffId, 'ABSENT'),
              ),
              const SizedBox(width: 6),
              _buildStatusBtn(
                label: 'Leave',
                statusKey: 'LEAVE',
                isSelected: item.status == 'LEAVE',
                activeColor: AppColors.info,
                onTap: () => ref.read(attendanceProvider.notifier).setStaffStatus(item.staffId, 'LEAVE'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Overtime Stepper Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.more_time_rounded, size: 16, color: AppColors.purple),
                    const SizedBox(width: 6),
                    Text(
                      'OT: ${item.overtimeHours.toStringAsFixed(1)} hrs',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.purple,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildOtChip(
                      label: '+0.5h',
                      onTap: () => ref.read(attendanceProvider.notifier).addOvertimeHours(item.staffId, 0.5),
                    ),
                    const SizedBox(width: 6),
                    _buildOtChip(
                      label: '+1.0h',
                      onTap: () => ref.read(attendanceProvider.notifier).addOvertimeHours(item.staffId, 1.0),
                    ),
                    const SizedBox(width: 6),
                    _buildOtChip(
                      label: '+2.0h',
                      onTap: () => ref.read(attendanceProvider.notifier).addOvertimeHours(item.staffId, 2.0),
                    ),
                    if (item.overtimeHours > 0) ...[
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => ref.read(attendanceProvider.notifier).addOvertimeHours(item.staffId, -item.overtimeHours),
                        child: const Icon(Icons.cancel_outlined, size: 18, color: AppColors.danger),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBtn({
    required String label,
    required String statusKey,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.cardBorder,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtChip({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
