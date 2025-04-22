import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfile {
  final String? name;
  final String email;

  UserProfile({this.name, required this.email});

  UserProfile copyWith({String? name, String? email}) {
    return UserProfile(name: name ?? this.name, email: email ?? this.email);
  }
}

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  UserProfileNotifier() : super(null);

  void updateProfile(String email, {String? name}) {
    state = UserProfile(name: name, email: email);
  }

  void updateName(String name) {
    if (state != null) {
      state = state!.copyWith(name: name);
    }
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
      return UserProfileNotifier();
    });
