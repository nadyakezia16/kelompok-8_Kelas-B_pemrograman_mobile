
import '../../models/app_notification.dart';
import '../interfaces/notification_repository.dart';

class MockNotificationRepository
    implements NotificationRepository {
  final List<AppNotification> _notifications = [
    AppNotification(
      id: 'notification-001',
      userId: 'student-001',
      title: 'Lamaran berhasil dikirim',
      body: 'Lamaran magang Software Developer berhasil dikirim.',
      isRead: false,
      applicationId: 'application-001',
      createdAt: DateTime(2026, 11, 23, 10, 30),
    ),
    AppNotification(
      id: 'notification-002',
      userId: 'student-001',
      title: 'Lamaran sedang diproses',
      body: 'Perusahaan sedang meninjau lamaran magang kamu.',
      isRead: false,
      applicationId: 'application-002',
      createdAt: DateTime(2026, 11, 23, 14, 15),
    ),
    AppNotification(
      id: 'notification-003',
      userId: 'student-001',
      title: 'Selamat datang di Magangin!',
      body: 'Lengkapi profil dan dokumenmu untuk mulai melamar.',
      isRead: true,
      createdAt: DateTime(2026, 11, 20, 9, 0),
    ),
  ];

  @override
  Future<List<AppNotification>> getMyNotifications() async {
    return List.unmodifiable(
      _notifications.where(
            (notification) => notification.userId == 'student-001',
      ),
    );
  }

  @override
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere(
          (notification) => notification.id == id,
    );

    if (index == -1) {
      throw Exception('Notifikasi tidak ditemukan.');
    }

    final notification = _notifications[index];

    _notifications[index] = AppNotification(
      id: notification.id,
      userId: notification.userId,
      title: notification.title,
      body: notification.body,
      isRead: true,
      applicationId: notification.applicationId,
      createdAt: notification.createdAt,
    );
  }

  @override
  Future<int> unreadCount() async {
    return _notifications
        .where(
          (notification) =>
      notification.userId == 'student-001' &&
          !notification.isRead,
    )
        .length;
  }
}
