// user_profile_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/auth/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class UserProfile {
  final String? name;
  final String email;
  final String? phone;
  final String? patientPhone;
  final DateTime? birthDate;
  final String? gender;
  final String? photoUrl;

  UserProfile({
    this.name,
    required this.email,
    this.phone,
    this.patientPhone,
    this.birthDate,
    this.gender,
    this.photoUrl,
  });

  bool get isProfileComplete {
    return name != null &&
        name!.isNotEmpty &&
        photoUrl != null &&
        photoUrl!.isNotEmpty &&
        birthDate != null &&
        gender != null &&
        gender!.isNotEmpty;
  }

  String? get missingProfileFields {
    final List<String> missing = [];
    if (name == null || name!.isEmpty) missing.add('Nama');
    if (photoUrl == null || photoUrl!.isEmpty) missing.add('Foto Profil');
    if (birthDate == null) missing.add('Tanggal Lahir');
    if (gender == null || gender!.isEmpty) missing.add('Gender');

    return missing.isEmpty ? null : missing.join(', ');
  }

  // copyWith method jika diperlukan
  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? patientPhone,
    DateTime? birthDate,
    String? gender,
    String? photoUrl,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      patientPhone: patientPhone ?? this.patientPhone,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  final AuthNotifier _authNotifier;
  final FirebaseFirestore _firestore;
  final fb_auth.FirebaseAuth _auth; // Menggunakan alias fb_auth

  UserProfileNotifier(this._firestore, this._auth, this._authNotifier)
    : super(null) {
    // Anda masih bisa memanggilnya di konstruktor jika ingin data dimuat saat provider pertama kali dibuat
    loadProfile();
  }

  // Ubah menjadi publik atau buat wrapper publik
  Future<void> loadProfile() async {
    // Hapus garis bawah
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc =
            await _firestore.collection('user_profiles').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          state = UserProfile(
            name: data?['name'],
            email: data?['email'] ?? user.email!,
            phone: data?['phone'],
            patientPhone: data?['patientPhone'],
            birthDate:
                data?['birthDate'] != null
                    ? (data!['birthDate'] as Timestamp).toDate()
                    : null,
            gender: data?['gender'],
            photoUrl: data?['photoUrl'],
          );
        } else {
          // Jika profil tidak ada di Firestore, set state dengan email user
          // atau state null jika ingin ProfilePage menangani ini sebagai profil baru
          state = UserProfile(
            email: user.email!,
          ); // Atau state = null; tergantung logika Anda
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
    String? patientPhone,
    DateTime? birthDate,
    String? gender,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        Map<String, dynamic> profileData = {
          'email': email.isNotEmpty ? email : null,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (name != null) profileData['name'] = name;
        if (patientPhone != null) profileData['patientPhone'] = patientPhone;

        if (phone != null) profileData['phone'] = phone;
        if (birthDate != null)
          profileData['birthDate'] = Timestamp.fromDate(birthDate);
        if (gender != null) profileData['gender'] = gender;

        if (photoUrl == null) {
          profileData['photoUrl'] = null;
        } else {
          profileData['photoUrl'] = photoUrl;
        }

        // bool isEmailProviderLinked = user.providerData.any(
        //   (p) => p.providerId == fb_auth.EmailAuthProvider.PROVIDER_ID,
        // );

        // if (email.isNotEmpty && user.email != email) {
        //   // Jika user tidak punya email di Auth (login via phone) ATAU
        //   // jika user punya email provider dan email di form beda
        //   if (user.email == null ||
        //       (user.email != null && isEmailProviderLinked)) {
        //     try {
        //       await _authNotifier.updateAuthUserEmail(
        //         email,
        //       ); // Panggil method AuthNotifier
        //     } catch (e) {
        //       // Tangani error spesifik dari updateAuthUserEmail (misal email-already-in-use)
        //       // dan lempar ulang agar bisa ditangkap di UI
        //       print(
        //         "Error during updateAuthUserEmail from UserProfileNotifier: $e",
        //       );
        //       rethrow;
        //     }
        //   } else if (user.email != null &&
        //       !isEmailProviderLinked &&
        //       user.providerData.any(
        //         (p) => p.providerId == fb_auth.GoogleAuthProvider.PROVIDER_ID,
        //       )) {
        //     // User login dengan Google, dan mencoba mengubah email di form.
        //     // Ini seharusnya tidak diizinkan atau memerlukan perlakuan khusus karena email Google adalah identifier utama.
        //     // Untuk saat ini, kita tidak akan mencoba mengubah email Auth jika itu dari Google.
        //     // Email di Firestore akan tetap diupdate sesuai input form.
        //     print(
        //       "User logged in with Google. Firebase Auth email will not be changed via this form.",
        //     );
        //     // Anda mungkin ingin menampilkan pesan ke pengguna di sini.
        //   }
        // }

        final docSnapshot =
            await _firestore.collection('user_profiles').doc(user.uid).get();
        if (!docSnapshot.exists) {
          profileData['createdAt'] = FieldValue.serverTimestamp();
        }
        await _firestore
            .collection('user_profiles')
            .doc(user.uid)
            .set(profileData, SetOptions(merge: true));

        await _firestore
            .collection('user_profiles')
            .doc(user.uid)
            .set(profileData, SetOptions(merge: true));

        final currentState = state;
        state = UserProfile(
          name: name ?? currentState?.name,
          email: email.isNotEmpty ? email : (state?.email ?? ''),
          phone: phone ?? currentState?.phone,
          patientPhone: patientPhone ?? currentState?.patientPhone,
          birthDate: birthDate ?? currentState?.birthDate,
          gender: gender ?? currentState?.gender,
          photoUrl: photoUrl,
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
      final auth = ref.watch(firebaseAuthProvider);
      final firestore = ref.watch(firestoreProvider);
      final authNotifier = ref.read(authProvider.notifier); // Baca AuthNotifier
      return UserProfileNotifier(
        firestore,
        auth,
        authNotifier,
      ); // Berikan ke konstruktor
    });
