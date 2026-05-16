import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AgroSenseApp()));
}

class AgroSenseApp extends ConsumerWidget {
  const AgroSenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authProvider);

    return MaterialApp(
      title: 'AgroSense',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: authAsync.when(
        loading: () => const _SplashScreen(),
        error: (_, __) => const LoginScreen(),
        data: (status) => status == AuthStatus.authenticated
            ? const DashboardScreen()
            : const LoginScreen(),
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}
