import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../providers/user_provider.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  void _showAddUserDialog(BuildContext context, WidgetRef ref) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRole = 'SUPERVISOR';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Create User Account',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      label: 'Username',
                      controller: usernameController,
                      hint: 'e.g. suresh_sup',
                      validator: (v) => Validators.requiredField(v, 'Username'),
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Password (min 6 chars)',
                      controller: passwordController,
                      hint: 'Enter strong password',
                      validator: (v) => Validators.requiredField(v, 'Password'),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'First Name',
                            controller: firstNameController,
                            hint: 'Suresh',
                            validator: (v) => Validators.requiredField(v, 'First Name'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            label: 'Last Name',
                            controller: lastNameController,
                            hint: 'Kumar',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Phone Number',
                      controller: phoneController,
                      hint: '9876543210',
                      keyboardType: TextInputType.phone,
                      validator: Validators.phoneField,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Assigned Role & Permissions',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'SUPERVISOR', child: Text('Floor Supervisor (Mark Attendance)')),
                        DropdownMenuItem(value: 'MANAGER', child: Text('Factory Manager (Manage Staff & Advances)')),
                        DropdownMenuItem(value: 'ADMIN', child: Text('Administrator (Full Access & Payroll)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => selectedRole = val);
                      },
                    ),
                  ],
                ),
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
                  final ok = await ref.read(userProvider.notifier).createUser(
                        username: usernameController.text.trim(),
                        password: passwordController.text.trim(),
                        role: selectedRole,
                        firstName: firstNameController.text.trim(),
                        lastName: lastNameController.text.trim(),
                        phone: phoneController.text.trim(),
                        email: emailController.text.trim(),
                      );
                  if (ok && context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User account created successfully')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('User & Role Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(userProvider.notifier).fetchUsers(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('New User'),
        onPressed: () => _showAddUserDialog(context, ref),
      ),
      body: Builder(
        builder: (context) {
          if (userState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userState.errorMessage != null && userState.users.isEmpty) {
            return ErrorView(
              message: userState.errorMessage!,
              onRetry: () => ref.read(userProvider.notifier).fetchUsers(),
            );
          }

          if (userState.users.isEmpty) {
            return EmptyStateView(
              title: 'No User Accounts',
              message: 'No login accounts created yet.',
              buttonText: 'Add User',
              onButtonPressed: () => _showAddUserDialog(context, ref),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(userProvider.notifier).fetchUsers(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: userState.users.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final user = userState.users[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withAlpha(20),
                        child: Text(
                          user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user.fullName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge(
                                  text: user.role.displayName,
                                  type: BadgeType.custom,
                                  customBgColor: AppColors.accent.withAlpha(25),
                                  customTextColor: AppColors.accentDark,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@${user.username} • Phone: ${user.phone}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
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
