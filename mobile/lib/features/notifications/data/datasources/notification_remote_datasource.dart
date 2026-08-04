import 'package:dio/dio.dart';
import 'package:mobile/features/notifications/data/models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({CancelToken? cancelToken});
  Future<void> markAsRead(int notificationId, {CancelToken? cancelToken});
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio _dio;

  NotificationRemoteDataSourceImpl(this._dio);

  @override
  Future<List<NotificationModel>> getNotifications({CancelToken? cancelToken}) async {
    final response = await _dio.get(
      '/notifications',
      cancelToken: cancelToken,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  @override
  Future<void> markAsRead(int notificationId, {CancelToken? cancelToken}) async {
    final response = await _dio.put(
      '/notifications/$notificationId/read',
      cancelToken: cancelToken,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }
}
