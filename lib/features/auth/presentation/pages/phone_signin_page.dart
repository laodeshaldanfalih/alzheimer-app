import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/core/providers/shared_providers.dart';
import 'package:project/core/widgets/main_layout.dart';
import 'package:project/features/auth/providers/auth_provider.dart'
    as app_auth_provider;
// import 'package:project/features/login/auth_provider.dart';

class PhoneSignInPage extends ConsumerStatefulWidget {
  const PhoneSignInPage({super.key});

  @override
  ConsumerState<PhoneSignInPage> createState() => _PhoneSignInPageState();
}

class _PhoneSignInPageState extends ConsumerState<PhoneSignInPage> {
  final _phoneNumberController = TextEditingController();
  final _smsCodeController = TextEditingController();
  String _verificationId = '';
  bool _codeSent = false;
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  void _verifyPhoneNumber() async {
    ref.read(isLoadingProvider.notifier).state = true;
    final authNotifier = ref.read(
      app_auth_provider.authProvider.notifier,
    ); // Gunakan alias
    final fAuth = ref.read(
      app_auth_provider.firebaseAuthProvider,
    ); // Gunakan alias

    await fAuth.verifyPhoneNumber(
      // Panggil langsung instance FirebaseAuth
      phoneNumber: _phoneNumberController.text.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieve code on Android
        await authNotifier.signInWithPhoneNumber(
          credential.verificationId!,
          credential.smsCode!,
        ); // Panggil Notifier
        if (mounted) ref.read(isLoadingProvider.notifier).state = false;
      },
      verificationFailed: (FirebaseAuthException e) {
        // ... (error handling)
        if (mounted) ref.read(isLoadingProvider.notifier).state = false;
      },
      codeSent: (String verificationId, int? resendToken) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
          });
          ref.read(isLoadingProvider.notifier).state = false;
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
          });
        }
      },
      timeout: const Duration(seconds: 60),
    );
  }

  void _signInWithPhoneNumber() async {
    //
    if (_verificationId.isEmpty || _smsCodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification ID atau kode SMS tidak valid.")),
      );
      return;
    }
    ref.read(isLoadingProvider.notifier).state = true;
    try {
      // Panggil AuthNotifier untuk proses sign-in
      await ref
          .read(app_auth_provider.authProvider.notifier)
          .signInWithPhoneNumber(
            // Gunakan alias
            _verificationId,
            _smsCodeController.text.trim(),
          );
      // Navigasi sudah dihandle oleh listener di SignInPage atau AuthWrapper
    } catch (e) {
      print("Sign In with Phone Failed from UI: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal melakukan sign in: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);

    // Listen to auth state changes untuk navigasi
    ref.listen<User?>(app_auth_provider.authProvider, (previous, next) {
      // Gunakan alias
      if (next != null && mounted) {
        // Jika login berhasil
        // Cek apakah ada halaman sebelumnya di stack selain halaman sign-in/sign-up
        // Jika ya, kembali. Jika tidak (misalnya dari splash/authwrapper), pergi ke MainLayout.
        if (Navigator.of(context).canPop()) {
          // Jika kita datang dari SignInPage, kita ingin mengganti SignInPage dengan MainLayout
          bool isComingFromAuthFlow =
              ModalRoute.of(context)?.settings.name == '/signin' ||
              ModalRoute.of(context)?.settings.name == '/signup';
          if (isComingFromAuthFlow) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainLayout()),
              (Route<dynamic> route) => false,
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainLayout()),
            );
          }
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainLayout()),
          );
        }
      }
    });

    //  @override
    // void dispose() {
    //   _phoneNumberController.dispose();
    //   _smsCodeController.dispose();
    //   super.dispose();
    // }

    // @override
    // Widget build(BuildContext context) {
    //    final isLoading = ref.watch(isLoadingProvider);

    //    // Listen to auth state changes
    //   ref.listen(authProvider, (previous, next) {
    //     if (next != null) {
    //       Navigator.of(
    //         context,
    //       ).pushReplacement(MaterialPageRoute(builder: (_) => MainLayout()));
    //     }
    //   });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading:
            isLoading
                ? null
                : IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    "Login with Phone Number",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomor Telepon',
                      hintText: 'Masukkan nomor telepon Anda (cth: +62812...)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Color(0xffF2F3F7),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!_codeSent)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, double.minPositive),
                        backgroundColor: Color(0xffD9D9D9),
                      ),
                      onPressed: isLoading ? null : _verifyPhoneNumber,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'SEND VERIFICATION CODE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (_codeSent) ...[
                    TextFormField(
                      controller: _smsCodeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Verification Code',
                        hintText: 'Masukkan kode SMS',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color(0xffF2F3F7),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, double.minPositive),
                        backgroundColor: Color(0xffD9D9D9),
                      ),
                      onPressed: isLoading ? null : _signInWithPhoneNumber,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'VERIFY AND LOGIN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed:
                          isLoading
                              ? null
                              : () {
                                setState(() {
                                  _codeSent = false; // Allow resending code
                                  _phoneNumberController.clear();
                                  _smsCodeController.clear();
                                });
                              },
                      child: Text('Resend Code'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
