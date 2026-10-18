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
import '../models/shift_model.dart';
import '../providers/shift_provider.dart';

class ShiftsScreen extends ConsumerWidget {
  const ShiftsScreen({super.key});

  void _showAddEditShiftDialog(BuildContext context, WidgetRef ref, [ShiftModel? shift]) {
    final nameController = TextEditingController(text: shift?.name ?? '');
    final startTimeController = TextEditingController(text: shift?.startTime ?? '08:00:00');
    final endTimeController = TextEditingController(text: shift?.endTime ?? '16:00:00');
    bool isActive = shift?.isActive ?? true;
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
                shift == null ? 'Add Shift Schedule' : 'Edit Shift Schedule',
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
                        label: 'Shift Name',
                        controller: nameController,
                        hint: 'e.g. Morning Shift, Night Shift',
                        validator: (v) => Validators.requiredField(v, 'Shift Name'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Start Time (HH:MM)',
                              controller: startTimeController,
                              hint: '08:00:00',
                              validator: (v) => Validators.requiredField(v, 'Start Time'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              label: 'End Time (HH:MM)',
                              controller: endTimeController,
                              hint: '16:00:00',
                              validator: (v) => Validators.requiredField(v, 'End Time'),
                            ),
                          ),
                        ],
                      ),
                      if (shift != null) ...[
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
                      if (shift == null) {
                        ok = await ref.read(shiftProvider.notifier).createShift(
                              name: nameController.text.trim(),
                              startTime: startTimeController.text.trim(),
                              endTime: endTimeController.text.trim(),
                            );
                      } else {
                        ok = await ref.read(shiftProvider.notifier).updateShift(
                              id: shift.id,
                              name: nameController.text.trim(),
                              startTime: startTimeController.text.trim(),
                              endTime: endTimeController.text.trim(),
                              isActive: isActive,
                            );
                      }
                      if (ok && context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(shift == null ? 'Shift created' : 'Shift updated')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: Text(shift == null ? 'Create' : 'Save Changes'),
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
    final shiftState = ref.watch(shiftProvider);
    final authState = ref.watch(authProvider);
    final isAdmin = authState.user?.isAdmin ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Work Shifts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(shiftProvider.notifier).fetchShifts(),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Shift'),
              onPressed: () => _showAddEditShiftDialog(context, ref),
            )
          : null,
      body: Builder(
        builder: (context) {
          if (shiftState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (shiftState.errorMessage != null && shiftState.shifts.isEmpty) {
            return ErrorView(
              message: shiftState.errorMessage!,
              onRetry: () => ref.read(shiftProvider.notifier).fetchShifts(),
            );
          }

          if (shiftState.shifts.isEmpty) {
            return EmptyStateView(
              title: 'No Shifts Configured',
              message: 'Set up working shift hours (Morning, Evening, Night).',
              buttonText: isAdmin ? 'Add Shift' : null,
              onButtonPressed: isAdmin ? () => _showAddEditShiftDialog(context, ref) : null,
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(shiftProvider.notifier).fetchShifts(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: shiftState.shifts.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final shift = shiftState.shifts[index];
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
                          color: AppColors.purple.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.access_time_filled_rounded, color: AppColors.purple, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  shift.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge(
                                  text: shift.isActive ? 'Active' : 'Inactive',
                                  type: shift.isActive ? BadgeType.active : BadgeType.inactive,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Timing: ${shift.formattedSchedule}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isAdmin)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                          onPressed: () => _showAddEditShiftDialog(context, ref, shift),
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
