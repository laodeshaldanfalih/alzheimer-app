// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class UserProfile {
//   final String? name;
//   final String email;
//   final int? age;
//   final String? gender;
//   final DateTime? birthdate;

//   UserProfile({
//     this.name,
//     required this.email,
//     this.age,
//     this.gender,
//     this.birthdate,
//   });

//   UserProfile copyWith({
//     String? name,
//     String? email,
//     int? age,
//     String? gender,
//     DateTime? birthdate,
//   }) {
//     return UserProfile(
//       name: name ?? this.name,
//       email: email ?? this.email,
//       age: age ?? this.age,
//       gender: gender ?? this.gender,
//       birthdate: birthdate ?? this.birthdate,
//     );
//   }
// }

// class UserProfileNotifier extends StateNotifier<UserProfile?> {
//   UserProfileNotifier() : super(null) {
//     _loadProfileFromPrefs();
//   }

//   Future<void> _loadProfileFromPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     final hasProfile = prefs.getBool('has_profile') ?? false;

//     if (hasProfile) {
//       final name = prefs.getString('profile_name');
//       final ageStr = prefs.getString('profile_age');
//       final gender = prefs.getString('profile_gender');
//       final birthdateStr = prefs.getString('profile_birthdate');

//       // Get email from auth provider or use a default
//       final email =
//           'user@example.com'; // This should be replaced with actual email from auth provider

//       state = UserProfile(
//         name: name,
//         email: email,
//         age: ageStr != null ? int.tryParse(ageStr) : null,
//         gender: gender,
//         birthdate: birthdateStr != null ? DateTime.parse(birthdateStr) : null,
//       );
//     }
//   }

//   void updateProfile(
//     String email, {
//     String? name,
//     int? age,
//     String? gender,
//     DateTime? birthdate,
//   }) {
//     state = UserProfile(
//       name: name,
//       email: email,
//       age: age,
//       gender: gender,
//       birthdate: birthdate,
//     );
//   }

//   void updateName(String name) {
//     if (state != null) {
//       state = state!.copyWith(name: name);
//     }
//   }

//   void updateAge(int age) {
//     if (state != null) {
//       state = state!.copyWith(age: age);
//     }
//   }

//   void updateGender(String gender) {
//     if (state != null) {
//       state = state!.copyWith(gender: gender);
//     }
//   }

//   void updateBirthdate(DateTime birthdate) {
//     if (state != null) {
//       state = state!.copyWith(birthdate: birthdate);
//     }
//   }
// }

// final userProfileProvider =
//     StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
//       return UserProfileNotifier();
//     });
