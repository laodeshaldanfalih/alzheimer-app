import 'package:flutter/material.dart';

class MMSETestState extends ChangeNotifier {
  // Page 1 - Orientation Time
  List<String?> orientationTimeAnswers = List.filled(5, null);
  int? orientationTimeScore;

  // Page 2 - Orientation Place
  List<String?> orientationPlaceAnswers = List.filled(5, null);
  int? orientationPlaceScore;

  // Page 3 - Registration
  int? registrationScore;
  int? registrationRepetitions;

  // Page 4 - Attention and Recall
  int? attentionScore;
  int? recallScore;

  // Page 5 - Language
  int? bendaScore;
  String? kataAnswer;
  int? instruksiScore;
  String? angkatTanganAnswer;
  String? tulisKalimatAnswer;
  String? tiruGambarAnswer;

  // Calculate total score
  int get totalScore {
    int score = 0;

    // Page 1 scores
    score += orientationTimeScore ?? 0;
    score += orientationPlaceScore ?? 0;
    score += registrationScore ?? 0;

    // Page 2 scores
    score += attentionScore ?? 0;
    score += recallScore ?? 0;

    // Page 5 scores
    score += bendaScore ?? 0;
    score += (kataAnswer == "Benar" ? 1 : 0);
    score += instruksiScore ?? 0;
    score += (angkatTanganAnswer == "Benar" ? 1 : 0);
    score += (tulisKalimatAnswer == "Benar" ? 1 : 0);
    score += (tiruGambarAnswer == "Benar" ? 1 : 0);

    return score;
  }

  // Check if all questions in a page are answered
  bool isPage1Complete() {
    return !orientationTimeAnswers.contains(null);
  }

  bool isPage2Complete() {
    return !orientationPlaceAnswers.contains(null);
  }

  bool isPage3Complete() {
    return registrationScore != null;
  }

  bool isPage4Complete() {
    return attentionScore != null && recallScore != null;
  }

  bool isPage5Complete() {
    return bendaScore != null &&
        kataAnswer != null &&
        instruksiScore != null &&
        angkatTanganAnswer != null &&
        tulisKalimatAnswer != null &&
        tiruGambarAnswer != null;
  }

  // Reset all scores
  void reset() {
    orientationTimeAnswers = List.filled(5, null);
    orientationTimeScore = null;
    orientationPlaceAnswers = List.filled(5, null);
    orientationPlaceScore = null;
    registrationScore = null;
    registrationRepetitions = null;
    attentionScore = null;
    recallScore = null;
    bendaScore = null;
    kataAnswer = null;
    instruksiScore = null;
    angkatTanganAnswer = null;
    tulisKalimatAnswer = null;
    tiruGambarAnswer = null;
    notifyListeners();
  }
}
