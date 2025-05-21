// user_profile_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:project/features/auth/providers/auth_provider.dart'; // Menggunakan alias fb_auth

// ... (Definisi class UserProfile Anda) ...
class UserProfile {
  final String? name;
  final String email;
  final String? phone;
  final String? patientPhone; // Optional field
  final DateTime? birthDate;
  final String? gender;
  final String? photoUrl;

  UserProfile({
    this.name,
    required this.email,
    this.phone,
    this.patientPhone, // Optional parameter
    this.birthDate,
    this.gender,
    this.photoUrl,
  });

  // copyWith method jika diperlukan
  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? patientPhone, // Optional parameter
    DateTime? birthDate,
    String? gender,
    String? photoUrl,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      patientPhone: patientPhone ?? this.patientPhone, // Optional field
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
    : super(null);

  Future<void> loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      state = null;
      return;
    }

    try {
      // First, create a basic profile from Firebase Auth data
      UserProfile initialProfile = UserProfile(
        email: user.email ?? '',
        name: user.displayName,
        phone: user.phoneNumber,
        photoUrl: user.photoURL,
      );

      // Set initial state with auth data
      state = initialProfile;

      // Then try to load additional data from Firestore
      final doc =
          await _firestore.collection('user_profiles').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          state = UserProfile(
            name: data['name'] ?? user.displayName,
            email: data['email'] ?? user.email ?? '',
            phone: data['phone'] ?? user.phoneNumber,
            patientPhone: data['patientPhone'], // Optional field
            birthDate:
                data['birthDate'] != null
                    ? (data['birthDate'] as Timestamp).toDate()
                    : null,
            gender: data['gender'],
            photoUrl: data['photoUrl'] ?? user.photoURL,
          );
        }
      } else {
        // If no Firestore document exists, create one with the auth data
        await _firestore.collection('user_profiles').doc(user.uid).set({
          'email': user.email,
          'name': user.displayName,
          'phone': user.phoneNumber,
          'photoUrl': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print("Error loading profile: $e");
      // Keep the initial auth-based profile if Firestore fails
      if (state == null) {
        state = UserProfile(
          email: user.email ?? '',
          name: user.displayName,
          phone: user.phoneNumber,
          photoUrl: user.photoURL,
        );
      }
    }
  }

  // ... (method updateProfile Anda) ...
  Future<void> updateProfile({
    required String email,
    String? name,
    String? phone,
    String? patientPhone, // Optional parameter
    DateTime? birthDate,
    String? gender,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    try {
      Map<String, dynamic> profileData = {
        'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) profileData['name'] = name;
      if (phone != null) profileData['phone'] = phone;
      if (patientPhone != null)
        profileData['patientPhone'] = patientPhone; // Only update if provided
      if (birthDate != null)
        profileData['birthDate'] = Timestamp.fromDate(birthDate);
      if (gender != null) profileData['gender'] = gender;
      if (photoUrl != null) profileData['photoUrl'] = photoUrl;

      // Update Firestore
      await _firestore
          .collection('user_profiles')
          .doc(user.uid)
          .set(profileData, SetOptions(merge: true));

      // Update local state
      state = UserProfile(
        name: name ?? state?.name,
        email: email,
        phone: phone ?? state?.phone,
        patientPhone:
            patientPhone ??
            state?.patientPhone, // Keep existing value if not provided
        birthDate: birthDate ?? state?.birthDate,
        gender: gender ?? state?.gender,
        photoUrl: photoUrl ?? state?.photoUrl,
      );

      // Update Firebase Auth display name if changed
      if (name != null && user.displayName != name) {
        await user.updateDisplayName(name);
      }
    } catch (e) {
      print("Error updating profile: $e");
      rethrow;
    }
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
      final auth = ref.watch(firebaseAuthProvider);
      final firestore = ref.watch(firestoreProvider);
      final authNotifier = ref.read(authProvider.notifier); // Baca AuthNotifier
      return UserProfileNotifier(firestore, auth, authNotifier);
    });
