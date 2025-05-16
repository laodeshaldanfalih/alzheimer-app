class ReminderModel {
  String title;
  String description; // Tambahkan ini
  DateTime dateTime;
  Map<String, bool>? repeatDays;

  ReminderModel({
    required this.title,
    this.description = '', // Default kosong
    required this.dateTime,
    this.repeatDays,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description, // Tambahkan ini
      'dateTime': dateTime.toIso8601String(),
      'repeatDays': repeatDays,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      title: map['title'],
      description: map['description'] ?? '', // Tambahkan ini
      dateTime: DateTime.parse(map['dateTime']),
      repeatDays: Map<String, bool>.from(map['repeatDays'] ?? {}),
    );
  }
}