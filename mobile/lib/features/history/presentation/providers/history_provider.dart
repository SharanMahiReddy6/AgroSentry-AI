import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/scan/data/models/scan_history_model.dart';
import 'package:mobile/features/scan/data/repositories/scan_repository_impl.dart';

class HistoryState {
  final List<ScanHistoryModel> history;
  final bool isLoading;
  final String? error;
  final bool isDeleting;
  final String? deleteError;
  final int? deletingScanId;

  const HistoryState({
    this.history = const [],
    this.isLoading = false,
    this.error,
    this.isDeleting = false,
    this.deleteError,
    this.deletingScanId,
  });

  HistoryState copyWith({
    List<ScanHistoryModel>? history,
    bool? isLoading,
    String? error,
    bool? isDeleting,
    String? deleteError,
    int? deletingScanId,
    bool clearError = false,
    bool clearDeleteError = false,
    bool clearDeletingScanId = false,
  }) {
    return HistoryState(
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isDeleting: isDeleting ?? this.isDeleting,
      deleteError: clearDeleteError ? null : (deleteError ?? this.deleteError),
      deletingScanId: clearDeletingScanId ? null : (deletingScanId ?? this.deletingScanId),
    );
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final Ref _ref;
  CancelToken? _cancelToken;

  HistoryNotifier(this._ref) : super(const HistoryState()) {
    fetchHistory();
  }

  @override
  void dispose() {
    _cancelToken?.cancel('Notifier disposed');
    super.dispose();
  }

  Future<void> fetchHistory({bool isRefresh = false}) async {
    if (state.isLoading && !isRefresh) return;

    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repository = _ref.read(scanRepositoryProvider);
      final history = await repository.getHistory(_cancelToken!);
      if (!mounted) return;
      state = state.copyWith(isLoading: false, history: history);
    } catch (e) {
      if (!mounted) return;
      if (e is Failure && e.message.contains('cancelled')) {
        state = state.copyWith(isLoading: false);
        return;
      }
      state = state.copyWith(
        isLoading: false,
        error: e is Failure ? e.message : 'An unexpected error occurred',
      );
    }
  }

  Future<bool> deleteScan(int scanId) async {
    if (state.isDeleting) return false;

    // Optimistic delete
    final previousHistory = List<ScanHistoryModel>.from(state.history);
    final updatedHistory = state.history.where((s) => s.id != scanId).toList();

    state = state.copyWith(
      isDeleting: true,
      deletingScanId: scanId,
      clearDeleteError: true,
      history: updatedHistory,
    );

    try {
      final repository = _ref.read(scanRepositoryProvider);
      await repository.deleteScan(scanId);

      if (!mounted) return true;
      state = state.copyWith(
        isDeleting: false,
        clearDeletingScanId: true,
      );
      return true;
    } catch (e) {
      if (!mounted) return false;

      // Rollback
      state = state.copyWith(
        isDeleting: false,
        clearDeletingScanId: true,
        deleteError: e is Failure ? e.message : 'Failed to delete scan',
        history: previousHistory,
      );
      return false;
    }
  }
}

final historyProvider = StateNotifierProvider.autoDispose<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier(ref);
});
