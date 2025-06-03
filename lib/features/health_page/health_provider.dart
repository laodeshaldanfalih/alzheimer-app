
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/features/health_page/health_data_model.dart';

// --- Provider untuk Firebase (Tidak ada perubahan) ---
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// ======================================================================
// 1. KELAS STATE (STATE OBJECT) - Tidak ada perubahan
// ======================================================================
class HealthState {
  final List<HealthData> healthRecords;
  final bool isLoading;

  HealthState({
    this.healthRecords = const [],
    this.isLoading = false,
  });

  HealthState copyWith({
    List<HealthData>? healthRecords,
    bool? isLoading,
  }) {
    return HealthState(
      healthRecords: healthRecords ?? this.healthRecords,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ======================================================================
// 2. KELAS NOTIFIER (STATE LOGIC) - DITAMBAHKAN FUNGSI EDIT & DELETE
// ======================================================================
class HealthNotifier extends StateNotifier<HealthState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  HealthNotifier(this._firestore, this._auth) : super(HealthState());

  // --- Collection Reference ---
  CollectionReference<Map<String, dynamic>> _getHealthRecordsCollection() {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User tidak login.");
    return _firestore
        .collection('users_health_records')
        .doc(user.uid)
        .collection('health_records');
  }


  // --- METHODS ---

  /// Memuat semua riwayat data kesehatan dari Firestore. (Tidak ada perubahan)
  Future<void> loadHealthRecords() async {
    state = state.copyWith(isLoading: true);
    try {
      final snapshot = await _getHealthRecordsCollection()
          .orderBy('timestamp', descending: true)
          .get();
      final records = snapshot.docs.map((doc) => HealthData.fromMap(doc.id, doc.data())).toList();
      state = state.copyWith(healthRecords: records, isLoading: false);
    } catch (e) {
      print('Error loading health records: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Menambahkan satu entri data kesehatan baru. (Tidak ada perubahan)
  Future<void> addHealthRecord(HealthData entry) async {
    try {
      await _getHealthRecordsCollection().add(entry.toMap());
      // Muat ulang data untuk memastikan konsistensi
      await loadHealthRecords();
    } catch (e) {
      print('Error adding health record: $e');
      rethrow; // Lemparkan error agar bisa ditangani di UI
    }
  }

  /// [BARU] Memperbarui data kesehatan yang sudah ada di Firestore.
  Future<void> updateHealthRecord(HealthData updatedRecord) async {
    if (updatedRecord.id == null) return; // Butuh ID untuk update

    try {
      await _getHealthRecordsCollection()
        .doc(updatedRecord.id)
        .update(updatedRecord.toMap());

      // Update state secara lokal (Optimistic Update)
      final records = state.healthRecords;
      final index = records.indexWhere((r) => r.id == updatedRecord.id);
      if (index != -1) {
        records[index] = updatedRecord;
        state = state.copyWith(healthRecords: List.from(records));
      }
    } catch (e) {
      print('Error updating health record: $e');
      rethrow;
    }
  }

  /// [BARU] Menghapus data kesehatan dari Firestore.
  Future<void> deleteHealthRecord(String recordId) async {
    try {
      await _getHealthRecordsCollection().doc(recordId).delete();
      
      // Update state secara lokal (Optimistic Update)
      final updatedRecords = state.healthRecords.where((r) => r.id != recordId).toList();
      state = state.copyWith(healthRecords: updatedRecords);
    } catch (e) {
      print('Error deleting health record: $e');
      rethrow;
    }
  }
}


// ======================================================================
// 3. DEFINISI PROVIDER (RIVERPOD PROVIDER) - Tidak ada perubahan
// ======================================================================
final healthProvider = StateNotifierProvider<HealthNotifier, HealthState>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return HealthNotifier(firestore, auth);
});