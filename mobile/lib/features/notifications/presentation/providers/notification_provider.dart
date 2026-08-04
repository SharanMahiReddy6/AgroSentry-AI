import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:mobile/features/notifications/data/models/notification_model.dart';
import 'package:mobile/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:mobile/features/notifications/domain/repositories/notification_repository.dart';
import 'package:mobile/core/network/translation_service.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';

final notificationRemoteDataSourceProvider = Provider<NotificationRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return NotificationRemoteDataSourceImpl(dio);
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final remoteDataSource = ref.watch(notificationRemoteDataSourceProvider);
  return NotificationRepositoryImpl(remoteDataSource);
});

final notificationsProvider = StateNotifierProvider.autoDispose<NotificationsNotifier, AsyncValue<List<NotificationModel>>>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  
  // Keep alive for session caching
  ref.keepAlive();
  
  return NotificationsNotifier(repository, ref);
});

class NotificationsNotifier extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationRepository _repository;
  final Ref _ref;
  CancelToken? _cancelToken;

  NotificationsNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    try {
      state = const AsyncValue.loading();
      final notifications = await _repository.getNotifications(cancelToken: _cancelToken);
      
      final targetLang = _ref.read(authProvider).user?.language ?? 'en';
      final translationService = _ref.read(translationServiceProvider);
      
      final translated = <NotificationModel>[];
      for (final n in notifications) {
        if (targetLang == 'en') {
          translated.add(n);
        } else {
          translated.add(n.copyWith(
            title: await translationService.translateText(n.title, targetLang),
            message: await translationService.translateText(n.message, targetLang),
          ));
        }
      }
      
      state = AsyncValue.data(translated);
    } catch (e, stackTrace) {
      if (e is DioException && CancelToken.isCancel(e)) {
        return;
      }
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final currentState = state;
    if (currentState is! AsyncData<List<NotificationModel>>) return;

    final currentNotifications = currentState.value;
    final index = currentNotifications.indexWhere((n) => n.id == notificationId);
    
    if (index == -1 || currentNotifications[index].isRead) return;

    // Optimistic update
    final updatedNotifications = List<NotificationModel>.from(currentNotifications);
    updatedNotifications[index] = updatedNotifications[index].copyWith(isRead: true);
    state = AsyncValue.data(updatedNotifications);

    try {
      await _repository.markAsRead(notificationId);
    } catch (e) {
      // Revert on failure
      state = currentState;
    }
  }

  Future<void> markAllAsRead() async {
    final currentState = state;
    if (currentState is! AsyncData<List<NotificationModel>>) return;

    final unreadNotifications = currentState.value.where((n) => !n.isRead).toList();
    if (unreadNotifications.isEmpty) return;

    // Optimistic update
    final updatedNotifications = currentState.value.map((n) => n.copyWith(isRead: true)).toList();
    state = AsyncValue.data(updatedNotifications);

    try {
      await Future.wait(
        unreadNotifications.map((n) => _repository.markAsRead(n.id))
      );
    } catch (e) {
      // Revert on failure
      state = currentState;
    }
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }
}

final unreadNotificationsCountProvider = Provider.autoDispose<int>((ref) {
  final notificationsState = ref.watch(notificationsProvider);
  return notificationsState.maybeWhen(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});
