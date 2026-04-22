import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';
import 'notification_service.dart';
import 'repository.dart';

class FirestoreNotificationsRepository implements NotificationsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppNotificationService _notificationService =
      AppNotificationService.instance;
  final String _notificationsCollection = 'notifications';
  final String _remindersCollection = 'reminders';
  final String _tokensCollection = 'device_tokens';

  @override
  Stream<List<Notification>> fetchNotifications(String userId) {
    return _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Notification.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Stream<List<Notification>> fetchUnreadNotifications(String userId) {
    return _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('readAt', isNull: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Notification.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection(_notificationsCollection)
        .doc(notificationId)
        .update({'readAt': Timestamp.now()});
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('readAt', isNull: true)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({'readAt': Timestamp.now()});
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await _firestore
        .collection(_notificationsCollection)
        .doc(notificationId)
        .delete();
  }

  @override
  Future<void> sendNotification(Notification notification) async {
    await _firestore
        .collection(_notificationsCollection)
        .add(notification.toFirestore());
  }

  @override
  Stream<List<Reminder>> fetchReminders(String userId) {
    return _firestore
        .collection(_remindersCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('scheduledTime')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Reminder.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Future<Reminder> createReminder(Reminder reminder) async {
    final docRef = await _firestore
        .collection(_remindersCollection)
        .add(reminder.toFirestore());

    final Reminder createdReminder = Reminder(
      id: docRef.id,
      userId: reminder.userId,
      title: reminder.title,
      description: reminder.description,
      scheduledTime: reminder.scheduledTime,
      frequency: reminder.frequency,
      isActive: reminder.isActive,
      createdAt: reminder.createdAt,
      appointmentId: reminder.appointmentId,
    );

    await _notificationService.scheduleReminder(createdReminder);
    return createdReminder;
  }

  @override
  Future<void> updateReminder(String reminderId, Reminder reminder) async {
    await _firestore
        .collection(_remindersCollection)
        .doc(reminderId)
        .update(reminder.toFirestore());

    if (reminder.isActive) {
      await _notificationService.scheduleReminder(reminder);
    } else {
      await _notificationService.cancelReminder(reminderId);
    }
  }

  @override
  Future<void> deleteReminder(String reminderId) async {
    await _firestore.collection(_remindersCollection).doc(reminderId).delete();
    await _notificationService.cancelReminder(reminderId);
  }

  @override
  Future<void> toggleReminder(String reminderId, bool isActive) async {
    await _firestore.collection(_remindersCollection).doc(reminderId).update({
      'isActive': isActive,
    });

    if (!isActive) {
      await _notificationService.cancelReminder(reminderId);
      return;
    }

    final doc = await _firestore
        .collection(_remindersCollection)
        .doc(reminderId)
        .get();
    if (doc.exists) {
      await _notificationService.scheduleReminder(Reminder.fromFirestore(doc));
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    final snapshot = await _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('readAt', isNull: true)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  @override
  Future<List<Notification>> getNotificationsByType(
    String userId,
    NotificationType type,
  ) async {
    final snapshot = await _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Notification.fromFirestore(doc)).toList();
  }

  @override
  Future<void> upsertDeviceToken(String userId, String token) async {
    if (userId.isEmpty || token.isEmpty) {
      return;
    }

    final query = await _firestore
        .collection(_tokensCollection)
        .where('userId', isEqualTo: userId)
        .where('token', isEqualTo: token)
        .limit(1)
        .get();

    final payload = {
      'userId': userId,
      'token': token,
      'platform': 'flutter',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (query.docs.isEmpty) {
      await _firestore.collection(_tokensCollection).add(payload);
    } else {
      await query.docs.first.reference.set(payload, SetOptions(merge: true));
    }
  }
}
