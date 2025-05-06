import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project/reminder/reminder_model.dart';

class ReminderStorage {
  static const _reminderKey = 'reminders';

  // Menyimpan reminder ke shared preferences
  static Future<void> saveReminders(List<ReminderModel> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = reminders.map((reminder) => reminder.toMap()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_reminderKey, jsonString);
  }

  // Mengambil list reminder dari shared preferences
  static Future<List<ReminderModel>> getReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_reminderKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((map) => ReminderModel.fromMap(map)).toList();
  }

  // Menambahkan reminder baru
  static Future<void> addReminder(ReminderModel reminder) async {
    final reminders = await getReminders();
    reminders.add(reminder);  // Menambahkan reminder baru ke dalam list
    await saveReminders(reminders);  // Menyimpan list terbaru ke SharedPreferences
  }

  // Memperbarui reminder yang sudah ada
  static Future<void> updateReminder(ReminderModel oldReminder, ReminderModel newReminder) async {
    final reminders = await getReminders();
    final index = reminders.indexWhere((reminder) => reminder == oldReminder); // Mencari index dari reminder yang lama
    if (index != -1) {
      reminders[index] = newReminder;  // Mengupdate reminder yang ditemukan
      await saveReminders(reminders);  // Menyimpan list terbaru ke SharedPreferences
    }
  }

  // Menghapus reminder berdasarkan index
  static Future<void> deleteReminder(int index) async {
    final reminders = await getReminders();
    reminders.removeAt(index);  // Menghapus reminder di index tersebut
    await saveReminders(reminders);  // Menyimpan list terbaru ke SharedPreferences
  }
}
