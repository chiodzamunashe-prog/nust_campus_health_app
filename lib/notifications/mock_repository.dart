import 'models.dart';
import 'notification_service.dart';
import 'repository.dart';
import 'mock_service.dart';

class MockNotificationsRepository implements NotificationsRepository {
  final MockNotificationsService _mockService = MockNotificationsService();
  final AppNotificationService _notificationService =
      AppNotificationService.instance;

  @override
  Stream<List<Notification>> fetchNotifications(String userId) {
    return _mockService.getNotificationsStream(userId);
  }

  @override
  Stream<List<Notification>> fetchUnreadNotifications(String userId) {
    return fetchNotifications(userId).map((notifications) {
      return notifications.where((n) => !n.isRead).toList();
    });
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    _mockService.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    _mockService.markAllAsRead(userId);
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    _mockService.deleteNotification(notificationId);
  }

  @override
  Future<void> sendNotification(Notification notification) async {
    _mockService.addNotification(notification);
  }

  @override
  Stream<List<Reminder>> fetchReminders(String userId) {
    return _mockService.getRemindersStream(userId);
  }

  @override
  Future<Reminder> createReminder(Reminder reminder) async {
    final Reminder created = _mockService.createReminder(reminder);
    await _notificationService.scheduleReminder(created);
    return created;
  }

  @override
  Future<void> updateReminder(String reminderId, Reminder reminder) async {
    _mockService.updateReminder(reminderId, reminder);
    if (reminder.isActive) {
      await _notificationService.scheduleReminder(reminder);
    } else {
      await _notificationService.cancelReminder(reminderId);
    }
  }

  @override
  Future<void> deleteReminder(String reminderId) async {
    _mockService.deleteReminder(reminderId);
    await _notificationService.cancelReminder(reminderId);
  }

  @override
  Future<void> toggleReminder(String reminderId, bool isActive) async {
    _mockService.toggleReminder(reminderId, isActive);
    if (!isActive) {
      await _notificationService.cancelReminder(reminderId);
      return;
    }

    final reminder = _mockService.getReminderById(reminderId);
    if (reminder != null) {
      await _notificationService.scheduleReminder(reminder);
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    return _mockService.getUnreadCount(userId);
  }

  @override
  Future<List<Notification>> getNotificationsByType(
    String userId,
    NotificationType type,
  ) async {
    return _mockService.getNotificationsByType(userId, type);
  }

  @override
  Future<void> upsertDeviceToken(String userId, String token) async {
    // No-op for mock mode.
  }
}
