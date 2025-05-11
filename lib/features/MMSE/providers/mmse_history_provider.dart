import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/mmse_history_entry.dart';

class MMSEHistoryState {
  final List<MMSEHistoryEntry> history;
  final bool sortByScore;

  MMSEHistoryState({this.history = const [], this.sortByScore = false});

  MMSEHistoryState copyWith({
    List<MMSEHistoryEntry>? history,
    bool? sortByScore,
  }) {
    return MMSEHistoryState(
      history: history ?? this.history,
      sortByScore: sortByScore ?? this.sortByScore,
    );
  }

  List<MMSEHistoryEntry> get sortedHistory {
    List<MMSEHistoryEntry> sorted = List.from(history);
    if (sortByScore) {
      sorted.sort((a, b) => b.score.compareTo(a.score));
    } else {
      sorted.sort((a, b) => b.date.compareTo(a.date));
    }
    return sorted;
  }
}

class MMSEHistoryNotifier extends StateNotifier<MMSEHistoryState> {
  MMSEHistoryNotifier() : super(MMSEHistoryState());

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('mmse_history') ?? [];
    final history =
        data.map((e) => MMSEHistoryEntry.fromJson(json.decode(e))).toList();
    state = state.copyWith(history: history);
  }

  Future<void> addEntry(MMSEHistoryEntry entry) async {
    final newHistory = [...state.history, entry];
    state = state.copyWith(history: newHistory);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'mmse_history',
      newHistory.map((e) => json.encode(e.toJson())).toList(),
    );
  }

  void toggleSort() {
    state = state.copyWith(sortByScore: !state.sortByScore);
  }
}

final mmseHistoryProvider =
    StateNotifierProvider<MMSEHistoryNotifier, MMSEHistoryState>((ref) {
      return MMSEHistoryNotifier();
    });
