import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      return; // Pengguna membatalkan login
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    state = userCredential.user;

    if (userCredential.user != null) {
      final user = userCredential.user!;
      final docRef = _firestore.collection('user_profiles').doc(user.uid);
      final docSnap = await docRef.get();

      // HANYA buat dokumen profil jika belum ada
      if (!docSnap.exists) {
        await docRef.set({
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'user', // Role default untuk pengguna baru
        });
        print('Profil baru dibuat untuk pengguna Google.');
      } else {
        print('Pengguna Google sudah ada, tidak ada perubahan role.');
        // Jika dokumen sudah ada, kita tidak melakukan apa-apa.
        // Ini akan mempertahankan peran 'admin' atau data lain yang sudah diubah manual.
      }
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
            .set(
              {
                'email': email,
                // 'name': username, // HAPUS field username dari sini
                'createdAt': FieldValue.serverTimestamp(),
                'role': 'user',
              },
            ); // Tidak perlu merge true karena ini pembuatan user baru, dokumen belum ada.
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
        final user = userCredential.user!;
        final profileDocRef = _firestore
            .collection('user_profiles')
            .doc(user.uid);
        final profileDoc = await profileDocRef.get();

        final Map<String, dynamic> profileData = {
          // user.phoneNumber bisa null jika tidak diekspos oleh provider
          // Lebih baik ambil dari credential jika memungkinkan, atau biarkan kosong untuk diisi manual jika perlu
          'phone':
              user.phoneNumber ??
              '', // Pastikan ini terisi dari auth jika memungkinkan
          'updatedAt': FieldValue.serverTimestamp(),
          
        };

        if (!profileDoc.exists) {
          profileData['email'] =
              user.email; // Akan null untuk pengguna baru via telepon
          profileData['createdAt'] = FieldValue.serverTimestamp();
          profileData['role'] = 'user';
          await profileDocRef.set(profileData);
        } else {
          // Jika sudah ada, hanya update phone jika belum ada atau berbeda
          // dan pastikan tidak menimpa email yang mungkin sudah ada dari metode login lain
          Map<String, dynamic> existingData =
              profileDoc.data() as Map<String, dynamic>;
          if (existingData['phone'] == null || existingData['phone'] == '') {
            await profileDocRef.update({'phone': user.phoneNumber ?? ''});
          }
          // Jangan set email di sini jika dokumen sudah ada, karena bisa menimpa email dari Google Sign In
        }
      }
    } catch (e) {
      print("Phone Sign-In Error: $e");
      rethrow;
    }
  }

  // BARU: Untuk menautkan Nomor Telepon ke akun yang sudah ada
  Future<void> linkPhoneNumberToCurrentUser(
    PhoneAuthCredential credential,
  ) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("User not logged in. Cannot link phone number.");
    }
    try {
      await currentUser.linkWithCredential(credential);
      // Update Firestore profile dengan nomor telepon jika belum ada
      await _firestore.collection('user_profiles').doc(currentUser.uid).set({
        'phone':
            currentUser
                .phoneNumber, // Setelah link, currentUser.phoneNumber mungkin terupdate
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      state =
          _auth.currentUser; // Refresh state untuk memuat ulang providerData
      print("Phone number successfully linked.");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
        print("This account is already linked with this phone provider.");
        // Opsional: tetap update nomor telepon di Firestore jika berbeda
        await _firestore.collection('user_profiles').doc(currentUser.uid).set({
          'phone':
              currentUser.phoneNumber ??
              credential.smsCode, // coba dapatkan nomor dari suatu tempat
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else if (e.code == 'credential-already-in-use') {
        throw Exception("Nomor ini sudah terhubung dengan akun lain.");
      } else {
        print("Error linking phone number: ${e.message}");
        rethrow;
      }
    }
  }

  // BARU: Untuk mengupdate email di Firebase Auth (setelah sign up via telepon)
  Future<void> updateAuthUserEmail(String newEmail) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("User not logged in. Cannot update email.");
    }
    if (currentUser.email == newEmail) {
      print("Email di Firebase Auth sudah sama, tidak perlu update.");
      // Anda mungkin ingin tetap mengirim verifikasi jika belum terverifikasi
      if (!currentUser.emailVerified) {
        await currentUser.sendEmailVerification();
        print("Email belum terverifikasi, email verifikasi ulang dikirim.");
      }
      return;
    }
    try {
      await currentUser.updateEmail(newEmail);
      await currentUser.sendEmailVerification(); // Kirim email verifikasi

      // Update juga di Firestore (meskipun UserProfileNotifier juga bisa melakukan ini)
      await _firestore.collection('user_profiles').doc(currentUser.uid).set({
        'email': newEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      state = _auth.currentUser; // Refresh state
      print("Auth user email updated and verification sent.");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception(
          "Email ini sudah terhubung dengan akun lain. Mohon gunakan email yang lain.",
        );
      } else if (e.code == 'requires-recent-login') {
        throw Exception(
          "This sensitive operation requires recent authentication. Please log out and log back in to update your email.",
        );
      } else {
        print("Error updating auth user email: ${e.message}");
        rethrow;
      }
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
      final querySnapshot =
          await _firestore
              .collection('user_profiles')
              .where('phone', isEqualTo: phoneNumber) // Ubah ke 'phone'
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userProfileData = querySnapshot.docs.first.data();
        final email = userProfileData['email'];
        if (email != null && (email as String).isNotEmpty) {
          // Pastikan email tidak null dan tidak kosong
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
