import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project/reminder/reminder_model.dart';
import 'package:project/reminder/reminder_storage.dart';
import 'package:project/reminder/reminder_page_service.dart';

class AddReminderPage extends StatefulWidget {
  final ReminderModel? existingReminder;

  const AddReminderPage({Key? key, this.existingReminder}) : super(key: key);

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  late TextEditingController _titleController;
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

    if (widget.existingReminder != null) {
      selectedDate = widget.existingReminder!.dateTime;
      selectedTime = TimeOfDay.fromDateTime(widget.existingReminder!.dateTime);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
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
      dateTime: _calculateFinalDateTime(),
      repeatDays: repeatDays,
    );

    if (widget.existingReminder == null) {
      await ReminderStorage.addReminder(reminder);
    } else {
      await ReminderStorage.updateReminder(widget.existingReminder!, reminder);
    }

    await ReminderPageService().scheduleCustomNotification(reminder);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildDaySelector() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: repeatDays.keys.map((day) {
        final selected = repeatDays[day]!;
        return ChoiceChip(
          label: Text(day),
          selected: selected,
          selectedColor: Colors.blue,
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
      appBar: AppBar(title: const Text('Add Reminder')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Reminder Title'),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 10),
                Text(
                  "${selectedDate.toLocal()}".split(' ')[0],
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text('Pilih Tanggal'),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text('Pilih Waktu:', style: TextStyle(fontSize: 16)),
            SizedBox(
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
                    selectedTime = TimeOfDay(hour: newTime.hour, minute: newTime.minute);
                  });
                },
              ),
            ),

            const SizedBox(height: 20),
            const Text('Pilih Hari Pengulangan:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            _buildDaySelector(),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _saveReminder,
                child: const Text('Simpan Reminder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
