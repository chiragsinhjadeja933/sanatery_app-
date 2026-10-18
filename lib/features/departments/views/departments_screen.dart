import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/department_model.dart';
import '../providers/department_provider.dart';

class DepartmentsScreen extends ConsumerWidget {
  const DepartmentsScreen({super.key});

  void _showAddEditDepartmentDialog(BuildContext context, WidgetRef ref, [DepartmentModel? department]) {
    final nameController = TextEditingController(text: department?.name ?? '');
    final descController = TextEditingController(text: department?.description ?? '');
    bool isActive = department?.isActive ?? true;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                department == null ? 'Add New Department' : 'Edit Department',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              ),
              content: Form(
                key: formKey,
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextField(
                        label: 'Department Name',
                        controller: nameController,
                        hint: 'e.g. Production Floor, QC, Packaging',
                        validator: (v) => Validators.requiredField(v, 'Department Name'),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Description',
                        controller: descController,
                        hint: 'Operational details and scope',
                        maxLines: 3,
                      ),
                      if (department != null) ...[
                        const SizedBox(height: 16),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Is Active', style: TextStyle(fontWeight: FontWeight.w600)),
                          value: isActive,
                          activeThumbColor: AppColors.success,
                          onChanged: (val) => setState(() => isActive = val),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      bool ok;
                      if (department == null) {
                        ok = await ref.read(departmentProvider.notifier).createDepartment(
                              name: nameController.text.trim(),
                              description: descController.text.trim(),
                            );
                      } else {
                        ok = await ref.read(departmentProvider.notifier).updateDepartment(
                              id: department.id,
                              name: nameController.text.trim(),
                              description: descController.text.trim(),
                              isActive: isActive,
                            );
                      }
                      if (ok && context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(department == null ? 'Department created' : 'Department updated')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: Text(department == null ? 'Create' : 'Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deptState = ref.watch(departmentProvider);
    final authState = ref.watch(authProvider);
    final isAdmin = authState.user?.isAdmin ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Factory Departments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(departmentProvider.notifier).fetchDepartments(),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Department'),
              onPressed: () => _showAddEditDepartmentDialog(context, ref),
            )
          : null,
      body: Builder(
        builder: (context) {
          if (deptState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (deptState.errorMessage != null && deptState.departments.isEmpty) {
            return ErrorView(
              message: deptState.errorMessage!,
              onRetry: () => ref.read(departmentProvider.notifier).fetchDepartments(),
            );
          }

          if (deptState.departments.isEmpty) {
            return EmptyStateView(
              title: 'No Departments Found',
              message: 'Get started by creating the first factory floor department.',
              buttonText: isAdmin ? 'Add Department' : null,
              onButtonPressed: isAdmin ? () => _showAddEditDepartmentDialog(context, ref) : null,
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(departmentProvider.notifier).fetchDepartments(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: deptState.departments.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final dept = deptState.departments[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.domain_rounded, color: AppColors.accentDark, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  dept.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge(
                                  text: dept.isActive ? 'Active' : 'Inactive',
                                  type: dept.isActive ? BadgeType.active : BadgeType.inactive,
                                ),
                              ],
                            ),
                            if (dept.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                dept.description,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isAdmin)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                          onPressed: () => _showAddEditDepartmentDialog(context, ref, dept),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
