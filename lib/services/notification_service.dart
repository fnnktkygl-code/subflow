import 'package:flutter/material.dart'; // Required for DateUtils
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/subscription_model.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    try {
      await _notificationsPlugin.initialize(initializationSettings);
    } catch (e) {
      debugPrint("Notification init warning: $e");
    }

    // ✅ FIX: Initialize timezone data using the 'tzdata' prefix
    tzdata.initializeTimeZones();
  }

  Future<void> requestPermissions() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint("Notification requestPermissions warning: $e");
    }
  }

  DateTime? _calculateNextDueDate(Subscription sub) {
    DateTime now = DateTime.now();
    DateTime nextDate = sub.startDate;

    if (nextDate.isBefore(now)) {
      switch (sub.cycle) {
        case 'Weekly':
          while (nextDate.isBefore(now)) {
            nextDate = DateTime(nextDate.year, nextDate.month, nextDate.day + 7);
          }
          break;
        case 'Monthly':
          while (nextDate.isBefore(now)) {
            var nextYear = nextDate.year;
            var nextMonth = nextDate.month + 1;
            if (nextMonth > 12) {
              nextMonth = 1;
              nextYear++;
            }
            final day = min(nextDate.day, DateUtils.getDaysInMonth(nextYear, nextMonth));
            nextDate = DateTime(nextYear, nextMonth, day);
          }
          break;
        case 'Yearly':
          while (nextDate.isBefore(now)) {
            var nextYear = nextDate.year + 1;
            final day = min(nextDate.day, DateUtils.getDaysInMonth(nextYear, nextDate.month));
            nextDate = DateTime(nextYear, nextDate.month, day);
          }
          break;
      }
    }

    if (sub.endDate != null && nextDate.isAfter(sub.endDate!)) {
      return null;
    }
    return nextDate;
  }

  /// Schedules a smarter, more personalized reminder notification.
  Future<void> scheduleNotification(Subscription sub) async {
    // 1. Check if notifications are enabled for this specific subscription.
    if (!sub.areNotificationsEnabled) {
      // If disabled, ensure any previously scheduled notification is cancelled and stop.
      await cancelNotification(sub.id);
      return;
    }

    try {
      final DateTime? nextDueDate = _calculateNextDueDate(sub);
      if (nextDueDate == null) return;

      // 2. Use the user's custom reminder time (e.g., 1, 2, 3, or 7 days).
      final notificationDate = nextDueDate.subtract(Duration(days: sub.reminderDays));

      final scheduledDate = tz.TZDateTime.from(
        DateTime(notificationDate.year, notificationDate.month, notificationDate.day, 10), // Schedule for 10 AM
        tz.local,
      );

      // Don't schedule notifications for past dates.
      if (scheduledDate.isBefore(DateTime.now())) return;

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'subscription_reminders', 'Subscription Reminders',
        channelDescription: 'Notifications for upcoming subscription payments',
        importance: Importance.max, priority: Priority.high,
      );
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      // 3. Personalize the notification message.
      final String daysString = sub.reminderDays == 1 ? '1 day' : '${sub.reminderDays} days';
      final String amountString = sub.amount.abs().toStringAsFixed(2);

      await _notificationsPlugin.zonedSchedule(
        sub.id.hashCode,
        'Upcoming Payment',
        'Your subscription for "${sub.name}" ($amountString €) is due in $daysString.',
        scheduledDate,
        const NotificationDetails(android: androidDetails, iOS: iosDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint("Notification schedule notice: $e");
    }
  }

  Future<void> cancelNotification(String subscriptionId) async {
    try {
      await _notificationsPlugin.cancel(subscriptionId.hashCode);
    } catch (e) {
      debugPrint("Notification cancel notice: $e");
    }
  }

  // --- DEV TESTING METHODS ---

  Future<void> showNowNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_channel', 'Test Notifications',
      channelDescription: 'Channel for instant test notifications',
      importance: Importance.max, priority: Priority.high,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    await _notificationsPlugin.show(
      -1,
      'Instant Test Notification',
      'If you see this, it works!',
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  Future<void> scheduleTestNotification() async {
    final scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_channel', 'Test Notifications',
      channelDescription: 'Channel for scheduled test notifications',
      importance: Importance.max, priority: Priority.high,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    await _notificationsPlugin.zonedSchedule(
      -2,
      'Scheduled Test Notification',
      'This should appear in 5 seconds.',
      scheduledDate,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> showPendingNotifications() async {
    final List<PendingNotificationRequest> pendingRequests =
    await _notificationsPlugin.pendingNotificationRequests();
    if (pendingRequests.isEmpty) {
      debugPrint("--- NO PENDING NOTIFICATIONS ---");
      return;
    }
    debugPrint('--- PENDING NOTIFICATIONS (${pendingRequests.length}) ---');
    for (var request in pendingRequests) {
      debugPrint(
          'ID: ${request.id}, Title: ${request.title}, Body: ${request.body}');
    }
    debugPrint('------------------------------------');
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    debugPrint("--- ALL NOTIFICATIONS CANCELLED ---");
  }
}