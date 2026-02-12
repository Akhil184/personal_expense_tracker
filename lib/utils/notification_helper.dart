import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  NotificationHelper() {
    _initialize();
  }

  Future<void> _initialize() async {
    // Initialize timezone data
    tz.initializeTimeZones();

    // Set the local time zone
    final String timeZone = tz.local.name;

    // Initialize FlutterLocalNotificationsPlugin
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Schedule a daily reminder at a specific time (e.g., 8 PM)
  Future<void> scheduleDailyReminder() async {
    final time = tz.TZDateTime.now(tz.local).add(Duration(days: 1));
    final scheduledTime = tz.TZDateTime(
        tz.local, time.year, time.month, time.day, 20, 0, 0); // 8 PM the next day

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'expense_reminder_channel', // Channel ID
      'Expense Reminders', // Channel name
      channelDescription: 'Reminder to record your daily expenses',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    // Schedule the notification at the calculated time
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Notification ID
      'Expense Reminder',
      'Don\'t forget to record your daily expenses!',
      scheduledTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time, // Ensures it repeats daily
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime, // Added required parameter
    );
  }
}