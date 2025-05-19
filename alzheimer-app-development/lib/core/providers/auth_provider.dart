// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:project/features/home/presentation/pages/home_page.dart';

// // FirebaseAuth instance provider
// final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
//   return FirebaseAuth.instance;
// });

// // StateNotifier for authentication
// class AuthNotifier extends StateNotifier<User?> {
//   final FirebaseAuth _auth;

//   AuthNotifier(this._auth) : super(_auth.currentUser) {
//     // Ensure state updates properly when auth state changes
//     _auth.authStateChanges().listen((user) {
//       state = user; // Update Riverpod state
//     });
//   }

//   // Google Sign-In (Using FirebaseAuth Directly)
//   Future<void> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//       if (googleUser == null) {
//         // User batal login
//         return;
//       }

//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final userCredential = await _auth.signInWithCredential(credential);
//       state = userCredential.user;
//     } catch (e) {
//       print("Google Sign-In Error: $e");
//       rethrow;
//     }
//   }

//   // Email/Password Sign-Up
//   Future<void> signUpWithEmail(String email, String password) async {
//     try {
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       state = userCredential.user; // Explicitly update state
//     } catch (e) {
//       print("Sign-Up Error: $e");
//       rethrow;
//     }
//   }

//   // Email/Password Sign-In
//   Future<void> signInWithEmail(String email, String password) async {
//     try {
//       final userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       state = userCredential.user; // Explicitly update state
//     } catch (e) {
//       print("Sign-In Error: $e");
//       rethrow;
//     }
//   }

//   Future<void> resetPassword(String email) async {
//     try {
//       await _auth.sendPasswordResetEmail(email: email);
//     } catch (e) {
//       print("Password Reset Error: $e");
//       rethrow;
//     }
//   }

//   // Sign-Out
//   Future<void> signOut() async {
//     await _auth.signOut();
//     state = null; // Ensure state is updated properly
//   }
// }

// // AuthNotifier provider
// final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
//   return AuthNotifier(ref.watch(firebaseAuthProvider));
// });

// final List<Widget> pages = [
//   HomePage(),
//   // YourFeatureMenuPage(), // Add your actual page
//   // YourBuletinPage(), // Add your actual page
//   // YourProfilePage(), // Add your actual page
// ];
