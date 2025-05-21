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
      print('Error loading MMSE history: $e');
      state = state.copyWith(isLoading: false);
      // Handle error appropriately
    }
  }

  Future<void> addEntry(MMSEHistoryEntry entry) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Create a new document with auto-generated ID
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

      // Update local state
      final newHistory = [...state.history, entry];
      state = state.copyWith(history: newHistory);
    } catch (e) {
      print('Error adding MMSE entry: $e');
      // Handle error appropriately
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
