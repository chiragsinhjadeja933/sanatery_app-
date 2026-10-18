import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../../departments/providers/department_provider.dart';
import '../models/staff_model.dart';
import '../providers/staff_provider.dart';
import 'staff_detail_screen.dart';
import 'staff_form_screen.dart';

class StaffListScreen extends ConsumerWidget {
  const StaffListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffState = ref.watch(staffProvider);
    final deptState = ref.watch(departmentProvider);
    final authState = ref.watch(authProvider);
    final isManagerOrAdmin = authState.user?.isManagerOrAdmin ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Staff Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(staffProvider.notifier).fetchStaffList(),
          ),
        ],
      ),
      floatingActionButton: isManagerOrAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Add Staff'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StaffFormScreen()),
                );
              },
            )
          : null,
      body: Column(
        children: [
          // Search & Department Filter Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Search Input
                TextField(
                  onChanged: (val) => ref.read(staffProvider.notifier).updateSearch(val),
                  decoration: InputDecoration(
                    hintText: 'Search by name, code (EMP001), designation...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Department filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All Depts'),
                        selected: staffState.filter.departmentId == null,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: staffState.filter.departmentId == null ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        onSelected: (_) => ref.read(staffProvider.notifier).updateDepartmentFilter(null),
                      ),
                      const SizedBox(width: 8),
                      ...deptState.departments.map((dept) {
                        final isSelected = staffState.filter.departmentId == dept.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(dept.name),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            onSelected: (_) => ref.read(staffProvider.notifier).updateDepartmentFilter(isSelected ? null : dept.id),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Staff List Content
          Expanded(
            child: Builder(
              builder: (context) {
                if (staffState.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (staffState.errorMessage != null && staffState.staffList.isEmpty) {
                  return ErrorView(
                    message: staffState.errorMessage!,
                    onRetry: () => ref.read(staffProvider.notifier).fetchStaffList(),
                  );
                }

                if (staffState.staffList.isEmpty) {
                  return EmptyStateView(
                    title: 'No Staff Found',
                    message: 'No employee records matching your current filter criteria.',
                    buttonText: isManagerOrAdmin ? 'Register Employee' : null,
                    onButtonPressed: isManagerOrAdmin
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const StaffFormScreen()),
                            );
                          }
                        : null,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(staffProvider.notifier).fetchStaffList(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: staffState.staffList.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final staff = staffState.staffList[index];
                      return _buildStaffCard(context, staff);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(BuildContext context, StaffModel staff) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StaffDetailScreen(staffId: staff.id)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withAlpha(20),
              child: Text(
                staff.fullName.isNotEmpty ? staff.fullName[0].toUpperCase() : 'E',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          staff.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      StatusBadge.fromStaffStatus(staff.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Text(
                          staff.employeeCode,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        staff.designation,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.domain_outlined, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        staff.departmentName,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.schedule_outlined, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        staff.shiftName ?? 'No Shift',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
