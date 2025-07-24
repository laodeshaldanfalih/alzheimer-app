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
    }
  }

  Future<void> addEntry(SKILASHistoryEntry entry) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
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

      final newHistory = [entry, ...state.history];
      state = state.copyWith(history: newHistory);
      // await loadHistory(); // Uncomment jika ingin selalu refresh dari Firestore setelah add
    } catch (e) {
      print('Error adding SKILAS entry: $e');
    }
  }

  Future<void> deleteEntry(SKILASHistoryEntry entryToDelete) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    state = state.copyWith(isLoading: true);

    try {
      final querySnapshot = await _firestore
          .collection('skilas_tests')
          .doc(user.uid)
          .collection('tests')
          .where('date', isEqualTo: Timestamp.fromDate(entryToDelete.date))
          .where('score', isEqualTo: entryToDelete.score)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        await _firestore
            .collection('skilas_tests')
            .doc(user.uid)
            .collection('tests')
            .doc(docId)
            .delete();

        final updatedHistory = state.history
            .where((entry) =>
                !(entry.date == entryToDelete.date &&
                    entry.score == entryToDelete.score)) // Asumsi date & score cukup unik
            .toList();
        state = state.copyWith(history: updatedHistory, isLoading: false);
      } else {
        print('SKILAS entry to delete not found in Firestore.');
        final updatedHistory = state.history
            .where((entry) =>
                !(entry.date == entryToDelete.date &&
                    entry.score == entryToDelete.score))
            .toList();
        if (updatedHistory.length < state.history.length) {
           state = state.copyWith(history: updatedHistory, isLoading: false);
        } else {
           state = state.copyWith(isLoading: false);
        }
      }
    } catch (e) {
      print('Error deleting SKILAS entry: $e');
      state = state.copyWith(isLoading: false);
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