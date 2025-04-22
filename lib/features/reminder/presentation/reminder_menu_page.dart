import 'package:flutter/material.dart';
import 'package:project/features/game/presentation/pages/menyusun_makanan_page.dart';
import 'package:project/features/reminder/domain/models/reminder_menu_item.dart';
import 'package:project/features/reminder/sholat_reminder/presentation/sholat_reminder_page.dart';

class ReminderMenuPage extends StatelessWidget {
  const ReminderMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ReminderMenuItem> reminders = [
      ReminderMenuItem(
        title: 'Pengingat Solat',
        description: 'Pengingat Solat',
        emoji: '🧎🏻',
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => SholatPage()));
        },
      ),
      ReminderMenuItem(
        title: 'Pengingat Kegiatan',
        description: 'Buat jadwal kegiatan harian dan dapatkan pengingat',
        emoji: '📅',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => MenyusunMakananPage()),
          );
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pengingat', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = reminders[index];
                    return _buildReminderCard(reminder);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard(ReminderMenuItem reminder) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: reminder.onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      reminder.emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                reminder.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 3),
              Text(
                reminder.description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  height: 1.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
