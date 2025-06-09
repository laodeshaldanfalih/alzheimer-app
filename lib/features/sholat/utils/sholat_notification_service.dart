import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';

class SholatNotificationService {
  static final SholatNotificationService _instance =
      SholatNotificationService._internal();
  factory SholatNotificationService() => _instance;
  SholatNotificationService._internal();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    // Initialize notification channel
    await AwesomeNotifications().initialize(
      null, // null means use default app icon
      [
        NotificationChannel(
          channelKey: 'sholat_channel',
          channelName: 'Sholat Notifications',
          channelDescription: 'Notifications for prayer times',
          defaultColor: Colors.blue,
          ledColor: Colors.blue,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          enableVibration: true,
          enableLights: true,
          criticalAlerts: true,
        ),
      ],
    );
  }

  Future<void> testScheduleNotification() async {
    final scheduleTime = DateTime.now().add(
      const Duration(seconds: 7),
    ); // Beri sedikit waktu lebih
    final id =
        DateTime.now().millisecondsSinceEpoch.remainder(100000) +
        1000; // ID unik, tambahkan offset agar beda dari reminder

    print(
      'Scheduling test notification for sholat_channel at $scheduleTime with ID $id',
    );

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id, // Gunakan ID dinamis seperti reminder
          channelKey: 'sholat_channel', // Tetap gunakan channel sholat
          title: 'Tes Jadwal Sholat Channel',
          body: 'Ini adalah notifikasi tes untuk sholat_channel. Meow.',
          notificationLayout: NotificationLayout.Default,
          wakeUpScreen: true, // SAMAKAN dengan reminder
          category: NotificationCategory.Alarm,
          payload: {'testId': id.toString()},
          criticalAlert: true,
          largeIcon: 'resource://drawable/sholat_icon',
        ),
        schedule: NotificationCalendar(
          year: scheduleTime.year,
          month: scheduleTime.month,
          day: scheduleTime.day,
          hour: scheduleTime.hour,
          minute: scheduleTime.minute,
          second: scheduleTime.second, // Gunakan detik dari scheduleTime
          millisecond: 0,
          timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
          preciseAlarm: true,
          // repeats: false, // Untuk tes, tidak perlu repeat
        ),
        actionButtons: [
          // Opsional, untuk debugging apakah action bisa diterima
          NotificationActionButton(
            key: 'TEST_ACTION_SHOLAT',
            label: 'Test Action',
          ),
        ],
      );
      print(
        'Test notification for sholat_channel successfully created/scheduled with ID $id.',
      );
    } catch (e) {
      print('Error scheduling test notification for sholat_channel: $e');
      // Di mode rilis, Anda mungkin ingin menggunakan logger yang lebih canggih
    }
  }

  Future<void> schedulePrayerNotifications(
    Map<String, String> prayerTimes, // Berisi nama sholat dan waktunya (HH:mm)
    Map<String, bool>
    notificationEnabled, // Berisi status aktif/nonaktif notifikasi per waktu sholat
  ) async {
    await AwesomeNotifications().cancelNotificationsByChannelKey(
      'sholat_channel',
    ); //
    print('Cancelled existing notifications for sholat_channel.');

    int idCounter = 100; // Reset ID counter setiap kali penjadwalan ulang
    final now = DateTime.now();
    final String localTimeZone =
        await AwesomeNotifications().getLocalTimeZoneIdentifier();

    for (var entry in prayerTimes.entries) {
      final prayerName = entry.key;
      final prayerTimeString = entry.value;

      // Lewati jika waktu sholat ini dinonaktifkan notifikasinya
      if (notificationEnabled[prayerName] == false) {
        // Cek dari map yang di-pass dari sholat_page.dart
        print('Notifications for $prayerName are disabled. Skipping.');
        continue;
      }

      if (prayerTimeString.isEmpty) {
        // Tambahan guard jika string waktu kosong
        print('Prayer time string for $prayerName is empty. Skipping.');
        continue;
      }

      final parts = prayerTimeString.split(':');
      if (parts.length != 2) {
        print(
          'Invalid time format for $prayerName: $prayerTimeString. Skipping.',
        );
        continue;
      }

      DateTime prayerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      // Jika waktu sholat sudah lewat hari ini, jadwalkan untuk besok
      if (prayerDateTime.isBefore(now)) {
        prayerDateTime = prayerDateTime.add(const Duration(days: 1));
      }

      // A. Notifikasi saat waktu sholat tiba
      try {
        print(
          'Scheduling main notification for $prayerName at $prayerDateTime (ID: $idCounter)',
        );
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: idCounter++,
            channelKey: 'sholat_channel',
            title: 'Waktunya ${prayerName.toTitleCase()}',
            body:
                'Sekarang sudah masuk waktu ${prayerName.toTitleCase()} (${DateFormat('HH:mm').format(prayerDateTime)}).',
            notificationLayout: NotificationLayout.Default,
            category: NotificationCategory.Alarm, // Konsisten
            wakeUpScreen: true,
            payload: {'prayerName': prayerName, 'type': 'reminder30'},
            icon: 'resource://drawable/sholat_icon',
          ),
          schedule: NotificationCalendar(
            year: prayerDateTime.year,
            month: prayerDateTime.month,
            day: prayerDateTime.day,
            hour: prayerDateTime.hour,
            minute: prayerDateTime.minute,
            second: 0,
            millisecond: 0,
            timeZone: localTimeZone, // Gunakan variabel yang sudah diambil
            preciseAlarm: true,
          ),
        );
      } catch (e) {
        print('Error scheduling main notification for $prayerName: $e');
      }

      // B. Notifikasi 30 menit sebelumnya
      final reminderTime30 = prayerDateTime.subtract(
        const Duration(minutes: 30),
      );
      if (reminderTime30.isAfter(now)) {
        try {
          print(
            'Scheduling 30-min reminder for $prayerName at $reminderTime30 (ID: $idCounter)',
          );
          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: idCounter++,
              channelKey: 'sholat_channel',
              title: '30 Menit Menuju ${prayerName.toTitleCase()}',
              body:
                  'Waktu ${prayerName.toTitleCase()} (${DateFormat('HH:mm').format(prayerDateTime)}) sekitar 30 menit lagi.',
              notificationLayout: NotificationLayout.Default,
              category:
                  NotificationCategory.Reminder, // Bisa Reminder atau Alarm
              wakeUpScreen: true,
              payload: {'prayerName': prayerName, 'type': 'reminder30'},
              icon: 'resource://drawable/sholat_icon',
            ),
            schedule: NotificationCalendar(
              year: reminderTime30.year,
              month: reminderTime30.month,
              day: reminderTime30.day,
              hour: reminderTime30.hour,
              minute: reminderTime30.minute,
              second: 0,
              millisecond: 0,
              timeZone: localTimeZone,
              preciseAlarm: true,

              // repeats: false,
            ),
          );
        } catch (e) {
          print('Error scheduling 30-min reminder for $prayerName: $e');
        }
      }

      // C. Notifikasi 10 menit sebelumnya
      final reminderTime10 = prayerDateTime.subtract(
        const Duration(minutes: 10),
      );
      if (reminderTime10.isAfter(now)) {
        try {
          print(
            'Scheduling 10-min reminder for $prayerName at $reminderTime10 (ID: $idCounter)',
          );
          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: idCounter++,
              channelKey: 'sholat_channel',
              title: '10 Menit Menuju ${prayerName.toTitleCase()}',
              body:
                  'Waktu ${prayerName.toTitleCase()} (${DateFormat('HH:mm').format(prayerDateTime)}) sekitar 10 menit lagi.',
              notificationLayout: NotificationLayout.Default,
              category: NotificationCategory.Reminder,
              wakeUpScreen: true,
              payload: {'prayerName': prayerName, 'type': 'reminder10'},
              icon: 'resource://drawable/sholat_icon',
            ),
            schedule: NotificationCalendar(
              year: reminderTime10.year,
              month: reminderTime10.month,
              day: reminderTime10.day,
              hour: reminderTime10.hour,
              minute: reminderTime10.minute,
              second: 0,
              millisecond: 0,
              timeZone: localTimeZone,
              preciseAlarm: true,

              // repeats: false,
            ),
          );
        } catch (e) {
          print('Error scheduling 10-min reminder for $prayerName: $e');
        }
      }
    }
    print('Finished scheduling all prayer notifications.');
  }
}

// Helper extension untuk membuat string menjadi Title Case (opsional, untuk tampilan)
extension StringCasingExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                  : '',
        )
        .join(' ');
  }
}
