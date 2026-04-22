import 'dart:async';
import 'models.dart';

class MockNotificationsService {
  static final MockNotificationsService _instance =
      MockNotificationsService._internal();

  factory MockNotificationsService() {
    return _instance;
  }

  MockNotificationsService._internal();

  final List<Notification> _notifications = [
    Notification(
      id: 'n1',
      userId: 'student1',
      title: 'Appointment Confirmed',
      message:
          'Your psychiatry appointment is confirmed for tomorrow at 10:00 AM',
      type: NotificationType.appointment,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      relatedId: 'apt1',
    ),
    Notification(
      id: 'n2',
      userId: 'student1',
      title: 'Lab Results Ready',
      message: 'Your lab test results are now available in your Health Records',
      type: NotificationType.result,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      relatedId: 'lab1',
      readAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Notification(
      id: 'n3',
      userId: 'student1',
      title: 'Campus Health Announcement',
      message: 'Free flu shots available at the clinic this Friday',
      type: NotificationType.announcement,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      readAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Notification(
      id: 'n4',
      userId: 'student1',
      title: 'Medication Reminder',
      message: 'Time to refill your prescription for Amoxicillin',
      type: NotificationType.reminder,
      createdAt: DateTime.now(),
    ),
  ];

  final List<Reminder> _reminders = [
    Reminder(
      id: 'r1',
      userId: 'student1',
      title: 'Take Medication',
      description: 'Take your daily vitamin D supplement',
      scheduledTime: DateTime.now().add(const Duration(hours: 2)),
      frequency: ReminderFrequency.daily,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Reminder(
      id: 'r2',
      userId: 'student1',
      title: 'Upcoming Appointment',
      description: 'Psychiatry appointment in 24 hours',
      scheduledTime: DateTime.now().add(const Duration(hours: 24)),
      frequency: ReminderFrequency.before_appointment,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      appointmentId: 'apt1',
    ),
    Reminder(
      id: 'r3',
      userId: 'student1',
      title: 'Weekly Health Check',
      description: 'Check your health metrics and log them',
      scheduledTime: DateTime.now().add(const Duration(days: 7)),
      frequency: ReminderFrequency.weekly,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  final StreamController<List<Notification>> _notificationsController =
      StreamController<List<Notification>>.broadcast();
  final StreamController<List<Reminder>> _remindersController =
      StreamController<List<Reminder>>.broadcast();

  Stream<List<Notification>> getNotificationsStream(String userId) async* {
    yield _notifications.where((n) => n.userId == userId).toList();
    yield* _notificationsController.stream.map(
      (items) => items.where((n) => n.userId == userId).toList(),
    );
  }

  Stream<List<Reminder>> getRemindersStream(String userId) async* {
    yield _reminders.where((r) => r.userId == userId).toList();
    yield* _remindersController.stream.map(
      (items) => items.where((r) => r.userId == userId).toList(),
    );
  }

  void addNotification(Notification notification) {
    _notifications.add(notification);
    _notificationsController.add(_notifications);
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = Notification(
        id: _notifications[index].id,
        userId: _notifications[index].userId,
        title: _notifications[index].title,
        message: _notifications[index].message,
        type: _notifications[index].type,
        createdAt: _notifications[index].createdAt,
        readAt: DateTime.now(),
        relatedId: _notifications[index].relatedId,
        metadata: _notifications[index].metadata,
      );
      _notificationsController.add(_notifications);
    }
  }

  void markAllAsRead(String userId) {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == userId && !_notifications[i].isRead) {
        _notifications[i] = Notification(
          id: _notifications[i].id,
          userId: _notifications[i].userId,
          title: _notifications[i].title,
          message: _notifications[i].message,
          type: _notifications[i].type,
          createdAt: _notifications[i].createdAt,
          readAt: DateTime.now(),
          relatedId: _notifications[i].relatedId,
          metadata: _notifications[i].metadata,
        );
      }
    }
    _notificationsController.add(_notifications);
  }

  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _notificationsController.add(_notifications);
  }

  Reminder createReminder(Reminder reminder) {
    final newId = 'r${_reminders.length + 1}';
    final newReminder = Reminder(
      id: newId,
      userId: reminder.userId,
      title: reminder.title,
      description: reminder.description,
      scheduledTime: reminder.scheduledTime,
      frequency: reminder.frequency,
      isActive: reminder.isActive,
      createdAt: reminder.createdAt,
      appointmentId: reminder.appointmentId,
    );
    _reminders.add(newReminder);
    _remindersController.add(_reminders);
    return newReminder;
  }

  void updateReminder(String reminderId, Reminder reminder) {
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      _reminders[index] = reminder;
      _remindersController.add(_reminders);
    }
  }

  void deleteReminder(String reminderId) {
    _reminders.removeWhere((r) => r.id == reminderId);
    _remindersController.add(_reminders);
  }

  void toggleReminder(String reminderId, bool isActive) {
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      _reminders[index] = Reminder(
        id: _reminders[index].id,
        userId: _reminders[index].userId,
        title: _reminders[index].title,
        description: _reminders[index].description,
        scheduledTime: _reminders[index].scheduledTime,
        frequency: _reminders[index].frequency,
        isActive: isActive,
        createdAt: _reminders[index].createdAt,
        appointmentId: _reminders[index].appointmentId,
      );
      _remindersController.add(_reminders);
    }
  }

  int getUnreadCount(String userId) {
    return _notifications.where((n) => n.userId == userId && !n.isRead).length;
  }

  List<Notification> getNotificationsByType(
    String userId,
    NotificationType type,
  ) {
    return _notifications
        .where((n) => n.userId == userId && n.type == type)
        .toList();
  }

  Reminder? getReminderById(String reminderId) {
    for (final reminder in _reminders) {
      if (reminder.id == reminderId) {
        return reminder;
      }
    }
    return null;
  }

  void dispose() {
    _notificationsController.close();
    _remindersController.close();
  }
}
