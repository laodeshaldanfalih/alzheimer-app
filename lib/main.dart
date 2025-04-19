import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:project/firebase/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project/menu_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Tambahkan ini dulu!
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  AwesomeNotifications().initialize(
    'resource://drawable/sholat_icon',
    [
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
      ),
    ],
    debug: true,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primaryColor: Colors.white, primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: const MenuGame(),

      debugShowCheckedModeBanner: false,
    );
  }
}
