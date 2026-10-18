import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../staff/providers/staff_provider.dart';
import '../models/attendance_model.dart';
import '../providers/attendance_provider.dart';

class AttendanceHistoryScreen extends ConsumerStatefulWidget {
  final int? initialStaffId;
  final String? initialStaffName;

  const AttendanceHistoryScreen({
    super.key,
    this.initialStaffId,
    this.initialStaffName,
  });

  @override
  ConsumerState<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends ConsumerState<AttendanceHistoryScreen> {
  late int _month;
  late int _year;
  int? _selectedStaffId;
  List<AttendanceRecordModel> _records = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = now.month;
    _year = now.year;
    _selectedStaffId = widget.initialStaffId;
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repo = ref.read(attendanceRepositoryProvider);
    final response = await repo.getAttendanceRecords(
      staffId: _selectedStaffId,
      month: _month,
      year: _year,
    );

    if (response.success && response.data != null) {
      if (mounted) {
        setState(() {
          _records = response.data!;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _month += delta;
      if (_month < 1) {
        _month = 12;
        _year -= 1;
      } else if (_month > 12) {
        _month = 1;
        _year += 1;
      }
    });
    _loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    final staffState = ref.watch(staffProvider);

    int presentCount = _records.where((r) => r.status.toUpperCase() == 'PRESENT').length;
    int halfDayCount = _records.where((r) => r.status.toUpperCase() == 'HALF_DAY').length;
    int absentCount = _records.where((r) => r.status.toUpperCase() == 'ABSENT').length;
    int leaveCount = _records.where((r) => r.status.toUpperCase() == 'LEAVE').length;
    double totalOt = _records.fold(0.0, (sum, r) => sum + r.overtimeHours);
    double totalOtPay = _records.fold(0.0, (sum, r) => sum + r.overtimeAmount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.initialStaffName != null
            ? '${widget.initialStaffName} Attendance'
            : 'Attendance History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecords,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Month / Year Navigator
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, size: 28),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  Formatters.formatMonthYear(_month, _year),
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, size: 28),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
          ),

          // 2. Optional Staff Filter (if not pre-locked to single staff)
          if (widget.initialStaffId == null && staffState.staffList.isNotEmpty) ...[
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: DropdownButtonFormField<int?>(
                initialValue: _selectedStaffId,
                decoration: const InputDecoration(
                  labelText: 'Filter by Employee',
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All Employees'),
                  ),
                  ...staffState.staffList.map((s) {
                    return DropdownMenuItem<int?>(
                      value: s.id,
                      child: Text('${s.fullName} (${s.employeeCode})'),
                    );
                  }),
                ],
                onChanged: (val) {
                  setState(() => _selectedStaffId = val);
                  _loadRecords();
                },
              ),
            ),
          ],

          // 3. Summary KPI Banner
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                _buildMetricPill('Present', '$presentCount', AppColors.success),
                const SizedBox(width: 6),
                _buildMetricPill('Half-Day', '$halfDayCount', AppColors.warning),
                const SizedBox(width: 6),
                _buildMetricPill('Absent', '$absentCount', AppColors.danger),
                const SizedBox(width: 6),
                _buildMetricPill('Leave', '$leaveCount', AppColors.info),
                const SizedBox(width: 6),
                _buildMetricPill('OT', '${totalOt.toStringAsFixed(1)}h', AppColors.purple),
              ],
            ),
          ),

          if (totalOtPay > 0)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.purple.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.purple.withAlpha(40)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.more_time_rounded, size: 16, color: AppColors.purple),
                      SizedBox(width: 6),
                      Text(
                        'Total Overtime Earned',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.purple),
                      ),
                    ],
                  ),
                  Text(
                    Formatters.formatCurrency(totalOtPay),
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.purple,
                    ),
                  ),
                ],
              ),
            ),

          const Divider(height: 1),

          // 4. Attendance Records List
          Expanded(
            child: Builder(
              builder: (context) {
                if (_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_errorMessage != null && _records.isEmpty) {
                  return ErrorView(
                    message: _errorMessage!,
                    onRetry: _loadRecords,
                  );
                }

                if (_records.isEmpty) {
                  return EmptyStateView(
                    title: 'No Logs Found',
                    message: 'No attendance marked for ${Formatters.formatMonthYear(_month, _year)}.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _records.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final record = _records[index];
                    return _buildRecordCard(record);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill(String label, String value, Color color) {
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
              value,
              style: TextStyle(
                fontSize: 13,
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

  Widget _buildRecordCard(AttendanceRecordModel record) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          // Date Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Text(
                  record.dateTime != null ? '${record.dateTime!.day}' : '',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  record.dateTime != null
                      ? Formatters.formatDate(record.date).split(' ')[1]
                      : '',
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      record.staffName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    StatusBadge.fromAttendanceStatus(record.status),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      record.employeeCode,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    if (record.overtimeHours > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.purpleLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '+${record.overtimeHours.toStringAsFixed(1)}h OT (${Formatters.formatCurrency(record.overtimeAmount)})',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.purple,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (record.remarks.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Note: ${record.remarks}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
