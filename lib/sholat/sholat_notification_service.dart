// import 'package:flutter/widgets.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import 'dart:io';
// import 'package:permission_handler/permission_handler.dart';

// class SholatNotificationService {
//   static final SholatNotificationService _instance =
//       SholatNotificationService._internal();
//   factory SholatNotificationService() => _instance;
//   SholatNotificationService._internal();

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> initialize() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);

//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);

//     // Init timezone
//     tz.initializeTimeZones();
//     tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

//     // Minta izin notifikasi (Android 13+)
//     if (Platform.isAndroid) {
//       final status = await Permission.notification.request();
//       if (!status.isGranted) {
//         debugPrint('Izin notifikasi tidak diberikan.');
//       }
//     }
//   }

//   Future<void> schedulePrayerNotifications(
//     Map<String, String> prayerTimes,
//   ) async {
//     await flutterLocalNotificationsPlugin.cancelAll();

//     final now = DateTime.now();
//     int id = 0;

//     for (var entry in prayerTimes.entries) {
//       final parts = entry.value.split(':');
//       DateTime scheduledTime = DateTime(
//         now.year,
//         now.month,
//         now.day,
//         int.parse(parts[0]),
//         int.parse(parts[1]),
//       );

//       if (scheduledTime.isBefore(now)) {
//         scheduledTime = scheduledTime.add(Duration(days: 1));
//       }

//       await flutterLocalNotificationsPlugin.zonedSchedule(
//         id++,
//         'Waktu Sholat ${entry.key}',
//         'Sudah masuk waktu ${entry.key}.',
//         tz.TZDateTime.from(scheduledTime, tz.local),
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'sholat_channel',
//             'Jadwal Sholat',
//             channelDescription: 'Pengingat waktu sholat',
//             importance: Importance.max,
//             priority: Priority.high,
//             playSound: true,
//             enableLights: true,
//             enableVibration: true,
//           ),
//         ),
//         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//         matchDateTimeComponents: DateTimeComponents.time,
//       );
//     }
//   }
// }

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class SholatNotificationService {
  static final SholatNotificationService _instance = SholatNotificationService._internal();
  factory SholatNotificationService() => _instance;
  SholatNotificationService._internal();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  Future<void> showTestNotificationNow() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'sholat_channel',
        title: 'Tes Notifikasi',
        body: 'Ini notifikasi instan pakai awesome_notifications!',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  Future<void> testScheduleNotification() async {
    final scheduleTime = DateTime.now().add(Duration(seconds: 10));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 2,
        channelKey: 'sholat_channel',
        title: 'Tes Jadwal',
        body: 'Meow.',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        year: scheduleTime.year,
        month: scheduleTime.month,
        day: scheduleTime.day,
        hour: scheduleTime.hour,
        minute: scheduleTime.minute,
        second: scheduleTime.second,
        millisecond: 0,
        timeZone: 'Asia/Jakarta',
        preciseAlarm: true,
      ),
    );
  }

  Future<void> schedulePrayerNotifications(Map<String, String> prayerTimes) async {
    int id = 100;
    final now = DateTime.now();

    for (var entry in prayerTimes.entries) {
      final parts = entry.value.split(':');
      DateTime scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(Duration(days: 1));
      }

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id++,
          channelKey: 'sholat_channel',
          title: 'Waktu Sholat ${entry.key}',
          body: 'Sudah masuk waktu ${entry.key}.',
        ),
        schedule: NotificationCalendar(
          year: scheduledTime.year,
          month: scheduledTime.month,
          day: scheduledTime.day,
          hour: scheduledTime.hour,
          minute: scheduledTime.minute,
          second: 0,
          timeZone: 'Asia/Jakarta',
          preciseAlarm: true,
          repeats: true,
        ),
      );
    }
  }
}
