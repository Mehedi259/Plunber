import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/notification_model.dart';

class NotificationService {
  static const String _notificationsKey = 'local_notifications';
  static const String _lastJobCountKey = 'last_job_count';

  // Save notifications locally
  Future<void> saveNotifications(List<NotificationModel> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = notifications.map((n) => n.toJson()).toList();
    await prefs.setString(_notificationsKey, jsonEncode(notificationsJson));
  }

  // Get all notifications
  Future<List<NotificationModel>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsString = prefs.getString(_notificationsKey);
    
    if (notificationsString == null) {
      return [];
    }

    final List<dynamic> notificationsJson = jsonDecode(notificationsString);
    return notificationsJson
        .map((json) => NotificationModel.fromJson(json))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Latest first
  }

  // Add a new notification
  Future<void> addNotification(NotificationModel notification) async {
    final notifications = await getNotifications();
    notifications.insert(0, notification);
    
    // Keep only last 50 notifications
    if (notifications.length > 50) {
      notifications.removeRange(50, notifications.length);
    }
    
    await saveNotifications(notifications);
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final notifications = await getNotifications();
    final index = notifications.indexWhere((n) => n.id == notificationId);
    
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      await saveNotifications(notifications);
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    final notifications = await getNotifications();
    final updatedNotifications = notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    await saveNotifications(updatedNotifications);
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => !n.isRead).length;
  }

  // Clear all notifications
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);
  }

  // Check for new jobs and create notifications
  Future<void> checkForNewJobs(int currentJobCount) async {
    final prefs = await SharedPreferences.getInstance();
    final lastJobCount = prefs.getInt(_lastJobCountKey) ?? 0;

    if (currentJobCount > lastJobCount) {
      final newJobsCount = currentJobCount - lastJobCount;
      
      // Create notification for new jobs
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'New Job${newJobsCount > 1 ? 's' : ''} Available',
        message: newJobsCount > 1
            ? 'You have $newJobsCount new jobs assigned to you.'
            : 'There is a new job available for you.',
        type: 'new_job',
        timestamp: DateTime.now(),
        data: {'count': newJobsCount},
      );

      await addNotification(notification);
    }

    // Update last job count
    await prefs.setInt(_lastJobCountKey, currentJobCount);
  }

  // Reset job count (call on first app launch)
  Future<void> resetJobCount(int currentCount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastJobCountKey, currentCount);
  }
}
