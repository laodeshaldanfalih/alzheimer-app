import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/features/auth/providers/auth_provider.dart';
import '../models/skilas_test_entry.dart';

class SKILASHistoryState {
  final List<SKILASHistoryEntry> history;
  final bool sortByScore;
  final bool isLoading;

  SKILASHistoryState({
    this.history = const [],
    this.sortByScore = false,
    this.isLoading = false,
  });

  SKILASHistoryState copyWith({
    List<SKILASHistoryEntry>? history,
    bool? sortByScore,
    bool? isLoading,
  }) {
    return SKILASHistoryState(
      history: history ?? this.history,
      sortByScore: sortByScore ?? this.sortByScore,
      isLoading: isLoading ?? this.isLoading,
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
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SKILASHistoryNotifier(this._firestore, this._auth)
    : super(SKILASHistoryState());

  Future<void> loadHistory() async {
    final user = _auth.currentUser;
    if (user == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final snapshot =
          await _firestore
              .collection('skilas_tests')
              .doc(user.uid)
              .collection('tests')
              .orderBy('date', descending: true)
              .get();

      final history =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return SKILASHistoryEntry(
              score: data['score'],
              date: (data['date'] as Timestamp).toDate(),
              page1Answers: List<String?>.from(data['page1Answers']),
              page2Answers: List<String?>.from(data['page2Answers']),
              page3Answers: List<String?>.from(data['page3Answers']),
            );
          }).toList();

      state = state.copyWith(history: history, isLoading: false);
    } catch (e) {
      print('Error loading SKILAS history: $e');
      state = state.copyWith(isLoading: false);
      // Handle error appropriately
    }
  }

  Future<void> addEntry(SKILASHistoryEntry entry) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Create a new document with auto-generated ID
      final docRef =
          _firestore
              .collection('skilas_tests')
              .doc(user.uid)
              .collection('tests')
              .doc();

      await docRef.set({
        'score': entry.score,
        'date': Timestamp.fromDate(entry.date),
        'page1Answers': entry.page1Answers,
        'page2Answers': entry.page2Answers,
        'page3Answers': entry.page3Answers,
      });

      // Update local state
      final newHistory = [...state.history, entry];
      state = state.copyWith(history: newHistory);
    } catch (e) {
      print('Error adding SKILAS entry: $e');
      // Handle error appropriately
    }
  }

  void toggleSort() {
    state = state.copyWith(sortByScore: !state.sortByScore);
  }
}

final skilasHistoryProvider =
    StateNotifierProvider<SKILASHistoryNotifier, SKILASHistoryState>((ref) {
      final firestore = ref.watch(firestoreProvider);
      final auth = ref.watch(firebaseAuthProvider);
      return SKILASHistoryNotifier(firestore, auth);
    });
