import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mmse_history_entry.dart';
import 'package:project/features/auth/providers/auth_provider.dart';

class MMSEHistoryState {
  final List<MMSEHistoryEntry> history;
  final bool sortByScore;
  final bool isLoading;

  MMSEHistoryState({
    this.history = const [],
    this.sortByScore = false,
    this.isLoading = false,
  });

  MMSEHistoryState copyWith({
    List<MMSEHistoryEntry>? history,
    bool? sortByScore,
    bool? isLoading,
  }) {
    return MMSEHistoryState(
      history: history ?? this.history,
      sortByScore: sortByScore ?? this.sortByScore,
      isLoading: isLoading ?? this.isLoading,
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
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MMSEHistoryNotifier(this._firestore, this._auth) : super(MMSEHistoryState());

  Future<void> loadHistory() async {
    final user = _auth.currentUser;
    if (user == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final snapshot =
          await _firestore
              .collection('mmse_tests')
              .doc(user.uid)
              .collection('tests')
              .orderBy('date', descending: true)
              .get();

      final history =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return MMSEHistoryEntry(
              score: data['score'],
              date: (data['date'] as Timestamp).toDate(),
              orientationTimeAnswers: List<String?>.from(
                data['orientationTimeAnswers'],
              ),
              orientationPlaceAnswers: List<String?>.from(
                data['orientationPlaceAnswers'],
              ),
              registrationScore: data['registrationScore'],
              finalScoreAnswer: data['finalScoreAnswer'],
              registrationRepetitions: data['registrationRepetitions'],
              attentionScore: data['attentionScore'],
              recallScore: data['recallScore'],
              bendaScore: data['bendaScore'],
              kataAnswer: data['kataAnswer'],
              instruksiScore: data['instruksiScore'],
              angkatTanganAnswer: data['angkatTanganAnswer'],
              tulisKalimatAnswer: data['tulisKalimatAnswer'],
              tiruGambarAnswer: data['tiruGambarAnswer'],
            );
          }).toList();

      state = state.copyWith(history: history, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addEntry(MMSEHistoryEntry entry) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final docRef =
          _firestore
              .collection('mmse_tests')
              .doc(user.uid)
              .collection('tests')
              .doc();

      await docRef.set({
        'score': entry.score,
        'date': Timestamp.fromDate(entry.date),
        'orientationTimeAnswers': entry.orientationTimeAnswers,
        'orientationPlaceAnswers': entry.orientationPlaceAnswers,
        'registrationScore': entry.registrationScore,
        'finalScoreAnswer' : entry.finalScoreAnswer,
        'registrationRepetitions': entry.registrationRepetitions,
        'attentionScore': entry.attentionScore,
        'recallScore': entry.recallScore,
        'bendaScore': entry.bendaScore,
        'kataAnswer': entry.kataAnswer,
        'instruksiScore': entry.instruksiScore,
        'angkatTanganAnswer': entry.angkatTanganAnswer,
        'tulisKalimatAnswer': entry.tulisKalimatAnswer,
        'tiruGambarAnswer': entry.tiruGambarAnswer,
      });

      final newHistory = [entry, ...state.history];
      state = state.copyWith(history: newHistory);
    } catch (e) {
      print('Error adding MMSE entry: $e');
    }
  }

  Future<void> deleteEntry(MMSEHistoryEntry entryToDelete) async {
    final user = _auth.currentUser;
    if (user == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final querySnapshot =
          await _firestore
              .collection('mmse_tests')
              .doc(user.uid)
              .collection('tests')
              .where('date', isEqualTo: Timestamp.fromDate(entryToDelete.date))
              .where('score', isEqualTo: entryToDelete.score)
              // Pertimbangkan menambahkan field lain yang lebih spesifik untuk MMSE jika diperlukan
              // .where('registrationScore', isEqualTo: entryToDelete.registrationScore)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        await _firestore
            .collection('mmse_tests')
            .doc(user.uid)
            .collection('tests')
            .doc(docId)
            .delete();

        final updatedHistory =
            state.history
                .where(
                  (entry) =>
                      !(entry.date == entryToDelete.date &&
                          entry.score == entryToDelete.score),
                ) // Sesuaikan kriteria pencocokan jika perlu
                .toList();
        state = state.copyWith(history: updatedHistory, isLoading: false);
      } else {
        final updatedHistory =
            state.history
                .where(
                  (entry) =>
                      !(entry.date == entryToDelete.date &&
                          entry.score == entryToDelete.score),
                )
                .toList();
        if (updatedHistory.length < state.history.length) {
          state = state.copyWith(history: updatedHistory, isLoading: false);
        } else {
          state = state.copyWith(isLoading: false);
        }
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void toggleSort() {
    state = state.copyWith(sortByScore: !state.sortByScore);
  }
}

final mmseHistoryProvider =
    StateNotifierProvider<MMSEHistoryNotifier, MMSEHistoryState>((ref) {
      final firestore = ref.watch(firestoreProvider);
      final auth = ref.watch(firebaseAuthProvider);
      return MMSEHistoryNotifier(firestore, auth);
    });