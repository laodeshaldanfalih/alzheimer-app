import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/gds_history_entry.dart';

class GDSHistoryState {
  final List<GDSHistoryEntry> history;
  final bool sortByScore;

  GDSHistoryState({this.history = const [], this.sortByScore = false});

  GDSHistoryState copyWith({
    List<GDSHistoryEntry>? history,
    bool? sortByScore,
  }) {
    return GDSHistoryState(
      history: history ?? this.history,
      sortByScore: sortByScore ?? this.sortByScore,
    );
  }

  List<GDSHistoryEntry> get sortedHistory {
    List<GDSHistoryEntry> sorted = List.from(history);
    if (sortByScore) {
      sorted.sort((a, b) => b.score.compareTo(a.score));
    } else {
      sorted.sort((a, b) => b.date.compareTo(a.date));
    }
    return sorted;
  }
}

class GDSHistoryNotifier extends StateNotifier<GDSHistoryState> {
  GDSHistoryNotifier() : super(GDSHistoryState());

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('gds_history') ?? [];
    final history =
        data.map((e) {
          final jsonMap = json.decode(e);
          // Backward compatibility: if answers missing, fill with empty list
          return GDSHistoryEntry.fromJson({
            ...jsonMap,
            'answers': jsonMap['answers'] ?? List<String>.filled(15, '-'),
          });
        }).toList();
    state = state.copyWith(history: history);
  }

  Future<void> addEntry(GDSHistoryEntry entry) async {
    final newHistory = [...state.history, entry];
    state = state.copyWith(history: newHistory);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'gds_history',
      newHistory.map((e) => json.encode(e.toJson())).toList(),
    );
  }

  void toggleSort() {
    state = state.copyWith(sortByScore: !state.sortByScore);
  }
}

final gdsHistoryProvider =
    StateNotifierProvider<GDSHistoryNotifier, GDSHistoryState>((ref) {
      return GDSHistoryNotifier();
    });
