import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/skilas_test_entry.dart';

class SKILASHistoryState {
  final List<SKILASHistoryEntry> history;
  final bool sortByScore;

  SKILASHistoryState({this.history = const [], this.sortByScore = false});

  SKILASHistoryState copyWith({
    List<SKILASHistoryEntry>? history,
    bool? sortByScore,
  }) {
    return SKILASHistoryState(
      history: history ?? this.history,
      sortByScore: sortByScore ?? this.sortByScore,
    );
  }

  List<SKILASHistoryEntry> get sortedHistory {
    List<SKILASHistoryEntry> sorted = List.from(history);
    if (sortByScore) {
      sorted.sort((a, b) => b.score.compareTo(a.score));
    } else {
      sorted.sort((a, b) => b.date.compareTo(a.date));
    }
    return sorted;
  }
}

class SKILASHistoryNotifier extends StateNotifier<SKILASHistoryState> {
  SKILASHistoryNotifier() : super(SKILASHistoryState());

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('skilas_history') ?? [];
    final history =
        data.map((e) => SKILASHistoryEntry.fromJson(json.decode(e))).toList();
    state = state.copyWith(history: history);
  }

  Future<void> addEntry(SKILASHistoryEntry entry) async {
    final newHistory = [...state.history, entry];
    state = state.copyWith(history: newHistory);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'skilas_history',
      newHistory.map((e) => json.encode(e.toJson())).toList(),
    );
  }

  void toggleSort() {
    state = state.copyWith(sortByScore: !state.sortByScore);
  }
}

final skilasHistoryProvider =
    StateNotifierProvider<SKILASHistoryNotifier, SKILASHistoryState>((ref) {
      return SKILASHistoryNotifier();
    });
