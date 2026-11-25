
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase/supabase_config.dart';
import '../../models/app_notification.dart';
import '../interfaces/notification_repository.dart';

class SupabaseNotificationRepository
    implements NotificationRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  String get _userId {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    return user.id;
  }

  @override
  Future<List<AppNotification>> getMyNotifications() async {
    final response = await _client
        .from('notifications')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => AppNotification.fromJson(item))
        .toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    final response = await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id)
        .eq('user_id', _userId)
        .select('id');

    if ((response as List).isEmpty) {
      throw Exception('Notifikasi tidak ditemukan.');
    }
  }

  @override
  Future<int> unreadCount() async {
    final response = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', _userId)
        .eq('is_read', false);

    return (response as List).length;
  }
}
