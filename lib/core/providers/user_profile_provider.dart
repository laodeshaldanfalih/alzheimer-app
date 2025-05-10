import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfile {
  final String? name;
  final String email;
  final int? age;
  final String? gender;
  final DateTime? birthdate;

  UserProfile({
    this.name,
    required this.email,
    this.age,
    this.gender,
    this.birthdate,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    int? age,
    String? gender,
    DateTime? birthdate,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      birthdate: birthdate ?? this.birthdate,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  UserProfileNotifier() : super(null);

  void updateProfile(
    String email, {
    String? name,
    int? age,
    String? gender,
    DateTime? birthdate,
  }) {
    state = UserProfile(
      name: name,
      email: email,
      age: age,
      gender: gender,
      birthdate: birthdate,
    );
  }

  void updateName(String name) {
    if (state != null) {
      state = state!.copyWith(name: name);
    }
  }

  void updateAge(int age) {
    if (state != null) {
      state = state!.copyWith(age: age);
    }
  }

  void updateGender(String gender) {
    if (state != null) {
      state = state!.copyWith(gender: gender);
    }
  }

  void updateBirthdate(DateTime birthdate) {
    if (state != null) {
      state = state!.copyWith(birthdate: birthdate);
    }
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
      return UserProfileNotifier();
    });
