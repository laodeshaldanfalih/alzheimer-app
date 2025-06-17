class GDSHistoryEntry {
  final DateTime date;
  final int score;
  final bool isDepressed;

  GDSHistoryEntry({
    required this.date,
    required this.score,
    required this.isDepressed,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'score': score,
      'isDepressed': isDepressed,
    };
  }

  factory GDSHistoryEntry.fromJson(Map<String, dynamic> json) {
    return GDSHistoryEntry(
      date: DateTime.parse(json['date']),
      score: json['score'],
      isDepressed: json['isDepressed'],
    );
  }
}
