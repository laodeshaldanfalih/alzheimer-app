class MMSEHistoryEntry {
  final int score;
  final DateTime date;

  // Page 1 - Orientation Time
  final List<String?> orientationTimeAnswers;

  // Page 2 - Orientation Place
  final List<String?> orientationPlaceAnswers;

  // Page 3 - Registration
  final int? registrationScore;
  final int? registrationRepetitions;

  // Page 4 - Attention and Recall
  final int? attentionScore;
  final int? recallScore;

  // Page 5 - Language
  final int? bendaScore;
  final String? kataAnswer;
  final int? instruksiScore;
  final String? angkatTanganAnswer;
  final String? tulisKalimatAnswer;
  final String? tiruGambarAnswer;

  MMSEHistoryEntry({
    required this.score,
    required this.date,
    required this.orientationTimeAnswers,
    required this.orientationPlaceAnswers,
    required this.registrationScore,
    required this.registrationRepetitions,
    required this.attentionScore,
    required this.recallScore,
    required this.bendaScore,
    required this.kataAnswer,
    required this.instruksiScore,
    required this.angkatTanganAnswer,
    required this.tulisKalimatAnswer,
    required this.tiruGambarAnswer,
  });

  Map<String, dynamic> toJson() => {
    'score': score,
    'date': date.toIso8601String(),
    'orientationTimeAnswers': orientationTimeAnswers,
    'orientationPlaceAnswers': orientationPlaceAnswers,
    'registrationScore': registrationScore,
    'registrationRepetitions': registrationRepetitions,
    'attentionScore': attentionScore,
    'recallScore': recallScore,
    'bendaScore': bendaScore,
    'kataAnswer': kataAnswer,
    'instruksiScore': instruksiScore,
    'angkatTanganAnswer': angkatTanganAnswer,
    'tulisKalimatAnswer': tulisKalimatAnswer,
    'tiruGambarAnswer': tiruGambarAnswer,
  };

  factory MMSEHistoryEntry.fromJson(Map<String, dynamic> json) =>
      MMSEHistoryEntry(
        score: json['score'],
        date: DateTime.parse(json['date']),
        orientationTimeAnswers: List<String?>.from(
          json['orientationTimeAnswers'],
        ),
        orientationPlaceAnswers: List<String?>.from(
          json['orientationPlaceAnswers'],
        ),
        registrationScore: json['registrationScore'],
        registrationRepetitions: json['registrationRepetitions'],
        attentionScore: json['attentionScore'],
        recallScore: json['recallScore'],
        bendaScore: json['bendaScore'],
        kataAnswer: json['kataAnswer'],
        instruksiScore: json['instruksiScore'],
        angkatTanganAnswer: json['angkatTanganAnswer'],
        tulisKalimatAnswer: json['tulisKalimatAnswer'],
        tiruGambarAnswer: json['tiruGambarAnswer'],
      );
}
