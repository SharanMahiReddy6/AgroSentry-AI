import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/data/models/auth_requests.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mobile/core/network/dio_client.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AuthState()) {
    checkSession();
  }

  Future<void> checkSession() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      final loggedIn = await repo.isLoggedIn();
      if (!mounted) return;
      
      if (loggedIn) {
        final user = await repo.getCurrentUser();
        if (!mounted) return;
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
      } else {
        if (!mounted) return;
        state = state.copyWith(isLoading: false, isAuthenticated: false);
      }
    } catch (e) {
      if (!mounted) return;
      try {
        await logout();
      } catch (_) {
        if (mounted) {
          state = const AuthState(isAuthenticated: false);
        }
      }
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.login(email, password);
      await checkSession();
    } catch (e) {
      if (mounted) state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> register(RegisterRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.register(request);
      await checkSession();
    } catch (e) {
      if (mounted) state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.forgotPassword(ForgotPasswordRequest(email: email));
      if (mounted) state = state.copyWith(isLoading: false);
    } catch (e) {
      if (mounted) state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> verifyOtp(String email, String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.verifyOtp(VerifyOtpRequest(email: email, code: code));
      if (mounted) state = state.copyWith(isLoading: false);
    } catch (e) {
      if (mounted) state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> resetPassword(String email, String code, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.resetPassword(ResetPasswordRequest(email: email, code: code, newPassword: newPassword));
      if (mounted) state = state.copyWith(isLoading: false);
    } catch (e) {
      if (mounted) state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.logout();
    } catch (_) {}
    if (!mounted) return;
    try {
      ref.invalidate(dioClientProvider); // Drop stale connections
    } catch (_) {}
    if (mounted) {
      state = const AuthState(isAuthenticated: false);
    }
  }

  void updateUser(UserModel user) {
    if (mounted) {
      state = state.copyWith(user: user);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});
