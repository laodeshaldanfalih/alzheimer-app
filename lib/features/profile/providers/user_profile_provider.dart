
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

  // copyWith method diperbarui untuk menyertakan role
  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? patientPhone,
    DateTime? birthDate,
    String? gender,
    String? photoUrl,
    String? role, // <-- DITAMBAHKAN
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
  final fb_auth.FirebaseAuth _auth;

  UserProfileNotifier(this._firestore, this._auth, this._authNotifier)
    : super(null) {
    loadProfile();
  }

  Future<void> loadProfile() async {
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
          // Jika profil tidak ada, buat state dasar dengan role 'user'
          state = UserProfile(
            email: user.email!,
          );
        }
      } catch (e) {
        print("Error loading profile from UserProfileNotifier: $e");
      }
    } else {
      state = null;
    }
  }

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
        // ... (logika profileData Anda tetap sama)
        if (name != null) profileData['name'] = name;
        if (patientPhone != null) profileData['patientPhone'] = patientPhone;
        if (phone != null) profileData['phone'] = phone;
        if (birthDate != null) profileData['birthDate'] = Timestamp.fromDate(birthDate);
        if (gender != null) profileData['gender'] = gender;
        if (photoUrl == null) {
          profileData['photoUrl'] = null;
        } else {
          profileData['photoUrl'] = photoUrl;
        }

        // Kita tidak mengizinkan role diubah dari sini, jadi tidak perlu ditambah ke profileData
        
        await _firestore
            .collection('user_profiles')
            .doc(user.uid)
            .set(profileData, SetOptions(merge: true));

        // Saat update state, pertahankan role yang ada
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
        rethrow;
      }
    }
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  final authNotifier = ref.read(authProvider.notifier);
  return UserProfileNotifier(
    firestore,
    auth,
    authNotifier,
  );
});