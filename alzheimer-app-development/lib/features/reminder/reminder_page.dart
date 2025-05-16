import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:project/features/reminder/add_reminder_page.dart';
import 'package:project/features/reminder/reminder_archive_page.dart';
import 'package:project/features/reminder/reminder_model.dart';
import 'package:project/features/reminder/reminder_storage.dart';
import 'package:project/reminder/reminder_model.dart';


class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  List<ReminderModel> reminders = [];

  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
    _loadReminders();
  }

  Future<void> _checkNotificationPermission() async {
    final notifAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!notifAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  Future<void> _loadReminders() async {
    final loadedReminders = await ReminderStorage.getReminders();
    setState(() {
      reminders = loadedReminders;
    });
  }

  String _formatRepeatDays(Map<String, bool>? repeatDays) {
    if (repeatDays == null || repeatDays.values.every((value) => !value)) {
      return "Tidak berulang";
    }
    return repeatDays.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key.substring(0, 3)) // contoh: Sen, Sel, Rab
        .join(", ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Daftar Reminder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReminderArchivePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddReminderPage()),
              );
              _loadReminders(); // reload after adding
            },
          ),
        ],
      ),
      body: reminders.isEmpty
    ? const Center(child: Text('Belum ada reminder.'))
    : RefreshIndicator(
        onRefresh: _loadReminders,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final reminder = reminders[index];
            final timeText = TimeOfDay.fromDateTime(reminder.dateTime).format(context);
            final dateText = "${reminder.dateTime.day}/${reminder.dateTime.month}/${reminder.dateTime.year}";
            return GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddReminderPage(existingReminder: reminder),
                  ),
                );
                _loadReminders();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_active, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reminder.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$dateText - $timeText",
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatRepeatDays(reminder.repeatDays),
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
      // body:
      //     reminders.isEmpty
      //         ? const Center(child: Text('Belum ada reminder.'))
      //         : RefreshIndicator(
      //           onRefresh: _loadReminders,
      //           child: ListView.builder(
      //             padding: const EdgeInsets.all(16),
      //             itemCount: reminders.length,
      //             itemBuilder: (context, index) {
      //               final reminder = reminders[index];
      //               return GestureDetector(
      //                 onTap: () async {
      //                   // Arahkan ke halaman edit, bawa data reminder
      //                   await Navigator.push(
      //                     context,
      //                     MaterialPageRoute(
      //                       builder:
      //                           (_) =>
      //                               AddReminderPage(existingReminder: reminder),
      //                     ),
      //                   );
      //                   _loadReminders();
      //                 },
      //                 child: Card(
      //                   margin: const EdgeInsets.only(bottom: 16),
      //                   child: ListTile(
      //                     title: Text(reminder.title),
      //                     subtitle: Column(
      //                       crossAxisAlignment: CrossAxisAlignment.start,
      //                       children: [
      //                         Text(
      //                           '${reminder.dateTime.toLocal()}',
      //                           style: const TextStyle(fontSize: 12),
      //                         ),
      //                         const SizedBox(height: 4),
      //                         Text(
      //                           _formatRepeatDays(reminder.repeatDays),
      //                           style: const TextStyle(
      //                             fontSize: 12,
      //                             fontStyle: FontStyle.italic,
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                     trailing: const Icon(
      //                       Icons.notifications_active,
      //                       color: Colors.blue,
      //                     ),
      //                   ),
      //                 ),
      //               );
      //             },
      //           ),
      //         ),
    );
  }
}
