// user_profile_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
// Pastikan import path benar untuk auth_provider
import 'package:project/features/login/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Menggunakan alias fb_auth

// ... (Definisi class UserProfile Anda) ...
class UserProfile {
  final String? name;
  final String email;
  final String? phone;
  final DateTime? birthDate;
  final String? gender;
  final String? photoUrl;

  UserProfile({
    this.name,
    required this.email,
    this.phone,
    this.birthDate,
    this.gender,
    this.photoUrl,
  });

// copyWith method jika diperlukan
  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    DateTime? birthDate,
    String? gender,
    String? photoUrl,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}


class UserProfileNotifier extends StateNotifier<UserProfile?> {
  final FirebaseFirestore _firestore;
  final fb_auth.FirebaseAuth _auth; // Menggunakan alias fb_auth

  UserProfileNotifier(this._firestore, this._auth) : super(null) {
    // Anda masih bisa memanggilnya di konstruktor jika ingin data dimuat saat provider pertama kali dibuat
    loadProfile();
  }

  // Ubah menjadi publik atau buat wrapper publik
  Future<void> loadProfile() async { // Hapus garis bawah
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('user_profiles').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          state = UserProfile(
            name: data?['name'],
            email: data?['email'] ?? user.email!,
            phone: data?['phone'],
            birthDate: data?['birthDate'] != null ? (data!['birthDate'] as Timestamp).toDate() : null,
            gender: data?['gender'],
            photoUrl: data?['photoUrl'],
          );
        } else {
          // Jika profil tidak ada di Firestore, set state dengan email user
          // atau state null jika ingin ProfilePage menangani ini sebagai profil baru
          state = UserProfile(email: user.email!); // Atau state = null; tergantung logika Anda
        }
      } catch (e) {
        print("Error loading profile from UserProfileNotifier: $e");
        // Pertimbangkan untuk set state ke error atau UserProfile dasar jika gagal
        state = UserProfile(email: user.email!); // Atau state = null;
      }
    } else {
      state = null; // Tidak ada user yang login
    }
  }

  // ... (method updateProfile Anda) ...
  Future<void> updateProfile({
    required String email,
    String? name,
    String? phone,
    DateTime? birthDate,
    String? gender,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        Map<String, dynamic> profileData = {
          'email': email,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        // Tambahkan field hanya jika tidak null untuk menghindari penimpaan dengan null secara tidak sengaja
        // jika SetOptions(merge: true) digunakan dan field dikirim sebagai null.
        // Atau, jika Anda ingin secara eksplisit mengizinkan null, maka sertakan saja.
        if (name != null) profileData['name'] = name;
        if (phone != null) profileData['phone'] = phone;
        if (birthDate != null) profileData['birthDate'] = Timestamp.fromDate(birthDate);
        if (gender != null) profileData['gender'] = gender;

        // Penanganan photoUrl: jika null, kita ingin menghapusnya atau set ke null di DB
        if (photoUrl == null) {
          profileData['photoUrl'] = null; // Atau FieldValue.delete() jika ingin fieldnya hilang
        } else {
          profileData['photoUrl'] = photoUrl;
        }

        final docSnapshot = await _firestore.collection('user_profiles').doc(user.uid).get();
        if (!docSnapshot.exists) {
          profileData['createdAt'] = FieldValue.serverTimestamp();
        }

        await _firestore.collection('user_profiles').doc(user.uid).set(
              profileData,
              SetOptions(merge: true), // Pastikan merge true
            );

        // Update state lokal setelah berhasil.
        // Ambil state saat ini untuk mempertahankan field yang tidak diubah.
        final currentState = state;
        state = UserProfile(
          name: name ?? currentState?.name,
          email: email, // email biasanya tidak berubah dari auth, tapi disertakan untuk kelengkapan
          phone: phone ?? currentState?.phone,
          birthDate: birthDate ?? currentState?.birthDate,
          gender: gender ?? currentState?.gender,
          photoUrl: photoUrl, // Ini akan jadi null jika photoUrl yang dikirim null
        );

        if (name != null && user.displayName != name) {
          await user.updateDisplayName(name);
        }
      } catch (e) {
        print("Error updating profile in UserProfileNotifier: $e");
        rethrow; // Lemparkan kembali error agar bisa ditangani di UI jika perlu
      }
    }
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  // Pastikan provider ini di-watch dengan benar
  final auth = ref.watch(firebaseAuthProvider); // Menggunakan alias fb_auth jika didefinisikan di auth_provider
  final firestore = ref.watch(firestoreProvider);
  return UserProfileNotifier(firestore, auth);
});