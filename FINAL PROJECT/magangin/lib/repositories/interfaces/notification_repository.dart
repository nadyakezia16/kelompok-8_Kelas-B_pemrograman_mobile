import '../../models/app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getMyNotifications();

  Future<void> markAsRead(String id);

  Future<int> unreadCount();
}