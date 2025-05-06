class ReminderModel {
  String title;
  DateTime dateTime;
  Map<String, bool>? repeatDays;

  ReminderModel({required this.title, required this.dateTime, this.repeatDays});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'repeatDays': repeatDays,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      title: map['title'],
      dateTime: DateTime.parse(map['dateTime']),
      repeatDays: Map<String, bool>.from(map['repeatDays'] ?? {}),
    );
  }
}
