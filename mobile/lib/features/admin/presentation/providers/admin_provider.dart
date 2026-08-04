import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';
import 'package:mobile/features/tips/data/models/quick_tip_model.dart';
import 'package:mobile/features/admin/data/repositories/admin_repository.dart';

class AdminState {
  final bool isLoading;
  final String? error;
  final List<dynamic> jobs;
  final List<UserModel> users;
  final List<QuickTipModel> pendingTips;
  final List<String> availableDatasets;

  AdminState({
    this.isLoading = true,
    this.error,
    this.jobs = const [],
    this.users = const [],
    this.pendingTips = const [],
    this.availableDatasets = const [],
  });

  AdminState copyWith({
    bool? isLoading,
    String? error,
    List<dynamic>? jobs,
    List<UserModel>? users,
    List<QuickTipModel>? pendingTips,
    List<String>? availableDatasets,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      jobs: jobs ?? this.jobs,
      users: users ?? this.users,
      pendingTips: pendingTips ?? this.pendingTips,
      availableDatasets: availableDatasets ?? this.availableDatasets,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  final AdminRepository _repository;

  AdminNotifier(this._repository) : super(AdminState()) {
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final futures = await Future.wait([
        _repository.getJobs(),
        _repository.getUsers(),
        _repository.getPendingTips(),
        _repository.getAvailableDatasets(),
      ]);

      state = state.copyWith(
        isLoading: false,
        jobs: futures[0],
        users: futures[1] as List<UserModel>,
        pendingTips: futures[2] as List<QuickTipModel>,
        availableDatasets: futures[3] as List<String>,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> startTraining(String datasetName, int epochs) async {
    await _repository.startTraining(datasetName, epochs);
    await fetchAllData();
  }

  Future<void> uploadDataset(File file, String cropName, bool isFullDataset, String? diseaseName) async {
    await _repository.uploadDataset(file, cropName, isFullDataset, diseaseName);
    await fetchAllData();
  }

  Future<void> deployModel(int jobId) async {
    await _repository.deployModel(jobId);
    await fetchAllData();
  }

  Future<void> approveTip(int tipId) async {
    await _repository.approveTip(tipId);
    state = state.copyWith(
      pendingTips: state.pendingTips.where((t) => t.id != tipId).toList(),
    );
  }

  Future<void> deleteTip(int tipId) async {
    await _repository.deleteTip(tipId);
    state = state.copyWith(
      pendingTips: state.pendingTips.where((t) => t.id != tipId).toList(),
    );
  }

  Future<void> sendNotification(String title, String message, int? userId) async {
    await _repository.sendNotification(title, message, userId);
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(ref.watch(adminRepositoryProvider));
});
