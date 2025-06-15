import 'package:flutter/foundation.dart';

class GDSTestResult {
  final DateTime date;
  final int score;
  final bool isDepressed;

  GDSTestResult({
    required this.date,
    required this.score,
    required this.isDepressed,
  });
}

class GDSTestState extends ChangeNotifier {
  final List<GDSTestResult> _testHistory = [];
  int _currentScore = 0;

  List<GDSTestResult> get testHistory => _testHistory;
  int get currentScore => _currentScore;

  void updateScore(int score) {
    _currentScore = score;
    notifyListeners();
  }

  void addTestResult(int score) {
    final result = GDSTestResult(
      date: DateTime.now(),
      score: score,
      isDepressed: score >= 5,
    );
    _testHistory.insert(0, result);
    notifyListeners();
  }

  void clearCurrentScore() {
    _currentScore = 0;
    notifyListeners();
  }
}
