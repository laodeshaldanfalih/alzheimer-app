import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project/features/reminder/reminder_model.dart';
import 'package:project/features/reminder/reminder_page_service.dart';
import 'package:project/features/reminder/reminder_storage.dart';
import 'package:project/reminder/reminder_model.dart';

class AddReminderPage extends StatefulWidget {
  final ReminderModel? existingReminder;

  const AddReminderPage({super.key, this.existingReminder});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  Map<String, bool> repeatDays = {
    "Senin": false,
    "Selasa": false,
    "Rabu": false,
    "Kamis": false,
    "Jumat": false,
    "Sabtu": false,
    "Minggu": false,
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingReminder?.title ?? '',
    );

    _descriptionController = TextEditingController(
      text: widget.existingReminder?.description ?? '',
    );

    if (widget.existingReminder != null) {
      selectedDate = widget.existingReminder!.dateTime;
      selectedTime = TimeOfDay.fromDateTime(widget.existingReminder!.dateTime);
      repeatDays = Map<String, bool>.from(
        widget.existingReminder!.repeatDays ?? repeatDays,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  DateTime _calculateFinalDateTime() {
    final now = DateTime.now();
    DateTime tentative = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (tentative.isBefore(now)) {
      tentative = tentative.add(const Duration(days: 1));
    }

    return tentative;
  }

  Future<void> _saveReminder() async {
    if (_titleController.text.isEmpty) return;

    final reminder = ReminderModel(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(), // Tambahkan ini
      dateTime: _calculateFinalDateTime(),
      repeatDays: repeatDays,
    );

    if (widget.existingReminder == null) {
      await ReminderStorage.addReminder(reminder);
    } else {
      await ReminderStorage.updateReminder(widget.existingReminder!, reminder);
    }

    await ReminderPageService().scheduleCustomNotification(reminder);

    if (mounted) Navigator.pop(context);
  }

  Widget _buildDaySelector() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children:
          repeatDays.keys.map((day) {
            final selected = repeatDays[day]!;
            return ChoiceChip(
              label: Text(day),
              selected: selected,
              selectedColor: Colors.blue,
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black,
              ),
              onSelected: (value) {
                setState(() {
                  repeatDays[day] = value;
                });
              },
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingReminder == null ? 'Tambah Reminder' : 'Edit Reminder',
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Reminder
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Judul Reminder',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tanggal
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.blue),
                  const SizedBox(width: 10),
                  Text(
                    "${selectedDate.toLocal()}".split(' ')[0],
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  TextButton(onPressed: _pickDate, child: const Text('Ubah')),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Waktu
            const Text('Pilih Waktu:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              height: 150,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(
                  0,
                  0,
                  0,
                  selectedTime.hour,
                  selectedTime.minute,
                ),
                use24hFormat: true,
                onDateTimeChanged: (DateTime newTime) {
                  setState(() {
                    selectedTime = TimeOfDay(
                      hour: newTime.hour,
                      minute: newTime.minute,
                    );
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // Pengulangan
            const Text(
              'Pilih Hari Pengulangan:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildDaySelector(),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _saveReminder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Simpan Reminder',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
