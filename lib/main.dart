import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/reminder/presentation/reminder_page.dart';
import 'package:project/features/sholat/presentation/sholat_reminder_page.dart';
import 'package:project/features/splash/presentation/pages/splash_page.dart';
import 'package:project/firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    // Untuk Android, defaultnya adalah Play Integrity.
    // Anda bisa menentukan provider secara eksplisit jika perlu.
    androidProvider: AndroidProvider.playIntegrity,
    // appleProvider: AppleProvider.appAttest, // Untuk iOS
  );

  // Initialize Awesome Notifications
  await _initializeNotifications();

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _initializeNotifications() async {
  await AwesomeNotifications().initialize('resource://drawable/test_icon', [
    NotificationChannel(
      channelKey: 'sholat_channel',
      channelName: 'Jadwal Sholat',
      channelDescription: 'Notifikasi pengingat waktu sholat',
      defaultColor: const Color(0xFF9D50DD),
      importance: NotificationImportance.High,
      channelShowBadge: true,
      playSound: true,
      enableLights: true,
      enableVibration: true,
      icon: 'resource://drawable/sholat_icon',
    ),
    NotificationChannel(
      channelKey: 'reminder_channel',
      channelName: 'Reminder Notifications',
      channelDescription: 'Notification',
      defaultColor: Colors.teal,
      importance: NotificationImportance.High,
      channelShowBadge: true,
      playSound: true,
      enableLights: true,
      enableVibration: true,
      icon: 'resource://drawable/reminder_icon',
      soundSource: 'resource://raw/res_gio_alarm',
    ),
  ], debug: true);

  // Set up notification click listeners
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: onActionReceivedMethod,
    onNotificationCreatedMethod: onNotificationCreatedMethod,
    onNotificationDisplayedMethod: onNotificationDisplayedMethod,
    onDismissActionReceivedMethod: onDismissActionReceivedMethod,
  );
}

Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  if (receivedAction.channelKey == 'reminder_channel') {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const ReminderPage()),
    );
  }
  if (receivedAction.channelKey == 'sholat_channel') {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => SholatPage()),
    );
  }
}

Future<void> onNotificationCreatedMethod(
  ReceivedNotification receivedNotification,
) async {}
Future<void> onNotificationDisplayedMethod(
  ReceivedNotification receivedNotification,
) async {}
Future<void> onDismissActionReceivedMethod(
  ReceivedAction receivedAction,
) async {}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
      theme: ThemeData(primaryColor: Colors.white, primarySwatch: Colors.blue),
    );
  }
}
