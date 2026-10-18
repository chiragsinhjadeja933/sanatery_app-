import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../../advances/views/advances_list_screen.dart';
import '../../attendance/views/daily_roster_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/views/users_screen.dart';
import '../../departments/views/departments_screen.dart';
import '../../payroll/views/payroll_list_screen.dart';
import '../../shifts/views/shifts_screen.dart';
import '../../staff/views/staff_list_screen.dart';
import 'dashboard_screen.dart';

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to log out of the Sanitary Factory ERP?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final pages = [
      DashboardScreen(onNavigateTab: _onTabTapped),
      const StaffListScreen(),
      const DailyRosterScreen(),
      const AdvancesListScreen(),
      const PayrollListScreen(),
    ];

    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            // Drawer User Header
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppColors.accent,
                child: Text(
                  user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              accountName: Text(
                user?.fullName ?? 'Factory Staff',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              accountEmail: Row(
                children: [
                  StatusBadge(
                    text: user?.role.displayName ?? 'Operator',
                    type: BadgeType.custom,
                    customBgColor: AppColors.accent.withAlpha(50),
                    customTextColor: AppColors.accentLight,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user?.phone ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Navigation Items
            ListTile(
              leading: const Icon(Icons.dashboard_outlined, color: AppColors.textPrimary),
              title: const Text('Overview Dashboard', style: TextStyle(fontWeight: FontWeight.w600)),
              selected: _currentIndex == 0,
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline, color: AppColors.textPrimary),
              title: const Text('Staff Directory', style: TextStyle(fontWeight: FontWeight.w600)),
              selected: _currentIndex == 1,
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.fact_check_outlined, color: AppColors.textPrimary),
              title: const Text('Daily Roster Sheet', style: TextStyle(fontWeight: FontWeight.w600)),
              selected: _currentIndex == 2,
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.request_quote_outlined, color: AppColors.textPrimary),
              title: const Text('Salary Advances', style: TextStyle(fontWeight: FontWeight.w600)),
              selected: _currentIndex == 3,
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.payments_outlined, color: AppColors.textPrimary),
              title: const Text('Factory Payroll', style: TextStyle(fontWeight: FontWeight.w600)),
              selected: _currentIndex == 4,
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 4);
              },
            ),

            const Divider(),

            // Config & Plant management
            ListTile(
              leading: const Icon(Icons.domain_outlined, color: AppColors.textSecondary),
              title: const Text('Departments Configuration'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DepartmentsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule_outlined, color: AppColors.textSecondary),
              title: const Text('Work Shift Schedules'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ShiftsScreen()),
                );
              },
            ),
            if (user?.isAdmin == true) ...[
              ListTile(
                leading: const Icon(Icons.manage_accounts_outlined, color: AppColors.textSecondary),
                title: const Text('User & Role Accounts'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UsersScreen()),
                  );
                },
              ),
            ],

            const Spacer(),
            const Divider(),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
              title: const Text(
                'Log Out',
                style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmLogout();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline_rounded),
            activeIcon: Icon(Icons.people_rounded),
            label: 'Staff',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
            activeIcon: Icon(Icons.fact_check_rounded),
            label: 'Roster',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_quote_outlined),
            activeIcon: Icon(Icons.request_quote_rounded),
            label: 'Advances',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_outlined),
            activeIcon: Icon(Icons.payments_rounded),
            label: 'Payroll',
          ),
        ],
      ),
    );
  }
}
