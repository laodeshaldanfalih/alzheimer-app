import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart'; // Tidak terpakai di sini, bisa dihapus
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Jika Google Sign-In masih dipakai
import 'package:project/features/home/presentation/pages/home_page.dart'; // Path mungkin perlu disesuaikan

// FirebaseAuth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Firestore instance provider (INI YANG PERLU DIUBAH)
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance; // Ini menunjuk ke database (default)
});

// StateNotifier for authentication
class AuthNotifier extends StateNotifier<User?> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthNotifier(this._auth, this._firestore) : super(_auth.currentUser) {
    _auth.authStateChanges().listen((user) {
      state = user;
    });
  }

  // Google Sign-In (Jika masih digunakan)
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      state = userCredential.user;

      // Saat Google Sign-In, Firebase Auth biasanya sudah mengisi displayName.
      // Kita akan membuat dokumen profil dasar di Firestore.
      // Nama akan diisi/diupdate nanti melalui halaman profil.
      if (userCredential.user != null) {
        await _firestore
            .collection('user_profiles')
            .doc(userCredential.user!.uid)
            .set({
              'email': userCredential.user!.email,
              // 'name': userCredential.user!.displayName, // Bisa diisi dari Google, atau biarkan kosong untuk diisi di profil
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true)); // Merge true penting jika dokumen sudah ada
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
      rethrow;
    }
  }

  // Email/Password Sign-Up
  Future<void> signUpWithEmail(
    String email,
    String password,
    // HAPUS: String username,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = userCredential.user;

      // HAPUS: Tidak ada update displayName dengan username di sini.
      // await userCredential.user!.updateDisplayName(username);

      // Buat dokumen profil dasar di Firestore.
      // Nama akan diisi/diupdate nanti melalui halaman profil.
      if (userCredential.user != null) {
        await _firestore
            .collection('user_profiles')
            .doc(userCredential.user!.uid)
            .set({
              'email': email,
              // 'name': username, // HAPUS field username dari sini
              'createdAt': FieldValue.serverTimestamp(),
            }); // Tidak perlu merge true karena ini pembuatan user baru, dokumen belum ada.
      }
    } catch (e) {
      print("Sign-Up Error: $e");
      rethrow;
    }
  }

  // Email/Password Sign-In
  Future<void> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = userCredential.user;
    } catch (e) {
      print("Sign-In Error: $e");
      rethrow;
    }
  }

  // Phone Number Sign-In
  Future<void> signInWithPhoneNumber(
    String verificationId,
    String smsCode,
  ) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      state = userCredential.user;

      if (userCredential.user != null) {
        // Cek apakah profil sudah ada di Firestore
        final profileDoc = await _firestore.collection('user_profiles').doc(userCredential.user!.uid).get();
        if (!profileDoc.exists) {
          // Jika profil belum ada (misalnya, pengguna pertama kali sign-up via phone),
          // buat entri dasar. Nomor telepon dari Firebase Auth bisa disimpan jika tersedia dan diinginkan.
          await _firestore
              .collection('user_profiles')
              .doc(userCredential.user!.uid)
              .set({
                'phone': userCredential.user!.phoneNumber, // Simpan nomor telepon dari kredensial Firebase Auth jika ada
                'email': userCredential.user!.email, // Mungkin null jika login via phone
                'createdAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
        }
      }
    } catch (e) {
      print("Phone Sign-In Error: $e");
      rethrow;
    }
  }

  // Send password reset email
  Future<void> resetPasswordByEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Password Reset Error (Email): $e");
      rethrow;
    }
  }

  Future<void> resetPasswordByPhoneNumber(String phoneNumber) async {
    try {
      // Find the user's email based on phone number in Firestore
      // Catatan: 'phoneNumber' di Firestore harusnya 'phone' sesuai struktur yang Anda inginkan
      final querySnapshot = await _firestore
          .collection('user_profiles')
          .where('phone', isEqualTo: phoneNumber) // Ubah ke 'phone'
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userProfileData = querySnapshot.docs.first.data();
        final email = userProfileData['email'];
        if (email != null && (email as String).isNotEmpty) { // Pastikan email tidak null dan tidak kosong
          await _auth.sendPasswordResetEmail(email: email);
        } else {
          throw Exception("Email not found or empty for this phone number.");
        }
      } else {
        throw Exception("No user found with this phone number.");
      }
    } catch (e) {
      print("Password Reset Error (Phone): $e");
      rethrow;
    }
  }

  // Sign-Out
  Future<void> signOut() async {
    // Jika menggunakan Google Sign-In, logout juga dari Google
    // final googleSignIn = GoogleSignIn();
    // if (await googleSignIn.isSignedIn()) {
    //   await googleSignIn.signOut();
    // }
    await _auth.signOut();
    state = null;
  }
}

// AuthNotifier provider
final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});

// Ini sepertinya tidak relevan dengan auth_provider, mungkin sisa dari file lain.
// final List<Widget> pages = [HomePage()];