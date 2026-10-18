import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/views/login_screen.dart';
import 'features/dashboard/views/main_navigation_shell.dart';

class SanitaryApp extends ConsumerWidget {
  const SanitaryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Sanitary & Ceramic Factory ERP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Builder(
        builder: (context) {
          if (authState.status == AuthStatus.initial) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (authState.status == AuthStatus.authenticated) {
            return const MainNavigationShell();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
