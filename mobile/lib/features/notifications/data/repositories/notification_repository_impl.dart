import 'package:dio/dio.dart';
import 'package:mobile/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:mobile/features/notifications/data/models/notification_model.dart';
import 'package:mobile/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<NotificationModel>> getNotifications({CancelToken? cancelToken}) async {
    return await _remoteDataSource.getNotifications(cancelToken: cancelToken);
  }

  @override
  Future<void> markAsRead(int notificationId, {CancelToken? cancelToken}) async {
    await _remoteDataSource.markAsRead(notificationId, cancelToken: cancelToken);
  }
}
