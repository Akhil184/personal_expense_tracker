import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart' as tz;
import 'presentation/cubit/expense_cubit.dart';
import 'domain/usecases/manage_expenses.dart';
import 'data/datasources/expense_local_data_source.dart';
import 'utils/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeTimeZones();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialize local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  // Await for initialization before running the app
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Request notification permission
  await _requestNotificationPermission();

  runApp(MyApp(flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin));
}

// Request notification permission
Future<void> _requestNotificationPermission() async {
  PermissionStatus status = await Permission.notification.status;

  if (status.isDenied) {
    PermissionStatus newStatus = await Permission.notification.request();
    if (newStatus.isGranted) {
      print('Notification permission granted');
    } else {
      print('Notification permission denied');
    }
  } else if (status.isGranted) {
    print('Notification permission already granted');
  }
}

class MyApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  MyApp({required this.flutterLocalNotificationsPlugin, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ExpenseCubit(
            ManageExpenses(ExpenseLocalDataSource()),
            flutterLocalNotificationsPlugin,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Expense Tracker',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        onGenerateRoute: AppRoutes.generateRoute, // Use generateRoute here
      ),
    );
  }
}

// Schedule a daily notification
Future<void> scheduleDailyExpenseNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    ) async {
  const AndroidNotificationDetails androidDetails =
  AndroidNotificationDetails(
    'expense_channel',
    'Daily Expense Notification',
    channelDescription: 'Channel for daily expense notifications',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
  NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Daily Expense Reminder',
    'Remember to track your daily expenses!',
    _nextInstanceOfTime(21, 38), // ⬅️ hour, minute
    notificationDetails,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
    UILocalNotificationDateInterpretation.wallClockTime,
    matchDateTimeComponents: DateTimeComponents.time, // DAILY
  );
}


// Helper function to get the next occurrence of a specific time
tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
  final now = tz.TZDateTime.now(tz.local);

  tz.TZDateTime scheduledDate = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );

  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  return scheduledDate;
}

