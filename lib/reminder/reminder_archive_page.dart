import 'package:flutter/material.dart';
import 'package:project/reminder/add_reminder_page.dart';
import 'package:project/reminder/reminder_model.dart';
import 'package:project/reminder/reminder_storage.dart';

class ReminderArchivePage extends StatefulWidget {
  const ReminderArchivePage({super.key});

  @override
  State<ReminderArchivePage> createState() => _ReminderArchivePageState();
}

class _ReminderArchivePageState extends State<ReminderArchivePage> {
  List<ReminderModel> reminders = [];
  List<ReminderModel> filteredReminders = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReminders();

    // Mengatur listener untuk pencarian
    _searchController.addListener(_filterReminders);
  }

  void _loadReminders() async {
    final loadedReminders = await ReminderStorage.getReminders();
    setState(() {
      reminders = loadedReminders;
      filteredReminders = reminders;
    });
  }

  // Fungsi untuk menyaring reminder berdasarkan pencarian
  void _filterReminders() {
    setState(() {
      filteredReminders = reminders
          .where((reminder) =>
              reminder.title.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminder Archive')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by title',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredReminders.length,
                itemBuilder: (context, index) {
                  final reminder = filteredReminders[index];
                  return ListTile(
                    title: Text(reminder.title),
                    subtitle: Text(reminder.dateTime.toString()),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddReminderPage(existingReminder: reminder),
                            ),
                          ).then((_) => _loadReminders());
                        } else if (value == 'delete') {
                          setState(() {
                            ReminderStorage.deleteReminder(index);
                            _loadReminders();
                          });
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
