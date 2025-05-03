class MMSEHistoryEntry {
  final int score;
  final DateTime date;

  MMSEHistoryEntry({required this.score, required this.date});

  Map<String, dynamic> toJson() => {
    'score': score,
    'date': date.toIso8601String(),
  };

  factory MMSEHistoryEntry.fromJson(Map<String, dynamic> json) =>
      MMSEHistoryEntry(
        score: json['score'],
        date: DateTime.parse(json['date']),
      );
}
