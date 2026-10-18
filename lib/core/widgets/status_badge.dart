import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum BadgeType { present, absent, halfDay, leave, active, inactive, draft, finalized, approved, pending, rejected, custom }

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeType type;
  final Color? customBgColor;
  final Color? customTextColor;
  final double fontSize;
  final EdgeInsets padding;

  const StatusBadge({
    super.key,
    required this.text,
    required this.type,
    this.customBgColor,
    this.customTextColor,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  factory StatusBadge.fromAttendanceStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'PRESENT':
        return const StatusBadge(text: 'Present', type: BadgeType.present);
      case 'ABSENT':
        return const StatusBadge(text: 'Absent', type: BadgeType.absent);
      case 'HALF_DAY':
        return const StatusBadge(text: 'Half-Day', type: BadgeType.halfDay);
      case 'LEAVE':
        return const StatusBadge(text: 'Leave', type: BadgeType.leave);
      default:
        return const StatusBadge(text: 'Unmarked', type: BadgeType.custom, customBgColor: Color(0xFFF1F5F9), customTextColor: Color(0xFF64748B));
    }
  }

  factory StatusBadge.fromStaffStatus(String? status) {
    if (status?.toUpperCase() == 'ACTIVE') {
      return const StatusBadge(text: 'Active', type: BadgeType.active);
    }
    return const StatusBadge(text: 'Inactive', type: BadgeType.inactive);
  }

  factory StatusBadge.fromPayrollStatus(String? status) {
    if (status?.toUpperCase() == 'FINALIZED' || status?.toUpperCase() == 'PAID') {
      return const StatusBadge(text: 'Finalized', type: BadgeType.finalized);
    }
    return const StatusBadge(text: 'Draft', type: BadgeType.draft);
  }

  factory StatusBadge.fromAdvanceStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'APPROVED':
        return const StatusBadge(text: 'Approved', type: BadgeType.approved);
      case 'REJECTED':
        return const StatusBadge(text: 'Rejected', type: BadgeType.rejected);
      default:
        return const StatusBadge(text: 'Pending', type: BadgeType.pending);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case BadgeType.present:
      case BadgeType.active:
      case BadgeType.finalized:
      case BadgeType.approved:
        bg = AppColors.successLight;
        fg = AppColors.successDark;
        break;

      case BadgeType.halfDay:
      case BadgeType.draft:
      case BadgeType.pending:
        bg = AppColors.warningLight;
        fg = AppColors.warningDark;
        break;

      case BadgeType.absent:
      case BadgeType.inactive:
      case BadgeType.rejected:
        bg = AppColors.dangerLight;
        fg = AppColors.dangerDark;
        break;

      case BadgeType.leave:
        bg = AppColors.infoLight;
        fg = AppColors.infoDark;
        break;

      case BadgeType.custom:
        bg = customBgColor ?? AppColors.cardBorder;
        fg = customTextColor ?? AppColors.textSecondary;
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
