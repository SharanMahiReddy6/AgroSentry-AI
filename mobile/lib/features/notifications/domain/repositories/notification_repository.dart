import 'package:dio/dio.dart';
import 'package:mobile/features/notifications/data/models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications({CancelToken? cancelToken});
  Future<void> markAsRead(int notificationId, {CancelToken? cancelToken});
}
