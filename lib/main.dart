import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/MMSE/data/mmse_test_state.dart';
import 'package:project/SKILAS/data/skilas_test_state.dart';
import 'package:project/firebase/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project/menu_game.dart';
import 'package:provider/provider.dart' as provider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Tambahkan ini dulu!
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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

  runApp(    provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => SKILASTestState()),
        provider.ChangeNotifierProvider(create: (context) => MMSETestState()),
      ],
      child: const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.white,
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const MenuGame(),

      debugShowCheckedModeBanner: false,
    );
  }
}
