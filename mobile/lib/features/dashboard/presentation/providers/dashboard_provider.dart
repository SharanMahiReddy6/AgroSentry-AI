import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/dashboard/data/models/dashboard_models.dart';
import 'package:mobile/features/dashboard/data/repositories/dashboard_repository_impl.dart';

class DashboardNotifier extends StateNotifier<DashboardState> {
  final Ref ref;

  DashboardNotifier(this.ref) : super(const DashboardState()) {
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(dashboardRepositoryProvider);
      
      final results = await Future.wait([
        repo.getRecentScans(),
        repo.getQuickTips(),
      ]);

      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        recentScans: results[0] as List<ScanRecordModel>,
        quickTips: results[1] as List<TipModel>,
      );
    } catch (e) {
      if (!mounted) return;
      if (e is Failure) {
        state = state.copyWith(isLoading: false, error: e.message);
      } else {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref);
});
