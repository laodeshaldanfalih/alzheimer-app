import 'package:flutter/material.dart';

class MMSETestState extends ChangeNotifier {
  // Page 1 scores
  int? orientationTimeScore;
  int? orientationPlaceScore;
  int? registrationScore;

  // Page 2 scores
  int? attentionScore;
  int? recallScore;

  // Page 3 scores
  int? namingScore;
  int? repetitionScore;
  int? readingScore;
  int? writingScore;
  int? drawingScore;

  // Page 4 scores
  int? bendaScore;
  int? kataScore;
  int? instruksiScore;
  int? angkatTanganScore;
  int? tulisKalimatScore;
  int? tiruGambarScore;

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

    // Page 3 scores
    score += namingScore ?? 0;
    score += repetitionScore ?? 0;
    score += readingScore ?? 0;
    score += writingScore ?? 0;
    score += drawingScore ?? 0;

    // Page 4 scores
    score += bendaScore ?? 0;
    score += kataScore ?? 0;
    score += instruksiScore ?? 0;
    score += angkatTanganScore ?? 0;
    score += tulisKalimatScore ?? 0;
    score += tiruGambarScore ?? 0;

    return score;
  }

  // Check if all questions in a page are answered
  bool isPage1Complete() {
    return orientationTimeScore != null &&
        orientationPlaceScore != null &&
        registrationScore != null;
  }

  bool isPage2Complete() {
    return attentionScore != null && recallScore != null;
  }

  bool isPage3Complete() {
    return namingScore != null &&
        repetitionScore != null &&
        readingScore != null &&
        writingScore != null &&
        drawingScore != null;
  }

  bool isPage4Complete() {
    return bendaScore != null &&
        kataScore != null &&
        instruksiScore != null &&
        angkatTanganScore != null &&
        tulisKalimatScore != null &&
        tiruGambarScore != null;
  }

  // Reset all scores
  void reset() {
    orientationTimeScore = null;
    orientationPlaceScore = null;
    registrationScore = null;
    attentionScore = null;
    recallScore = null;
    namingScore = null;
    repetitionScore = null;
    readingScore = null;
    writingScore = null;
    drawingScore = null;
    bendaScore = null;
    kataScore = null;
    instruksiScore = null;
    angkatTanganScore = null;
    tulisKalimatScore = null;
    tiruGambarScore = null;
    notifyListeners();
  }
}
