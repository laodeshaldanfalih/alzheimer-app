import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/core/providers/auth_provider.dart';
import 'package:project/core/providers/shared_providers.dart';
import 'package:project/core/widgets/main_layout.dart';
import 'package:project/features/login/auth_provider.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _verifyPhoneNumber() async {
    ref.read(isLoadingProvider.notifier).state = true;
    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneNumberController.text.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieve code on Android
        await _auth.signInWithCredential(credential);
        ref.read(isLoadingProvider.notifier).state = false;
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Verification Failed: ${e.message}");
        ref.read(isLoadingProvider.notifier).state = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification failed: ${e.message}")),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _codeSent = true;
          ref.read(isLoadingProvider.notifier).state = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
      timeout: const Duration(seconds: 60),
    );
  }

  void _signInWithPhoneNumber() async {
     ref.read(isLoadingProvider.notifier).state = true;
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _smsCodeController.text.trim(),
      );
      await _auth.signInWithCredential(credential);
      ref.read(isLoadingProvider.notifier).state = false;
    } catch (e) {
      print("Sign In with Phone Failed: $e");
       ref.read(isLoadingProvider.notifier).state = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign in failed: ${e.toString()}")),
      );
    }
  }

   @override
  void dispose() {
    _phoneNumberController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
     final isLoading = ref.watch(isLoadingProvider);

     // Listen to auth state changes
    ref.listen(authProvider, (previous, next) {
      if (next != null) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => MainLayout()));
      }
    });

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
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
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
                         contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
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
                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
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
                       onPressed: isLoading ? null : (){
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