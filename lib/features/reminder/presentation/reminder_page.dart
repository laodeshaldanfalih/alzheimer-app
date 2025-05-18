import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:project/features/reminder/presentation/add_reminder_page.dart';
import 'package:project/features/reminder/provider/reminder_storage.dart';
import 'package:project/features/reminder/model/reminder_model.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  List<ReminderModel> reminders = [];
  List<ReminderModel> filteredReminders = [];
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
    _loadReminders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterReminders(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredReminders = List.from(reminders);
      } else {
        filteredReminders =
            reminders.where((reminder) {
              final titleLower = reminder.title.toLowerCase();
              final descriptionLower = reminder.description.toLowerCase();
              final searchLower = query.toLowerCase();
              return titleLower.contains(searchLower) ||
                  descriptionLower.contains(searchLower);
            }).toList();
      }
    });
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
      filteredReminders = List.from(loadedReminders);
    });
  }

  String _formatRepeatDays(Map<String, bool>? repeatDays) {
    if (repeatDays == null || repeatDays.values.every((value) => !value)) {
      return "Tidak berulang";
    }
    return repeatDays.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key.substring(0, 3))
        .join(", ");
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: _filterReminders,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Icon(Icons.search, color: Color(0xFF2D3142), size: 28),
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: Color(0xFF2D3142)),
                    onPressed: () {
                      _searchController.clear();
                      _filterReminders('');
                    },
                  )
                  : null,
          hintText: 'Cari Reminder',
          hintStyle: const TextStyle(color: Color(0xFF6D6D6D), fontSize: 16),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: InputBorder.none,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFB5BED4), width: 1.2),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFB5BED4), width: 1.2),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard(ReminderModel reminder) {
    final timeText = TimeOfDay.fromDateTime(reminder.dateTime).format(context);
    final dateText =
        "${reminder.dateTime.day}/${reminder.dateTime.month}/${reminder.dateTime.year}";

    return Hero(
      tag: 'reminder-${reminder.title}',
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddReminderPage(existingReminder: reminder),
                ),
              );
              _loadReminders();
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.notifications_active,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reminder.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            if (reminder.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                reminder.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red.shade400,
                          size: 24,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: const Text('Hapus Reminder'),
                                  content: const Text(
                                    'Apakah Anda yakin ingin menghapus reminder ini?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: Text(
                                        'Batal',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: Text(
                                        'Hapus',
                                        style: TextStyle(
                                          color: Colors.red.shade400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          );

                          if (confirm == true) {
                            await ReminderStorage.deleteReminder(
                              reminders.indexOf(reminder),
                            );
                            _loadReminders();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.grey.shade50, Colors.grey.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.repeat,
                              color: Colors.grey.shade700,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatRepeatDays(reminder.repeatDays),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade50, Colors.blue.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.blue.shade700,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "$dateText - $timeText",
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Close keyboard
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'Daftar Reminder',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddReminderPage()),
                );
                _loadReminders();
              },
              icon: const Icon(Icons.add, color: Colors.blue),
            ),
            const SizedBox(width: 8),
          ],
        ),

        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child:
                  filteredReminders.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'Tidak ada reminder yang sesuai'
                                  : 'Belum ada reminder',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                      : RefreshIndicator(
                        onRefresh: _loadReminders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredReminders.length,
                          itemBuilder: (context, index) {
                            return _buildReminderCard(filteredReminders[index]);
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
