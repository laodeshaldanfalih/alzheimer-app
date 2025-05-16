import 'package:flutter_riverpod/flutter_riverpod.dart';

class GDSTestState {
  // GDS Questions
  final List<String?> answers;
  final int? totalScore;

  GDSTestState({this.answers = const [], this.totalScore});

  GDSTestState copyWith({List<String?>? answers, int? totalScore}) {
    return GDSTestState(
      answers: answers ?? this.answers,
      totalScore: totalScore ?? this.totalScore,
    );
  }

  // Calculate total score (GDS specific)
  int calculateTotalScore() {
    int score = 0;
    // Indeks yang skor 1 jika jawabannya 'Tidak'
    const reverseScored = [0, 4, 6, 10, 12];
    for (int i = 0; i < answers.length; i++) {
      final ans = answers[i];
      if (reverseScored.contains(i)) {
        if (ans == 'Tidak') score++;
      } else {
        if (ans == 'Ya') score++;
      }
    }
    return score;
  }

  // Check if all questions are answered
  bool isComplete() {
    return !answers.contains(null);
  }

  // Helper: apakah depressed?
  bool get isDepressed => (totalScore ?? 0) >= 5;
}

class GDSTestNotifier extends StateNotifier<GDSTestState> {
  GDSTestNotifier()
    : super(
        GDSTestState(
          answers: List.filled(15, null), // GDS has 15 questions
        ),
      );

  void setAnswers(List<String?> answers) {
    // Indeks yang skor 1 jika jawabannya 'Tidak'
    const reverseScored = [0, 4, 6, 10, 12];
    int score = 0;
    for (int i = 0; i < answers.length; i++) {
      final ans = answers[i];
      if (reverseScored.contains(i)) {
        if (ans == 'Tidak') score++;
      } else {
        if (ans == 'Ya') score++;
      }
    }
    state = state.copyWith(answers: List.from(answers), totalScore: score);
  }

  void reset() {
    state = GDSTestState(answers: List.filled(15, null));
  }
}

final gdsTestProvider = StateNotifierProvider<GDSTestNotifier, GDSTestState>((
  ref,
) {
  return GDSTestNotifier();
});
