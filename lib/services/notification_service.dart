import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  SupabaseClient get _client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      throw Exception('Supabase not initialized: $e');
    }
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Get current Firebase user
  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  // Send notification to a specific user
  Future<void> sendNotification({
    required String firebaseUid,
    required String title,
    required String message,
    String type = 'post',
  }) async {
    try {
      await _client.from('notifications').insert({
        'firebase_uid': firebaseUid,
        'title': title,
        'message': message,
        'type': type,
        'is_read': false,
      });
      print('Notification sent successfully to user: $firebaseUid');
    } catch (e) {
      print('Error sending notification: $e');
      rethrow;
    }
  }

  // Send notification to multiple users
  Future<void> sendNotificationToMultipleUsers({
    required List<String> firebaseUids,
    required String title,
    required String message,
    String type = 'post',
  }) async {
    try {
      final notifications =
          firebaseUids
              .map(
                (uid) => {
                  'firebase_uid': uid,
                  'title': title,
                  'message': message,
                  'type': type,
                  'is_read': false,
                },
              )
              .toList();

      await _client.from('notifications').insert(notifications);
      print('Notifications sent successfully to ${firebaseUids.length} users');
    } catch (e) {
      print('Error sending notifications: $e');
      rethrow;
    }
  }

  // Send verification notification
  Future<void> sendVerificationNotification({
    required String postOwnerUid,
    required String verifierName,
    required String postMessage,
  }) async {
    await sendNotification(
      firebaseUid: postOwnerUid,
      title: 'Post Verified! 🎉',
      message: '$verifierName verified your post: "$postMessage"',
      type: 'verification',
    );
  }

  // Send rejection notification
  Future<void> sendRejectionNotification({
    required String postOwnerUid,
    required String rejectorName,
    required String postMessage,
  }) async {
    await sendNotification(
      firebaseUid: postOwnerUid,
      title: 'Post Rejected ❌',
      message: '$rejectorName rejected your post: "$postMessage"',
      type: 'rejection',
    );
  }

  // Send post creation notification to other users
  Future<void> sendPostCreationNotification({
    required String postOwnerName,
    required String postMessage,
    required String fetchType,
    String? partnerUserName,
  }) async {
    try {
      // Get all users except the post owner
      final currentUid = currentFirebaseUser?.uid;
      if (currentUid == null) return;

      final response = await _client
          .from('user_profiles')
          .select('firebase_uid')
          .neq('firebase_uid', currentUid);

      if (response.isNotEmpty) {
        final otherUserUids =
            response
                .map<String>((profile) => profile['firebase_uid'] as String)
                .toList();

        String title;
        String message;

        if (fetchType == 'Together' && partnerUserName != null) {
          title = 'New Together Post! 🤝';
          message = '$postOwnerName & $partnerUserName posted: "$postMessage"';
        } else {
          title = 'New Water Fetch Post! 💧';
          message = '$postOwnerName posted: "$postMessage"';
        }

        await sendNotificationToMultipleUsers(
          firebaseUids: otherUserUids,
          title: title,
          message: message,
          type: 'post',
        );
      }
    } catch (e) {
      print('Error sending post creation notifications: $e');
      // Don't rethrow - notifications are not critical for post creation
    }
  }

  // Get user's notifications
  Future<List<Map<String, dynamic>>> getUserNotifications({
    int limit = 50,
    bool unreadOnly = false,
  }) async {
    try {
      final user = currentFirebaseUser;
      if (user == null) return [];

      var query = _client
          .from('notifications')
          .select()
          .eq('firebase_uid', user.uid);

      if (unreadOnly) {
        query = query.eq('is_read', false);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      final user = currentFirebaseUser;
      if (user == null) return;

      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('firebase_uid', user.uid)
          .eq('is_read', false);
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  // Get unread notification count
  Future<int> getUnreadNotificationCount() async {
    try {
      final user = currentFirebaseUser;
      if (user == null) return 0;

      final response = await _client
          .from('notifications')
          .select('id')
          .eq('firebase_uid', user.uid)
          .eq('is_read', false);

      return response.length;
    } catch (e) {
      print('Error getting unread notification count: $e');
      return 0;
    }
  }

  // Delete old notifications (older than 30 days)
  Future<void> cleanupOldNotifications() async {
    try {
      final user = currentFirebaseUser;
      if (user == null) return;

      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      await _client
          .from('notifications')
          .delete()
          .eq('firebase_uid', user.uid)
          .lt('created_at', thirtyDaysAgo.toIso8601String());
    } catch (e) {
      print('Error cleaning up old notifications: $e');
    }
  }
}
