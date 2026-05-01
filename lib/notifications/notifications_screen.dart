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
  late Stream<List<notif.Notification>> _notificationsStream;
  late Stream<List<notif.Reminder>> _remindersStream;

  List<notif.Notification> get _sampleNotifications => [
    notif.Notification(
      id: 'sample-1',
      userId: _currentUserId,
      title: 'Lab results ready',
      message:
          'Your blood panel is ready for review. Tap to view the details and next steps.',
      type: notif.NotificationType.result,
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    notif.Notification(
      id: 'sample-2',
      userId: _currentUserId,
      title: 'New appointment confirmed',
      message:
          'Your dermatologist appointment is confirmed for tomorrow at 10:30 AM.',
      type: notif.NotificationType.appointment,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    notif.Notification(
      id: 'sample-3',
      userId: _currentUserId,
      title: 'Hydration reminder',
      message: 'Drink a glass of water to keep your daily hydration on track.',
      type: notif.NotificationType.reminder,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    notif.Notification(
      id: 'sample-4',
      userId: _currentUserId,
      title: 'Campus clinic update',
      message:
          'The campus clinic will be open until 8 PM today for evening checkups.',
      type: notif.NotificationType.announcement,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    notif.Notification(
      id: 'sample-5',
      userId: _currentUserId,
      title: 'Prescription ready',
      message:
          'Your prescribed medication is available for pickup at the pharmacy.',
      type: notif.NotificationType.result,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  List<notif.Reminder> get _sampleReminders => [
    notif.Reminder(
      id: 'reminder-1',
      userId: _currentUserId,
      title: 'Daily vitamins',
      description: 'Take your daily vitamins to support immune health.',
      scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      frequency: notif.ReminderFrequency.daily,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    notif.Reminder(
      id: 'reminder-2',
      userId: _currentUserId,
      title: 'Physio exercises',
      description: 'Complete your knee recovery exercises for 20 minutes.',
      scheduledTime: DateTime.now().add(const Duration(hours: 4)),
      frequency: notif.ReminderFrequency.daily,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    notif.Reminder(
      id: 'reminder-3',
      userId: _currentUserId,
      title: 'Medication review',
      description: 'Review your medications before your next consultation.',
      scheduledTime: DateTime.now().add(const Duration(days: 1, hours: 9)),
      frequency: notif.ReminderFrequency.before_appointment,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    notif.Reminder(
      id: 'reminder-4',
      userId: _currentUserId,
      title: 'Annual checkup prep',
      description:
          'Gather your health history and symptoms before the checkup.',
      scheduledTime: DateTime.now().add(const Duration(days: 2, hours: 2)),
      frequency: notif.ReminderFrequency.weekly,
      isActive: false,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

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

    _notificationsStream = _repository.fetchNotifications(_currentUserId);
    _remindersStream = _repository.fetchReminders(_currentUserId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      appBar: AppBar(
        title: const Text('Notifications & Reminders'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3366FF), Color(0xFF00C6FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Color.fromRGBO(255, 255, 255, 0.25),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Notifications'),
            Tab(text: 'Reminders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildNotificationsTab(), _buildRemindersTab()],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return StreamBuilder<List<notif.Notification>>(
      stream: _notificationsStream,
      builder: (context, snapshot) {
        final hasData = snapshot.hasData && snapshot.data!.isNotEmpty;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final notifications = hasData ? snapshot.data! : _sampleNotifications;
        final unreadCount = notifications.where((n) => !n.isRead).length;

        if (hasData) {
          _notificationService.updateBadgeCount(unreadCount);
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          itemCount: notifications.length + 1,
          separatorBuilder: (context, _) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildNotificationsHeader(
                context,
                notifications.length,
                hasData,
              );
            }
            final notification = notifications[index - 1];
            return _buildNotificationTile(
              context,
              notification,
              isSample: !hasData,
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationsHeader(
    BuildContext context,
    int count,
    bool hasRealData,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Latest updates',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Stay informed about your health schedule and results.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    notif.Notification notification, {
    bool isSample = false,
  }) {
    final backgroundColor = notification.isRead
        ? Colors.white
        : Color.fromRGBO(173, 216, 230, 0.9);
    final iconColor = _getNotificationIconColor(notification.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                _getNotificationIcon(notification.type),
                color: iconColor,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w700,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!notification.isRead && !isSample)
                      Container(
                        margin: const EdgeInsets.only(left: 8, top: 2),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  notification.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTime(notification.createdAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        notification.type.name.toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: iconColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isSample)
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
    );
  }

  Widget _buildRemindersTab() {
    return StreamBuilder<List<notif.Reminder>>(
      stream: _remindersStream,
      builder: (context, snapshot) {
        final hasData = snapshot.hasData && snapshot.data!.isNotEmpty;
        final reminders = hasData ? snapshot.data! : _sampleReminders;
        final activeReminders = reminders.where((r) => r.isActive).toList();
        final inactiveReminders = reminders.where((r) => !r.isActive).toList();

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildRemindersHeader(context, hasData),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () => _showCreateReminderDialog(context),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Create reminder'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  backgroundColor: const Color(0xFF3366FF),
                  foregroundColor: Colors.white,
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (activeReminders.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Active reminders',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            if (activeReminders.isNotEmpty) const SizedBox(height: 12),
            ...activeReminders.map(
              (reminder) => _buildReminderTile(
                context,
                reminder,
                _repository,
                isSample: !hasData,
              ),
            ),
            if (activeReminders.isEmpty) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'No active reminders yet. Add one to stay on top of your wellness routine.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                ),
              ),
            ],
            if (inactiveReminders.isNotEmpty) ...[
              if (activeReminders.isNotEmpty) const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Inactive reminders',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...inactiveReminders.map(
                (reminder) => _buildReminderTile(
                  context,
                  reminder,
                  _repository,
                  isSample: !hasData,
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildRemindersHeader(BuildContext context, bool hasData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your wellness schedule',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage medication, appointments, and health goals in one place.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildReminderTile(
    BuildContext context,
    notif.Reminder reminder,
    NotificationsRepository repository, {
    bool isSample = false,
  }) {
    final frequencyLabel = _getFrequencyLabel(reminder.frequency);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: reminder.isActive ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: reminder.isActive
                        ? const Color(0xFF3366FF).withValues(alpha: 0.12)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    color: reminder.isActive
                        ? const Color(0xFF3366FF)
                        : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    reminder.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: reminder.isActive
                          ? Colors.black87
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
                if (!isSample)
                  Switch(
                    value: reminder.isActive,
                    onChanged: (value) {
                      repository.toggleReminder(reminder.id, value);
                    },
                    activeThumbColor: const Color(0xFF3366FF),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              reminder.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  _formatTime(reminder.scheduledTime),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: reminder.isActive
                        ? const Color(0xFF00C6FF).withValues(alpha: 0.16)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    frequencyLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: reminder.isActive
                          ? const Color(0xFF0091EA)
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (!isSample)
              Align(
                alignment: Alignment.centerRight,
                child: PopupMenuButton<String>(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                initialValue: selectedFrequency,
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
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reminder created')),
                  );
                }
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reminder updated')),
                  );
                }
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

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    if (date == today) {
      return 'Today $hour:$minute';
    } else if (date == yesterday) {
      return 'Yesterday $hour:$minute';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} $hour:$minute';
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
        return const Color(0xFF3366FF);
      case notif.NotificationType.reminder:
        return const Color(0xFFFFA726);
      case notif.NotificationType.result:
        return const Color(0xFF43A047);
      case notif.NotificationType.announcement:
        return const Color(0xFF7E57C2);
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
    try {
      final unreadCount = await _repository.getUnreadCount(_currentUserId);
      await _notificationService.updateBadgeCount(unreadCount);
    } catch (e) {
      // Handle error silently
    }
  }
}
