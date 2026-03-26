import 'package:get/get.dart';
import '../../models/notification_model.dart';
import '../../service/notification/notification_service.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService = NotificationService();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      notifications.value = await _notificationService.getNotifications();
      unreadCount.value = await _notificationService.getUnreadCount();
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
    await loadNotifications();
  }

  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
    await loadNotifications();
  }

  Future<void> clearAll() async {
    await _notificationService.clearAll();
    await loadNotifications();
  }

  Future<void> checkForNewJobs(int currentJobCount) async {
    await _notificationService.checkForNewJobs(currentJobCount);
    await loadNotifications();
  }
}
