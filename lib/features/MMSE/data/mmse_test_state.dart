import 'package:flutter/material.dart';

class MMSETestState {
  final List<String?> orientationTimeAnswers;
  final List<String?> orientationPlaceAnswers;
  final int registrationScore;
  final int registrationRepetitions;
  final int attentionScore;
  final int recallScore;
  final int? bendaScore;
  final String? kataAnswer;
  final int? instruksiScore;
  final String? angkatTanganAnswer;
  final String? tulisKalimatAnswer;
  final String? tiruGambarAnswer;

  MMSETestState({
    this.orientationTimeAnswers = const [],
    this.orientationPlaceAnswers = const [],
    this.registrationScore = 0,
    this.registrationRepetitions = 0,
    this.attentionScore = 0,
    this.recallScore = 0,
    this.bendaScore,
    this.kataAnswer,
    this.instruksiScore,
    this.angkatTanganAnswer,
    this.tulisKalimatAnswer,
    this.tiruGambarAnswer,
  });

  int get totalScore {
    int score = 0;

    // Orientation Time (5 points)
    score += orientationTimeAnswers.where((answer) => answer == "Benar").length;

    // Orientation Place (5 points)
    score +=
        orientationPlaceAnswers.where((answer) => answer == "Benar").length;

    // Registration (3 points)
    score += registrationScore;

    // Attention and Calculation (5 points)
    score += attentionScore;

    // Recall (3 points)
    score += recallScore;

    // Language (9 points)
    score += bendaScore ?? 0;
    score += kataAnswer == "Benar" ? 1 : 0;
    score += instruksiScore ?? 0;
    score += angkatTanganAnswer == "Benar" ? 1 : 0;
    score += tulisKalimatAnswer == "Benar" ? 1 : 0;
    score += tiruGambarAnswer == "Benar" ? 1 : 0;

    return score;
  }

  MMSETestState copyWith({
    List<String?>? orientationTimeAnswers,
    List<String?>? orientationPlaceAnswers,
    int? registrationScore,
    int? registrationRepetitions,
    int? attentionScore,
    int? recallScore,
    int? bendaScore,
    String? kataAnswer,
    int? instruksiScore,
    String? angkatTanganAnswer,
    String? tulisKalimatAnswer,
    String? tiruGambarAnswer,
  }) {
    return MMSETestState(
      orientationTimeAnswers:
          orientationTimeAnswers ?? this.orientationTimeAnswers,
      orientationPlaceAnswers:
          orientationPlaceAnswers ?? this.orientationPlaceAnswers,
      registrationScore: registrationScore ?? this.registrationScore,
      registrationRepetitions:
          registrationRepetitions ?? this.registrationRepetitions,
      attentionScore: attentionScore ?? this.attentionScore,
      recallScore: recallScore ?? this.recallScore,
      bendaScore: bendaScore ?? this.bendaScore,
      kataAnswer: kataAnswer ?? this.kataAnswer,
      instruksiScore: instruksiScore ?? this.instruksiScore,
      angkatTanganAnswer: angkatTanganAnswer ?? this.angkatTanganAnswer,
      tulisKalimatAnswer: tulisKalimatAnswer ?? this.tulisKalimatAnswer,
      tiruGambarAnswer: tiruGambarAnswer ?? this.tiruGambarAnswer,
    );
  }
}
