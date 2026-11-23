import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/admin/presentation/screens/admin_shell.dart';
import '../../features/auth/application/auth_notifier.dart';
import '../../features/auth/presentation/screens/admin_login_screen.dart';
import '../../features/auth/presentation/screens/admin_profile_screen.dart';
import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/kiosk/presentation/screens/kiosk_screen.dart';
import '../../features/students/presentation/screens/students_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'kiosk',
        builder: (context, state) => const KioskScreen(),
      ),
      GoRoute(
        path: '/admin/login',
        name: 'adminLogin',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin/inventory',
            name: 'adminInventory',
            builder: (context, state) => const InventoryScreen(),
          ),
          GoRoute(
            path: '/admin/students',
            name: 'adminStudents',
            builder: (context, state) => const StudentsScreen(),
          ),
          GoRoute(
            path: '/admin/profile',
            name: 'adminProfile',
            builder: (context, state) => const AdminProfileScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/admin/login';
      final isAdminArea = state.matchedLocation.startsWith('/admin') && !isLoggingIn;

      if (isAdminArea && !authState.isAuthenticated) {
        return '/admin/login';
      }
      if (isLoggingIn && authState.isAuthenticated) {
        return '/admin/inventory';
      }
      return null;
    },
  );
}
