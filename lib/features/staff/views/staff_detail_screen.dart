import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../attendance/views/attendance_history_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/staff_model.dart';
import '../providers/staff_provider.dart';
import 'staff_form_screen.dart';

class StaffDetailScreen extends ConsumerStatefulWidget {
  final int staffId;

  const StaffDetailScreen({super.key, required this.staffId});

  @override
  ConsumerState<StaffDetailScreen> createState() => _StaffDetailScreenState();
}

class _StaffDetailScreenState extends ConsumerState<StaffDetailScreen> {
  StaffModel? _staff;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repo = ref.read(staffRepositoryProvider);
    final response = await repo.getStaffDetail(widget.staffId);

    if (response.success && response.data != null) {
      if (mounted) {
        setState(() {
          _staff = response.data;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _error = response.message;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleStatus() async {
    if (_staff == null) return;
    final isDeactivating = _staff!.isActive;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isDeactivating ? 'Deactivate Employee?' : 'Activate Employee?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: Text(
          isDeactivating
              ? 'Are you sure you want to deactivate ${_staff!.fullName}? They will no longer appear on daily rosters.'
              : 'Activate ${_staff!.fullName} to enable attendance marking and payroll calculations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDeactivating ? AppColors.danger : AppColors.success,
            ),
            child: Text(isDeactivating ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final ok = await ref.read(staffProvider.notifier).toggleStaffStatus(_staff!);
      if (ok) {
        await _loadStaff();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isDeactivating ? 'Employee deactivated' : 'Employee activated',
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.user?.isAdmin ?? false;
    final isManagerOrAdmin = authState.user?.isManagerOrAdmin ?? false;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _staff == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Employee Profile')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error ?? 'Staff not found'),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Retry',
                onPressed: _loadStaff,
                width: 120,
              ),
            ],
          ),
        ),
      );
    }

    final staff = _staff!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(staff.employeeCode),
        actions: [
          if (isManagerOrAdmin)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StaffFormScreen(staff: staff),
                  ),
                );
                if (updated == true) {
                  _loadStaff();
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      staff.fullName.isNotEmpty ? staff.fullName[0].toUpperCase() : 'E',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    staff.fullName,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    staff.designation,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  StatusBadge.fromStaffStatus(staff.status),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Compensation & Wage Cards (Admin & Manager View)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.payments_outlined, color: AppColors.accent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Compensation Structure',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoBlock(
                          label: 'Monthly Salary',
                          value: Formatters.formatCurrency(staff.monthlySalary),
                          highlight: true,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoBlock(
                          label: 'Daily Rate (est.)',
                          value: Formatters.formatCurrency(staff.dailySalary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoBlock(
                          label: 'Overtime Rate / hr',
                          value: Formatters.formatCurrency(staff.overtimeRate),
                        ),
                      ),
                      Expanded(
                        child: _buildInfoBlock(
                          label: 'Salary Model',
                          value: staff.salaryType,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Operational & Factory Floor Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.badge_outlined, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Factory Deployment',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Employee Code', staff.employeeCode),
                  const Divider(height: 16),
                  _buildDetailRow('Department', staff.departmentName),
                  const Divider(height: 16),
                  _buildDetailRow('Assigned Shift', staff.shiftName ?? 'Not Assigned'),
                  if (staff.shiftDetail != null) ...[
                    const Divider(height: 16),
                    _buildDetailRow('Shift Timings', staff.shiftDetail!.formattedSchedule),
                  ],
                  const Divider(height: 16),
                  _buildDetailRow('Joining Date', Formatters.formatDate(staff.joiningDate)),
                  const Divider(height: 16),
                  _buildDetailRow('Contact Phone', staff.phone),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Records Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Employee History & Records',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'View Attendance History',
                    icon: Icons.calendar_month_outlined,
                    isOutlined: true,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AttendanceHistoryScreen(
                            initialStaffId: staff.id,
                            initialStaffName: staff.fullName,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Status toggle action (Admin only)
            if (isAdmin) ...[
              CustomButton(
                text: staff.isActive ? 'Deactivate Employee' : 'Activate Employee',
                icon: staff.isActive ? Icons.block_rounded : Icons.check_circle_outline,
                backgroundColor: staff.isActive ? AppColors.danger : AppColors.success,
                onPressed: _toggleStatus,
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBlock({
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: highlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
