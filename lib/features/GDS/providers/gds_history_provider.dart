import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/gds_history_entry.dart';
import 'package:project/features/auth/providers/auth_provider.dart';

class GDSHistoryState {
  final List<GDSHistoryEntry> history;
  final bool sortByScore;
  final bool isLoading;

  GDSHistoryState({
    this.history = const [],
    this.sortByScore = false,
    this.isLoading = false,
  });

  GDSHistoryState copyWith({
    List<GDSHistoryEntry>? history,
    bool? sortByScore,
    bool? isLoading,
  }) {
    return GDSHistoryState(
      history: history ?? this.history,
      sortByScore: sortByScore ?? this.sortByScore,
      isLoading: isLoading ?? this.isLoading,
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
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  GDSHistoryNotifier(this._firestore, this._auth) : super(GDSHistoryState());

  Future<void> loadHistory() async {
    final user = _auth.currentUser;
    if (user == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final snapshot =
          await _firestore
              .collection('gds_tests')
              .doc(user.uid)
              .collection('tests')
              .orderBy('date', descending: true)
              .get();

      final history =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return GDSHistoryEntry(
              score: data['score'],
              date: (data['date'] as Timestamp).toDate(),
              isDepressed: data['isDepressed'],
              answers: List<String>.from(data['answers']),
            );
          }).toList();

      state = state.copyWith(history: history, isLoading: false);
    } catch (e) {
      print('Error loading GDS history: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addEntry(GDSHistoryEntry entry) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final docRef =
          _firestore
              .collection('gds_tests')
              .doc(user.uid)
              .collection('tests')
              .doc();

      await docRef.set({
        'score': entry.score,
        'date': Timestamp.fromDate(entry.date),
        'isDepressed': entry.isDepressed,
        'answers': entry.answers,
      });

      final newHistory = [...state.history, entry];
      state = state.copyWith(history: newHistory);
    } catch (e) {
      print('Error adding GDS entry: $e');
    }
  }

  void toggleSort() {
    state = state.copyWith(sortByScore: !state.sortByScore);
  }
}

final gdsHistoryProvider =
    StateNotifierProvider<GDSHistoryNotifier, GDSHistoryState>((ref) {
      final firestore = ref.watch(firestoreProvider);
      final auth = ref.watch(firebaseAuthProvider);
      return GDSHistoryNotifier(firestore, auth);
    });
