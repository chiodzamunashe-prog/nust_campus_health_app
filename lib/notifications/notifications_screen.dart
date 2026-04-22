import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import 'models.dart' as notif;
import 'notification_service.dart';
import 'repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late NotificationsRepository _repository;
  final AppNotificationService _notificationService =
      AppNotificationService.instance;
  String _currentUserId = 'guest';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _repository = AuthService.instance.getNotificationsRepository();
    _currentUserId = AuthService.instance.currentUserId;

    _notificationService.syncDeviceToken(
      userId: _currentUserId,
      onToken: (token) => _repository.upsertDeviceToken(_currentUserId, token),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = AuthService.instance.currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications & Reminders'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Notifications'),
            Tab(text: 'Reminders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildNotificationsTab(userId), _buildRemindersTab(userId)],
      ),
    );
  }

  Widget _buildNotificationsTab(String userId) {
    return StreamBuilder<List<notif.Notification>>(
      stream: _repository.fetchNotifications(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'re all caught up!',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        final notifications = snapshot.data!;
        final unreadCount = notifications.where((n) => !n.isRead).length;
        _notificationService.updateBadgeCount(unreadCount);

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _buildNotificationTile(context, notification);
          },
        );
      },
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    notif.Notification notification,
  ) {
    final backgroundColor = notification.isRead
        ? Colors.grey.shade50
        : Colors.blue.shade50;
    final iconColor = _getNotificationIconColor(notification.type);

    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          _repository.markAsRead(notification.id).then((_) {
            _refreshBadge();
          });
        }
        _showNotificationDetail(context, notification);
      },
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: iconColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(notification.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _repository.deleteNotification(notification.id).then((_) {
                    _refreshBadge();
                  });
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersTab(String userId) {
    return StreamBuilder<List<notif.Reminder>>(
      stream: _repository.fetchReminders(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No reminders set',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create reminders to stay on top of your health',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showCreateReminderDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Reminder'),
                ),
              ],
            ),
          );
        }

        final reminders = snapshot.data!;
        final activeReminders = reminders.where((r) => r.isActive).toList();
        final inactiveReminders = reminders.where((r) => !r.isActive).toList();

        return ListView(
          children: [
            if (activeReminders.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Active Reminders',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showCreateReminderDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                    ),
                  ],
                ),
              ),
            ...activeReminders.map(
              (reminder) => _buildReminderTile(context, reminder, _repository),
            ),
            if (inactiveReminders.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  'Inactive Reminders',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              ...inactiveReminders.map(
                (reminder) =>
                    _buildReminderTile(context, reminder, _repository),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildReminderTile(
    BuildContext context,
    notif.Reminder reminder,
    NotificationsRepository repository,
  ) {
    final frequencyLabel = _getFrequencyLabel(reminder.frequency);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: reminder.isActive ? Colors.white : Colors.grey.shade50,
        border: Border.all(
          color: reminder.isActive
              ? const Color(0xFF003366).withOpacity(0.2)
              : Colors.grey.shade200,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Checkbox(
          value: reminder.isActive,
          onChanged: (value) {
            repository.toggleReminder(reminder.id, value ?? true);
          },
        ),
        title: Text(
          reminder.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: reminder.isActive ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(reminder.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  _formatTime(reminder.scheduledTime),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    frequencyLabel,
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              repository.deleteReminder(reminder.id);
            } else if (value == 'edit') {
              _showEditReminderDialog(context, reminder);
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void _showNotificationDetail(
    BuildContext context,
    notif.Notification notification,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationIconColor(notification.type),
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        _formatTime(notification.createdAt),
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              notification.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    _repository.deleteNotification(notification.id).then((_) {
                      _refreshBadge();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateReminderDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    notif.ReminderFrequency selectedFrequency = notif.ReminderFrequency.none;
    DateTime selectedTime = DateTime.now().add(const Duration(hours: 1));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Reminder'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<notif.ReminderFrequency>(
                value: selectedFrequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(),
                ),
                items: notif.ReminderFrequency.values
                    .map(
                      (f) => DropdownMenuItem(
                        value: f,
                        child: Text(_getFrequencyLabel(f)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  selectedFrequency = value ?? notif.ReminderFrequency.none;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final reminder = notif.Reminder(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                userId: AuthService.instance.currentUserId,
                title: titleController.text,
                description: descriptionController.text,
                scheduledTime: selectedTime,
                frequency: selectedFrequency,
                isActive: true,
                createdAt: DateTime.now(),
              );
              _repository.createReminder(reminder).then((_) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reminder created')),
                );
              });
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditReminderDialog(BuildContext context, notif.Reminder reminder) {
    final titleController = TextEditingController(text: reminder.title);
    final descriptionController = TextEditingController(
      text: reminder.description,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Reminder'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedReminder = notif.Reminder(
                id: reminder.id,
                userId: reminder.userId,
                title: titleController.text,
                description: descriptionController.text,
                scheduledTime: reminder.scheduledTime,
                frequency: reminder.frequency,
                isActive: reminder.isActive,
                createdAt: reminder.createdAt,
                appointmentId: reminder.appointmentId,
              );
              _repository.updateReminder(reminder.id, updatedReminder).then((
                _,
              ) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reminder updated')),
                );
              });
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      return 'Today ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (date == yesterday) {
      return 'Yesterday ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  IconData _getNotificationIcon(notif.NotificationType type) {
    switch (type) {
      case notif.NotificationType.appointment:
        return Icons.event_note;
      case notif.NotificationType.reminder:
        return Icons.schedule;
      case notif.NotificationType.result:
        return Icons.assignment;
      case notif.NotificationType.announcement:
        return Icons.announcement;
    }
  }

  Color _getNotificationIconColor(notif.NotificationType type) {
    switch (type) {
      case notif.NotificationType.appointment:
        return Colors.blue;
      case notif.NotificationType.reminder:
        return Colors.orange;
      case notif.NotificationType.result:
        return Colors.green;
      case notif.NotificationType.announcement:
        return Colors.purple;
    }
  }

  String _getFrequencyLabel(notif.ReminderFrequency frequency) {
    switch (frequency) {
      case notif.ReminderFrequency.none:
        return 'Once';
      case notif.ReminderFrequency.daily:
        return 'Daily';
      case notif.ReminderFrequency.weekly:
        return 'Weekly';
      case notif.ReminderFrequency.before_appointment:
        return 'Before Appointment';
    }
  }

  Future<void> _refreshBadge() async {
    final unreadCount = await _repository.getUnreadCount(_currentUserId);
    await _notificationService.updateBadgeCount(unreadCount);
  }
}
