class SKILASHistoryEntry {
  final int score; // 1 = normal, 0 = perlu ke rumah sakit
  final DateTime date;

  SKILASHistoryEntry({required this.score, required this.date});

  Map<String, dynamic> toJson() => {
    'score': score,
    'date': date.toIso8601String(),
  };

  factory SKILASHistoryEntry.fromJson(Map<String, dynamic> json) =>
      SKILASHistoryEntry(
        score: json['score'],
        date: DateTime.parse(json['date']),
      );
}
