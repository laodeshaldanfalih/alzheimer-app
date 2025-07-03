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

      final newHistory = [entry, ...state.history]; // Tambahkan ke depan agar urutan default (tanggal terbaru) terjaga jika tidak ada sort khusus
      state = state.copyWith(history: newHistory);
    } catch (e) {
      print('Error adding GDS entry: $e');
    }
  }

  Future<void> deleteEntry(GDSHistoryEntry entryToDelete) async {
    final user = _auth.currentUser;
    if (user == null) return;

    state = state.copyWith(isLoading: true); // Opsional: tandai loading selama proses hapus

    try {
      // Cari dokumen di Firestore berdasarkan tanggal dan skor
      // Ini berasumsi kombinasi tanggal & skor cukup unik.
      // Untuk keandalan lebih, simpan dan gunakan ID dokumen Firestore.
      final querySnapshot = await _firestore
          .collection('gds_tests')
          .doc(user.uid)
          .collection('tests')
          .where('date', isEqualTo: Timestamp.fromDate(entryToDelete.date))
          .where('score', isEqualTo: entryToDelete.score)
          // Tambahkan field lain jika perlu untuk meningkatkan keunikan query
          // .where('isDepressed', isEqualTo: entryToDelete.isDepressed) 
          .limit(1) // Harapannya hanya 1 dokumen yang cocok
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        await _firestore
            .collection('gds_tests')
            .doc(user.uid)
            .collection('tests')
            .doc(docId)
            .delete();

        // Hapus dari state lokal
        final updatedHistory = state.history
            .where((entry) =>
                !(entry.date == entryToDelete.date &&
                    entry.score == entryToDelete.score &&
                    entry.isDepressed == entryToDelete.isDepressed)) // Cocokkan lebih banyak field
            .toList();
        state = state.copyWith(history: updatedHistory, isLoading: false);
      } else {
        print('GDS entry to delete not found in Firestore.');
        // Jika tidak ditemukan di Firestore, mungkin hanya perlu update state lokal jika entri ada di sana karena suatu alasan
        final updatedHistory = state.history
            .where((entry) =>
                !(entry.date == entryToDelete.date &&
                    entry.score == entryToDelete.score &&
                    entry.isDepressed == entryToDelete.isDepressed))
            .toList();
        if (updatedHistory.length < state.history.length) {
           state = state.copyWith(history: updatedHistory, isLoading: false);
        } else {
           state = state.copyWith(isLoading: false);
        }
      }
    } catch (e) {
      print('Error deleting GDS entry: $e');
      state = state.copyWith(isLoading: false);
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