import 'package:flutter/material.dart';

class SKILASTestState extends ChangeNotifier {
  // Store answers for each page
  List<String?> page1Answers = List.filled(4, null);
  List<String?> page2Answers = List.filled(3, null);
  List<String?> page3Answers = List.filled(2, null);

  // Setters
  void setPage1Answers(List<String?> answers) {
    page1Answers = List.from(answers);
    notifyListeners();
  }

  void setPage2Answers(List<String?> answers) {
    page2Answers = List.from(answers);
    notifyListeners();
  }

  void setPage3Answers(List<String?> answers) {
    page3Answers = List.from(answers);
    notifyListeners();
  }

  // Check if any answer is 'Salah'
  bool get isAnyAnswerWrong {
    return [
      ...page1Answers,
      ...page2Answers,
      ...page3Answers,
    ].contains('Salah');
  }

  // Reset all answers
  void reset() {
    page1Answers = List.filled(4, null);
    page2Answers = List.filled(3, null);
    page3Answers = List.filled(2, null);
    notifyListeners();
  }
}
