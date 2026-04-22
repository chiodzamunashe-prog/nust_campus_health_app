import 'models.dart';

abstract class NotificationsRepository {
  // Notification methods
  Stream<List<Notification>> fetchNotifications(String userId);
  Stream<List<Notification>> fetchUnreadNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> deleteNotification(String notificationId);
  Future<void> sendNotification(Notification notification);

  // Reminder methods
  Stream<List<Reminder>> fetchReminders(String userId);
  Future<Reminder> createReminder(Reminder reminder);
  Future<void> updateReminder(String reminderId, Reminder reminder);
  Future<void> deleteReminder(String reminderId);
  Future<void> toggleReminder(String reminderId, bool isActive);

  // Statistics
  Future<int> getUnreadCount(String userId);
  Future<List<Notification>> getNotificationsByType(
    String userId,
    NotificationType type,
  );

  // Push token methods
  Future<void> upsertDeviceToken(String userId, String token);
}
