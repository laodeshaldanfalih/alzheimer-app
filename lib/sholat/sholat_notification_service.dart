import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class SholatNotificationService {
  static final SholatNotificationService _instance =
      SholatNotificationService._internal();
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

  Future<void> testScheduleNotification() async {
    final scheduleTime = DateTime.now().add(Duration(seconds: 5));

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

  Future<void> schedulePrayerNotifications(
    Map<String, String> prayerTimes,
  ) async {
    int id = 100;
    final now = DateTime.now();

    for (var entry in prayerTimes.entries) {
      final parts = entry.value.split(':');
      DateTime prayerTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      // Jika waktu sholat sudah lewat, jadwalkan untuk besok
      if (prayerTime.isBefore(now)) {
        prayerTime = prayerTime.add(Duration(days: 1));
      }

      // Notifikasi saat waktu sholat tiba
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id++,
          channelKey: 'sholat_channel',
          title: 'Waktu ${entry.key}',
          body: '${entry.value} Sudah masuk waktu ${entry.key}.',
        ),
        schedule: NotificationCalendar(
          year: prayerTime.year,
          month: prayerTime.month,
          day: prayerTime.day,
          hour: prayerTime.hour,
          minute: prayerTime.minute,
          second: 0,
          timeZone: 'Asia/Jakarta',
          preciseAlarm: true,
          repeats: true,
        ),
      );

      // Notifikasi 1 jam sebelumnya
      final reminderTime30 = prayerTime.subtract(Duration(minutes: 30));
      final reminderTime10 = prayerTime.subtract(Duration(minutes: 10));

      if (reminderTime30.isAfter(now)) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: id++,
            channelKey: 'sholat_channel',
            title: '30 menit lagi menuju ${entry.key}',
            body: '${entry.key} pada pukul [${entry.value}].',
          ),
          schedule: NotificationCalendar(
            year: reminderTime30.year,
            month: reminderTime30.month,
            day: reminderTime30.day,
            hour: reminderTime30.hour,
            minute: reminderTime30.minute,
            second: 0,
            timeZone: 'Asia/Jakarta',
            preciseAlarm: true,
            repeats: true,
          ),
        );
      }

      if (reminderTime10.isAfter(now)) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: id++,
            channelKey: 'sholat_channel',
            title: '10 menit lagi menuju ${entry.key}',
            body: '${entry.key} pada pukul [${entry.value}].',
          ),
          schedule: NotificationCalendar(
            year: reminderTime10.year,
            month: reminderTime10.month,
            day: reminderTime10.day,
            hour: reminderTime10.hour,
            minute: reminderTime10.minute,
            second: 0,
            timeZone: 'Asia/Jakarta',
            preciseAlarm: true,
            repeats: true,
          ),
        );
      }
    }
  }
}
