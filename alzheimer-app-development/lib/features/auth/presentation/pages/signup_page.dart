// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:project/core/providers/auth_provider.dart';
// import 'package:project/core/providers/shared_providers.dart';
// import 'package:project/core/widgets/main_layout.dart';
// import 'package:project/features/auth/presentation/widgets/signup_form.dart';

// class SignUpPage extends ConsumerStatefulWidget {
//   const SignUpPage({super.key});

//   @override
//   ConsumerState<SignUpPage> createState() => _SignUpPageState();
// }

// class _SignUpPageState extends ConsumerState<SignUpPage> {
//   @override
//   void initState() {
//     super.initState();
//     // Check if user is already logged in
//     Future.delayed(Duration.zero, () {
//       final user = ref.read(authProvider);
//       if (user != null && mounted) {
//         Navigator.of(
//           context,
//         ).pushReplacement(MaterialPageRoute(builder: (_) => MainLayout()));
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isLoading = ref.watch(isLoadingProvider);

//     // Listen to auth state changes
//     ref.listen(authProvider, (previous, next) {
//       if (next != null && mounted) {
//         Navigator.of(
//           context,
//         ).pushReplacement(MaterialPageRoute(builder: (_) => MainLayout()));
//       }
//     });

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading:
//             isLoading
//                 ? null
//                 : IconButton(
//                   icon: Icon(Icons.arrow_back, color: Colors.black),
//                   onPressed: () => Navigator.of(context).pop(),
//                 ),
//       ),
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           SafeArea(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const SizedBox(height: 20),
//                     Text(
//                       "Buat Akun",
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 40),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         padding: EdgeInsets.symmetric(vertical: 20),
//                         backgroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(38),
//                           side: BorderSide(width: 1, color: Color(0xffEBEAEC)),
//                         ),
//                         elevation: 0,
//                       ),
//                       onPressed:
//                           isLoading
//                               ? null
//                               : () async {
//                                 try {
//                                   ref.read(isLoadingProvider.notifier).state =
//                                       true;
//                                   final authNotifier = ref.read(
//                                     authProvider.notifier,
//                                   );
//                                   await authNotifier.signInWithGoogle();
//                                 } catch (e) {
//                                   if (mounted) {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text('Login failed: $e'),
//                                       ),
//                                     );
//                                   }
//                                 } finally {
//                                   if (mounted) {
//                                     ref.read(isLoadingProvider.notifier).state =
//                                         false;
//                                   }
//                                 }
//                               },
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Image.asset(
//                             "assets/images/google_icons.png",
//                             width: 24,
//                           ),
//                           SizedBox(width: 10),
//                           Text(
//                             "CONTINUE WITH GOOGLE",
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     Text(
//                       "Atau daftar dengan email",
//                       style: TextStyle(color: Color(0XFFA1A4B2), fontSize: 12),
//                     ),
//                     const SizedBox(height: 30),
//                     SignUpForm(),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           if (isLoading)
//             Container(
//               color: Colors.black.withOpacity(0.5),
//               child: Center(child: CircularProgressIndicator()),
//             ),
//         ],
//       ),
//     );
//   }
// }
