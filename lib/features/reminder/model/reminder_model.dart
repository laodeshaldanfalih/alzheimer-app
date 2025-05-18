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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReminderModel &&
        other.title == title &&
        other.description == description &&
        other.dateTime == dateTime &&
        mapEquals(other.repeatDays, repeatDays);
  }

  @override
  int get hashCode {
    return Object.hash(
      title,
      description,
      dateTime,
      repeatDays != null ? Object.hashAll(repeatDays!.entries) : null,
    );
  }
}

// Helper function to compare maps
bool mapEquals(Map<String, bool>? map1, Map<String, bool>? map2) {
  if (map1 == null && map2 == null) return true;
  if (map1 == null || map2 == null) return false;
  if (map1.length != map2.length) return false;
  return map1.entries.every((entry) => map2[entry.key] == entry.value);
}
