import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../advances/views/add_advance_modal.dart';
import '../../attendance/views/daily_roster_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../departments/views/departments_screen.dart';
import '../../shifts/views/shifts_screen.dart';
import '../../staff/views/staff_form_screen.dart';
import '../models/dashboard_kpi_model.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  final Function(int)? onNavigateTab;

  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashState = ref.watch(dashboardProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.factory_outlined, color: AppColors.accent, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Factory Dashboard',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Metrics',
            onPressed: () => ref.read(dashboardProvider.notifier).fetchKpis(),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
            tooltip: 'Sign Out / Switch User',
            onPressed: () => _confirmLogout(context, ref, user),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (dashState.isLoading && dashState.kpis == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dashState.errorMessage != null && dashState.kpis == null) {
            return ErrorView(
              message: dashState.errorMessage!,
              onRetry: () => ref.read(dashboardProvider.notifier).fetchKpis(),
            );
          }

          final kpis = dashState.kpis;
          if (kpis == null) {
            return const Center(child: Text('No KPI metrics available.'));
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(dashboardProvider.notifier).fetchKpis(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Executive Welcome Header
                  _buildWelcomeHeader(context, ref, user, kpis),
                  const SizedBox(height: 20),

                  // 2. Today's Attendance Progress Card
                  _buildAttendanceLiveCard(context, kpis),
                  const SizedBox(height: 20),

                  // 3. Quick Action Shortcuts Grid
                  Text(
                    'Quick Operational Actions',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActions(context),
                  const SizedBox(height: 20),

                  // 4. Monthly Financial & Payroll Snapshot
                  _buildPayrollOverviewCard(context, kpis),
                  const SizedBox(height: 20),

                  // 5. Plant & Department Overview Metrics
                  Text(
                    'Plant & Staff Capacity',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          title: 'Active Workers',
                          value: '${kpis.totalActiveStaff}',
                          subtitle: '${kpis.totalInactiveStaff} inactive',
                          icon: Icons.people_outline_rounded,
                          iconColor: AppColors.primary,
                          onTap: () => onNavigateTab?.call(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MetricCard(
                          title: 'Floor Depts',
                          value: '${kpis.totalDepartments}',
                          subtitle: '${kpis.totalShifts} active shifts',
                          icon: Icons.domain_rounded,
                          iconColor: AppColors.accentDark,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const DepartmentsScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, WidgetRef ref, dynamic user, DashboardKpiModel kpis) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(50),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.accent.withAlpha(40),
                    child: Text(
                      user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withAlpha(180),
                        ),
                      ),
                      Text(
                        user?.fullName ?? 'User',
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  StatusBadge(
                    text: user?.role.displayName ?? 'Staff',
                    type: BadgeType.custom,
                    customBgColor: AppColors.accent.withAlpha(40),
                    customTextColor: AppColors.accentLight,
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _confirmLogout(context, ref, user),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withAlpha(40),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.danger.withAlpha(100)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout_rounded, size: 14, color: Color(0xFFFF8A80)),
                          SizedBox(width: 4),
                          Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF8A80),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.today_rounded, size: 16, color: AppColors.accent),
                  const SizedBox(width: 6),
                  Text(
                    Formatters.formatDate(kpis.todayDate.isNotEmpty ? kpis.todayDate : DateTime.now().toString()),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                'Shift Operations Live',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.successLight.withAlpha(200),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceLiveCard(BuildContext context, DashboardKpiModel kpis) {
    final ratePercent = (kpis.attendanceRate * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Floor Attendance',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${kpis.presentToday} of ${kpis.totalActiveStaff} workers on site',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$ratePercent% Turnout',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.successDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Linear Attendance Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: kpis.attendanceRate.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: AppColors.cardBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
          ),
          const SizedBox(height: 16),

          // Stats Counters
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAttendanceMetric('Present', '${kpis.presentToday}', AppColors.success),
              _buildAttendanceMetric('Half-Day', '${kpis.halfDayToday}', AppColors.warning),
              _buildAttendanceMetric('Absent', '${kpis.absentToday}', AppColors.danger),
              _buildAttendanceMetric('Leave', '${kpis.leaveToday}', AppColors.info),
              _buildAttendanceMetric('OT Hours', '${kpis.todayOtHours.toStringAsFixed(1)}h', AppColors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            title: 'Mark Roster',
            icon: Icons.fact_check_outlined,
            color: AppColors.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DailyRosterScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionCard(
            context,
            title: 'Add Staff',
            icon: Icons.person_add_outlined,
            color: AppColors.infoDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StaffFormScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionCard(
            context,
            title: 'Advance ₹',
            icon: Icons.request_quote_outlined,
            color: AppColors.warningDark,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) => const AddAdvanceModal(),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionCard(
            context,
            title: 'Shifts',
            icon: Icons.schedule_rounded,
            color: AppColors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShiftsScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayrollOverviewCard(BuildContext context, DashboardKpiModel kpis) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payroll & Advance Ledger',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                Formatters.formatMonthYear(kpis.payrollMonth, kpis.payrollYear),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Net Wage Budget',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.formatCurrency(kpis.totalNetPayroll),
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${kpis.finalizedPayrollCount} finalized • ${kpis.draftPayrollCount} draft',
                        style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Advances Disbursed',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.formatCurrency(kpis.totalAdvancesDisbursed),
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.warningDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Auto-deducted from salary',
                        style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref, dynamic user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.danger.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 22),
            ),
            const SizedBox(width: 12),
            Text('Sign Out', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to log out of the Sanitary Factory ERP?',
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_circle_outlined, size: 20, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? user?.username ?? 'Current User',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Role: ${user?.role.displayName ?? "Operator"}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
