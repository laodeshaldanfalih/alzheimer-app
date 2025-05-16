import 'package:flutter_riverpod/flutter_riverpod.dart';

class SKILASTestState {
  final List<String?> page1Answers;
  final List<String?> page2Answers;
  final List<String?> page3Answers;

  SKILASTestState({
    this.page1Answers = const [],
    this.page2Answers = const [],
    this.page3Answers = const [],
  });

  SKILASTestState copyWith({
    List<String?>? page1Answers,
    List<String?>? page2Answers,
    List<String?>? page3Answers,
  }) {
    return SKILASTestState(
      page1Answers: page1Answers ?? this.page1Answers,
      page2Answers: page2Answers ?? this.page2Answers,
      page3Answers: page3Answers ?? this.page3Answers,
    );
  }

  bool get isAnyAnswerWrong {
    return [
      ...page1Answers,
      ...page2Answers,
      ...page3Answers,
    ].contains('Salah');
  }
}

class SKILASTestNotifier extends StateNotifier<SKILASTestState> {
  SKILASTestNotifier()
    : super(
        SKILASTestState(
          page1Answers: List.filled(4, null),
          page2Answers: List.filled(3, null),
          page3Answers: List.filled(2, null),
        ),
      );

  void setPage1Answers(List<String?> answers) {
    state = state.copyWith(page1Answers: List.from(answers));
  }

  void setPage2Answers(List<String?> answers) {
    state = state.copyWith(page2Answers: List.from(answers));
  }

  void setPage3Answers(List<String?> answers) {
    state = state.copyWith(page3Answers: List.from(answers));
  }

  void reset() {
    state = SKILASTestState(
      page1Answers: List.filled(4, null),
      page2Answers: List.filled(3, null),
      page3Answers: List.filled(2, null),
    );
  }
}

final skilasTestProvider =
    StateNotifierProvider<SKILASTestNotifier, SKILASTestState>((ref) {
      return SKILASTestNotifier();
    });
