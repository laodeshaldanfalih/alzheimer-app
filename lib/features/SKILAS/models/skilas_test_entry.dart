class SKILASHistoryEntry {
  final int score; // 1 = normal, 0 = perlu ke rumah sakit
  final DateTime date;
  final List<String?> page1Answers; // Cognitive decline answers
  final List<String?> page2Answers; // Malnutrition answers
  final List<String?> page3Answers; // Depression answers

  SKILASHistoryEntry({
    required this.score,
    required this.date,
    required this.page1Answers,
    required this.page2Answers,
    required this.page3Answers,
  });

  Map<String, dynamic> toJson() => {
    'score': score,
    'date': date.toIso8601String(),
    'page1Answers': page1Answers,
    'page2Answers': page2Answers,
    'page3Answers': page3Answers,
  };

  factory SKILASHistoryEntry.fromJson(Map<String, dynamic> json) =>
      SKILASHistoryEntry(
        score: json['score'],
        date: DateTime.parse(json['date']),
        page1Answers: List<String?>.from(json['page1Answers']),
        page2Answers: List<String?>.from(json['page2Answers']),
        page3Answers: List<String?>.from(json['page3Answers']),
      );
}
