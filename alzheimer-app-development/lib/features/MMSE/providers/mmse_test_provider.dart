import 'package:flutter_riverpod/flutter_riverpod.dart';

class MMSETestState {
  // Page 1 - Orientation Time
  final List<String?> orientationTimeAnswers;
  final int? orientationTimeScore;

  // Page 2 - Orientation Place
  final List<String?> orientationPlaceAnswers;
  final int? orientationPlaceScore;

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

  MMSETestState({
    this.orientationTimeAnswers = const [],
    this.orientationTimeScore,
    this.orientationPlaceAnswers = const [],
    this.orientationPlaceScore,
    this.registrationScore,
    this.registrationRepetitions,
    this.attentionScore,
    this.recallScore,
    this.bendaScore,
    this.kataAnswer,
    this.instruksiScore,
    this.angkatTanganAnswer,
    this.tulisKalimatAnswer,
    this.tiruGambarAnswer,
  });

  MMSETestState copyWith({
    List<String?>? orientationTimeAnswers,
    int? orientationTimeScore,
    List<String?>? orientationPlaceAnswers,
    int? orientationPlaceScore,
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
      orientationTimeScore: orientationTimeScore ?? this.orientationTimeScore,
      orientationPlaceAnswers:
          orientationPlaceAnswers ?? this.orientationPlaceAnswers,
      orientationPlaceScore:
          orientationPlaceScore ?? this.orientationPlaceScore,
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
}

class MMSETestNotifier extends StateNotifier<MMSETestState> {
  MMSETestNotifier()
    : super(
        MMSETestState(
          orientationTimeAnswers: List.filled(5, null),
          orientationPlaceAnswers: List.filled(5, null),
        ),
      );

  void setOrientationTimeAnswers(List<String?> answers) {
    int score = 0;
    for (String? answer in answers) {
      if (answer == "Benar") {
        score++;
      }
    }
    state = state.copyWith(
      orientationTimeAnswers: List.from(answers),
      orientationTimeScore: score,
    );
  }

  void setOrientationPlaceAnswers(List<String?> answers) {
    int score = 0;
    for (String? answer in answers) {
      if (answer == "Benar") {
        score++;
      }
    }
    state = state.copyWith(
      orientationPlaceAnswers: List.from(answers),
      orientationPlaceScore: score,
    );
  }

  void setRegistrationScore(int score, int repetitions) {
    state = state.copyWith(
      registrationScore: score,
      registrationRepetitions: repetitions,
    );
  }

  void setAttentionAndRecallScore(int attentionScore, int recallScore) {
    state = state.copyWith(
      attentionScore: attentionScore,
      recallScore: recallScore,
    );
  }

  void setLanguageScores(
    int? bendaScore,
    String? kataAnswer,
    int? instruksiScore,
    String? angkatTanganAnswer,
    String? tulisKalimatAnswer,
    String? tiruGambarAnswer,
  ) {
    state = state.copyWith(
      bendaScore: bendaScore,
      kataAnswer: kataAnswer,
      instruksiScore: instruksiScore,
      angkatTanganAnswer: angkatTanganAnswer,
      tulisKalimatAnswer: tulisKalimatAnswer,
      tiruGambarAnswer: tiruGambarAnswer,
    );
  }

  void reset() {
    state = MMSETestState(
      orientationTimeAnswers: List.filled(5, null),
      orientationPlaceAnswers: List.filled(5, null),
    );
  }
}

final mmseTestProvider = StateNotifierProvider<MMSETestNotifier, MMSETestState>(
  (ref) {
    return MMSETestNotifier();
  },
);
