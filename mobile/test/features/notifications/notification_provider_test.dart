import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:mobile/features/notifications/data/models/notification_model.dart';
import 'package:mobile/features/notifications/presentation/providers/notification_provider.dart';

class MockNotificationRemoteDataSource implements NotificationRemoteDataSource {
  int callCount = 0;
  int markReadCount = 0;
  bool shouldThrow = false;
  CancelToken? lastCancelToken;

  final List<NotificationModel> mockNotifications = const [
    NotificationModel(
      id: 1,
      title: 'Scan Complete',
      message: 'Your scan for Tomato is complete.',
      userId: 1,
      isRead: false,
      createdAt: '2023-10-27 10:00:00',
    ),
    NotificationModel(
      id: 2,
      title: 'Critical Alert',
      message: 'Blight detected nearby.',
      userId: 1,
      isRead: false,
      createdAt: '2023-10-26 08:00:00',
    ),
    NotificationModel(
      id: 3,
      title: 'Welcome',
      message: 'Welcome to AgroSentry',
      userId: null,
      isRead: true,
      createdAt: '2023-10-25 10:00:00',
    ),
  ];

  @override
  Future<List<NotificationModel>> getNotifications({CancelToken? cancelToken}) async {
    callCount++;
    lastCancelToken = cancelToken;
    if (shouldThrow) {
      throw Exception('Failed');
    }
    return mockNotifications;
  }

  @override
  Future<void> markAsRead(int notificationId, {CancelToken? cancelToken}) async {
    markReadCount++;
    if (shouldThrow) {
      throw Exception('Failed to mark read');
    }
  }
}

void main() {
  late ProviderContainer container;
  late MockNotificationRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockNotificationRemoteDataSource();
    container = ProviderContainer(
      overrides: [
        notificationRemoteDataSourceProvider.overrideWithValue(mockDataSource),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('notificationsProvider loads data correctly', () async {
    final sub = container.listen(notificationsProvider, (_, __) {});
    final notifier = container.read(notificationsProvider.notifier);
    await notifier.loadNotifications();
    
    final state = container.read(notificationsProvider);
    expect(state.value?.length, 3);
    
    sub.close();
  });

  test('notificationsProvider markAsRead updates state and calls API', () async {
    final sub = container.listen(notificationsProvider, (_, __) {});
    final notifier = container.read(notificationsProvider.notifier);
    await notifier.loadNotifications();
    
    await notifier.markAsRead(1);
    
    final state = container.read(notificationsProvider);
    
    final notif1 = state.value!.firstWhere((n) => n.id == 1);
    expect(notif1.isRead, true);
    expect(mockDataSource.markReadCount, 1);
  });

  test('unreadNotificationsCountProvider returns correct count', () async {
    final sub = container.listen(notificationsProvider, (_, __) {});
    final notifier = container.read(notificationsProvider.notifier);
    await notifier.loadNotifications();
    
    var unreadCount = container.read(unreadNotificationsCountProvider);
    expect(unreadCount, 2); // IDs 1 and 2 are false
    
    // Mark one as read
    await notifier.markAsRead(1);
    
    unreadCount = container.read(unreadNotificationsCountProvider);
    expect(unreadCount, 1);
  });

  test('markAllAsRead updates state for all unread and calls API', () async {
    final sub = container.listen(notificationsProvider, (_, __) {});
    final notifier = container.read(notificationsProvider.notifier);
    await notifier.loadNotifications();
    
    await notifier.markAllAsRead();
    
    final state = container.read(notificationsProvider);
    expect(state.value!.every((n) => n.isRead), true);
    
    // There were 2 unread, so markRead API should be called twice
    expect(mockDataSource.markReadCount, 2);
  });
}
