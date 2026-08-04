
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:mobile/features/auth/presentation/screens/verify_otp_screen.dart';
import 'package:mobile/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:mobile/features/scan/presentation/screens/scan_screen.dart';
import 'package:mobile/features/scan/presentation/screens/scan_result_screen.dart';
import 'package:mobile/features/history/presentation/screens/history_screen.dart';
import 'package:mobile/features/library/presentation/screens/library_screen.dart';
import 'package:mobile/features/library/presentation/screens/disease_detail_screen.dart';
import 'package:mobile/features/library/data/models/library_disease_model.dart';
import 'package:mobile/features/tips/presentation/screens/tips_screen.dart';
import 'package:mobile/features/tips/presentation/screens/tip_detail_screen.dart';
import 'package:mobile/features/tips/data/models/quick_tip_model.dart';
import 'package:mobile/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:mobile/features/notifications/presentation/screens/notification_detail_screen.dart';
import 'package:mobile/features/notifications/data/models/notification_model.dart';
import 'package:mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:mobile/features/admin/presentation/screens/admin_screen.dart';
import 'package:mobile/core/widgets/app_shell.dart';

class AuthRefreshListenable extends ChangeNotifier {
  AuthRefreshListenable(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, __) {
      notifyListeners();
    });
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = AuthRefreshListenable(ref);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuth = authState.isAuthenticated;
      final isPublicRoute = state.matchedLocation == '/login' || 
                            state.matchedLocation == '/register' ||
                            state.matchedLocation == '/forgot-password' ||
                            state.matchedLocation == '/verify-reset-code' ||
                            state.matchedLocation == '/reset-password';
      final isAdminRoute = state.matchedLocation.startsWith('/admin');

      if (authState.isLoading) return null; // Wait for initialization

      if (!isAuth && !isPublicRoute) {
        return '/login';
      }

      if (isAuth && isPublicRoute) {
        return '/dashboard';
      }

      if (isAdminRoute) {
        final isAdmin = authState.user?.isAdmin ?? false;
        if (!isAdmin) {
          return '/dashboard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-reset-code',
        builder: (context, state) {
          final extraMap = state.extra is Map ? (state.extra as Map) : null;
          final email = (state.extra is String ? state.extra as String : null) ??
              extraMap?['email']?.toString() ??
              state.uri.queryParameters['email'] ??
              '';
          return VerifyOtpScreen(email: email);
        },
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final extraMap = state.extra is Map ? (state.extra as Map) : null;
          final email = extraMap?['email']?.toString() ?? state.uri.queryParameters['email'] ?? '';
          final code = extraMap?['code']?.toString() ?? state.uri.queryParameters['code'] ?? '';
          return ResetPasswordScreen(
            email: email,
            code: code,
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/scan',
                builder: (context, state) => const ScanScreen(),
                routes: [
                  GoRoute(
                    path: 'result',
                    builder: (context, state) => const ScanResultScreen(),
                  ),
                ]
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) {
                      final disease = state.extra as LibraryDiseaseModel;
                      return DiseaseDetailScreen(disease: disease);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/tips',
        builder: (context, state) => const TipsScreen(),
        routes: [
          GoRoute(
            path: 'detail',
            builder: (context, state) {
              final tip = state.extra as QuickTipModel;
              return TipDetailScreen(tip: tip);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
        routes: [
          GoRoute(
            path: 'detail',
            builder: (context, state) {
              final notif = state.extra as NotificationModel;
              return NotificationDetailScreen(notif: notif);
            },
          ),
        ],
      ),
    ],
  );
});
