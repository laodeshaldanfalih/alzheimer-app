import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:project/features/reminder/model/reminder_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class ReminderPageService {
  static final ReminderPageService _instance = ReminderPageService._internal();
  factory ReminderPageService() => _instance;
  ReminderPageService._internal();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  Future<void> scheduleNotification(DateTime dateTime) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'reminder_channel',
        title: 'Alarm Notification',
        body: 'This is your scheduled alarm!',
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Alarm,
      ),
      schedule: NotificationCalendar(
        year: dateTime.year,
        month: dateTime.month,
        day: dateTime.day,
        hour: dateTime.hour,
        minute: dateTime.minute,
        second: 0,
        millisecond: 0,
        repeats: false,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
      ),
    );
  }

  Future<void> testNotification() async {
    try {
      final scheduleTime = DateTime.now().add(const Duration(seconds: 5));

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 3,
          channelKey: 'reminder_channel',
          title: 'Tes Halaman Reminder',
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
          timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
          preciseAlarm: true,
        ),
      );
      print('Notification scheduled successfully');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  Future<void> scheduleCustomNotification(ReminderModel reminder) async {
    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'reminder_channel',
        title: reminder.title,
        body:
            reminder.description.isNotEmpty
                ? reminder.description
                : 'Reminder: ${reminder.title}',
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
        payload: {'reminderId': id.toString()}, // Tambahkan payload
        criticalAlert: true,
      ),
      schedule: NotificationCalendar(
        year: reminder.dateTime.year,
        month: reminder.dateTime.month,
        day: reminder.dateTime.day,
        hour: reminder.dateTime.hour,
        minute: reminder.dateTime.minute,
        second: 0,
        millisecond: 0,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        preciseAlarm: true,
      ),
    );
  }
}
