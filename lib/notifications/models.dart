import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { appointment, reminder, result, announcement }

enum ReminderFrequency { none, daily, weekly, before_appointment }

class Notification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? relatedId; // appointment or prescription id
  final Map<String, dynamic>? metadata;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.readAt,
    this.relatedId,
    this.metadata,
  });

  bool get isRead => readAt != null;

  factory Notification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Notification(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) =>
            e.toString() ==
            'NotificationType.${data['type'] ?? 'announcement'}',
        orElse: () => NotificationType.announcement,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      readAt: data['readAt'] != null
          ? (data['readAt'] as Timestamp).toDate()
          : null,
      relatedId: data['relatedId'],
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'relatedId': relatedId,
      'metadata': metadata,
    };
  }
}

class Reminder {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime scheduledTime;
  final ReminderFrequency frequency;
  final bool isActive;
  final DateTime createdAt;
  final String? appointmentId;

  Reminder({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.scheduledTime,
    required this.frequency,
    required this.isActive,
    required this.createdAt,
    this.appointmentId,
  });

  factory Reminder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reminder(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      scheduledTime: (data['scheduledTime'] as Timestamp).toDate(),
      frequency: ReminderFrequency.values.firstWhere(
        (e) =>
            e.toString() == 'ReminderFrequency.${data['frequency'] ?? 'none'}',
        orElse: () => ReminderFrequency.none,
      ),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      appointmentId: data['appointmentId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'frequency': frequency.toString().split('.').last,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'appointmentId': appointmentId,
    };
  }
}
