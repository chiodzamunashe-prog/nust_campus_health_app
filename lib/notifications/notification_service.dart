import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'models.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Ignore: app might already be initialized.
  }
}

class AppNotificationService {
  AppNotificationService._();
  static final AppNotificationService instance = AppNotificationService._();

  static const String _channelId = 'health_alerts';
  static const String _channelName = 'Health Alerts';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  StreamSubscription<String>? _tokenRefreshSubscription;
  String? _tokenSyncedUserId;

  Future<void> initialize({required bool enableRemoteMessaging}) async {
    if (_initialized) {
      return;
    }

    tz_data.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      ),
      onDidReceiveNotificationResponse: (_) {},
    );

    await _createAndroidChannel();
    await _requestLocalNotificationPermissions();

    if (enableRemoteMessaging) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await _requestRemoteNotificationPermissions();
      FirebaseMessaging.onMessage.listen(_showForegroundPush);
      FirebaseMessaging.onMessageOpenedApp.listen((_) {});
    }

    _initialized = true;
  }

  Future<void> syncDeviceToken({
    required String userId,
    required Future<void> Function(String token) onToken,
  }) async {
    if (kIsWeb || userId.isEmpty || userId == 'guest') {
      return;
    }

    if (_tokenSyncedUserId == userId) {
      return;
    }

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await onToken(token);
      }

      await _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
          .listen((String refreshedToken) async {
            if (refreshedToken.isNotEmpty) {
              await onToken(refreshedToken);
            }
          });
      _tokenSyncedUserId = userId;
    } catch (_) {
      // Firebase Messaging can be unavailable in local or mock environments.
    }
  }

  Future<void> updateBadgeCount(int unreadCount) async {
    if (kIsWeb) {
      return;
    }

    try {
      final supported = await FlutterAppBadger.isAppBadgeSupported();
      if (!supported) {
        return;
      }
      if (unreadCount <= 0) {
        FlutterAppBadger.removeBadge();
      } else {
        FlutterAppBadger.updateBadgeCount(unreadCount);
      }
    } catch (_) {
      // Ignore badge failures on unsupported launchers/platforms.
    }
  }

  Future<void> scheduleReminder(Reminder reminder) async {
    if (kIsWeb) {
      return;
    }

    if (!reminder.isActive) {
      await cancelReminder(reminder.id);
      return;
    }

    final tz.TZDateTime scheduleAt = _nextSchedule(reminder);
    DateTimeComponents? repeat;

    if (reminder.frequency == ReminderFrequency.daily) {
      repeat = DateTimeComponents.time;
    }
    if (reminder.frequency == ReminderFrequency.weekly) {
      repeat = DateTimeComponents.dayOfWeekAndTime;
    }

    await _localNotifications.zonedSchedule(
      id: _idFromString(reminder.id),
      title: reminder.title,
      body: reminder.description,
      scheduledDate: scheduleAt,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          channelShowBadge: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
        macOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode({'type': 'reminder', 'id': reminder.id}),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: repeat,
    );
  }

  Future<void> cancelReminder(String reminderId) async {
    if (kIsWeb) {
      return;
    }
    await _localNotifications.cancel(id: _idFromString(reminderId));
  }

  Future<void> _showForegroundPush(RemoteMessage message) async {
    final title = message.notification?.title ?? 'Campus Health Update';
    final body = message.notification?.body ?? 'You have a new notification.';

    await _localNotifications.show(
      id: _idFromString(message.messageId ?? DateTime.now().toIso8601String()),
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          channelShowBadge: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
        macOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  Future<void> _createAndroidChannel() async {
    final androidPlatform = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlatform?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Appointment, reminder, and urgent health notifications',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    );
  }

  Future<void> _requestRemoteNotificationPermissions() async {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    } catch (_) {
      // Ignore in mock or unsupported environments.
    }
  }

  Future<void> _requestLocalNotificationPermissions() async {
    final androidPlatform = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlatform?.requestNotificationsPermission();

    final iosPlatform = _localNotifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosPlatform?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    final macPlatform = _localNotifications
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    await macPlatform?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  tz.TZDateTime _nextSchedule(Reminder reminder) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime candidate = tz.TZDateTime.from(
      reminder.scheduledTime,
      tz.local,
    );

    if (candidate.isAfter(now)) {
      return candidate;
    }

    switch (reminder.frequency) {
      case ReminderFrequency.daily:
        while (!candidate.isAfter(now)) {
          candidate = candidate.add(const Duration(days: 1));
        }
        break;
      case ReminderFrequency.weekly:
        while (!candidate.isAfter(now)) {
          candidate = candidate.add(const Duration(days: 7));
        }
        break;
      case ReminderFrequency.none:
      case ReminderFrequency.before_appointment:
        candidate = now.add(const Duration(minutes: 1));
        break;
    }

    return candidate;
  }

  int _idFromString(String value) {
    return value.hashCode & 0x7fffffff;
  }
}
