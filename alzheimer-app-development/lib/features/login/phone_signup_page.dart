// File: phone_signup_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Pastikan path ini benar, gunakan alias jika ada konflik
import 'package:project/features/login/auth_provider.dart' as app_auth_provider;
import 'package:project/core/providers/shared_providers.dart';
import 'package:project/core/widgets/main_layout.dart';

class PhoneSignUpPage extends ConsumerStatefulWidget {
  // Diubah menjadi PhoneSignUpPage
  const PhoneSignUpPage({super.key});

  @override
  ConsumerState<PhoneSignUpPage> createState() => _PhoneSignUpPageState();
}

class _PhoneSignUpPageState extends ConsumerState<PhoneSignUpPage> {
  final _phoneNumberController = TextEditingController();
  final _smsCodeController = TextEditingController();
  String _verificationId = '';
  bool _codeSent = false;
  // final FirebaseAuth _auth = FirebaseAuth.instance; // Bisa dihapus

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  void _verifyPhoneNumber() async {
    if (!mounted) return;

    String phoneNumberInput = _phoneNumberController.text.trim();
    String formattedPhoneNumber = phoneNumberInput;

    if (formattedPhoneNumber.startsWith('0')) {
      formattedPhoneNumber = '+62${formattedPhoneNumber.substring(1)}';
    } else if (!formattedPhoneNumber.startsWith('+')) {
      // Logika serupa seperti di edit_profile_page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Format nomor telepon tidak valid. Harap gunakan format 08xx atau +628xx.",
          ),
        ),
      );
      return; // Hentikan proses jika format salah
    }
    //

    ref.read(isLoadingProvider.notifier).state = true;
    final fAuth = ref.read(app_auth_provider.firebaseAuthProvider);

    await fAuth.verifyPhoneNumber(
      // phoneNumber: _phoneNumberController.text.trim(),
      phoneNumber: formattedPhoneNumber, // GUNAKAN NOMOR YANG SUDAH DIFORMAT

      verificationCompleted: (PhoneAuthCredential credential) async {
        if (!mounted) return;
        // Auto-retrieve code on Android
        // Untuk sign-up, kita tetap sign-in, AuthNotifier akan handle pembuatan profil jika baru
        await ref
            .read(app_auth_provider.authProvider.notifier)
            .signInWithPhoneNumber(
              credential.verificationId!,
              credential.smsCode!,
            );
        if (mounted) ref.read(isLoadingProvider.notifier).state = false;
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!mounted) return;
        print("Verification Failed: ${e.message}");
        ref.read(isLoadingProvider.notifier).state = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verifikasi gagal: ${e.message}")),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!mounted) return;
        setState(() {
          _verificationId = verificationId;
          _codeSent = true;
        });
        ref.read(isLoadingProvider.notifier).state = false;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Kode OTP telah dikirim.")));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!mounted) {
          setState(() {
            _verificationId = verificationId;
          });
        }
      },
      timeout: const Duration(seconds: 60),
    );
  }

  void _signUpWithPhoneNumber() async {
    // Diubah nama metodenya untuk kejelasan
    if (_verificationId.isEmpty || _smsCodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ID Verifikasi atau kode OTP tidak valid.")),
      );
      return;
    }
    if (!mounted) return;
    ref.read(isLoadingProvider.notifier).state = true;
    try {
      await ref
          .read(app_auth_provider.authProvider.notifier)
          .signInWithPhoneNumber(
            _verificationId,
            _smsCodeController.text.trim(),
          );
      // Navigasi akan diurus oleh listener di AuthWrapper atau listener di halaman ini
    } catch (e) {
      if (!mounted) return;
      print("Sign Up with Phone Failed from UI: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal melakukan pendaftaran: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);

    // Listener untuk navigasi setelah login/signup berhasil
    ref.listen<User?>(app_auth_provider.authProvider, (previous, next) {
      if (next != null && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainLayout()),
          (Route<dynamic> route) => false,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar dengan Telepon', // Judul diubah
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        leading:
            isLoading
                ? null
                : IconButton(
                  icon: Icon(Icons.arrow_back),
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
                  const SizedBox(height: 20),
                  Text(
                    _codeSent
                        ? "Verifikasi Nomor Telepon Anda"
                        : "Masukkan Nomor Telepon Anda",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _codeSent
                        ? "Masukkan kode OTP 6 digit yang dikirimkan ke nomor ${_phoneNumberController.text}"
                        : "Kami akan mengirimkan kode verifikasi OTP ke nomor telepon Anda.",
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  if (!_codeSent)
                    TextFormField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Nomor Telepon',
                        hintText: 'Contoh: +628123456789',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor telepon tidak boleh kosong';
                        }
                        // Anda bisa menambahkan validasi format nomor telepon yang lebih ketat
                        return null;
                      },
                    ),
                  if (_codeSent) ...[
                    TextFormField(
                      controller: _smsCodeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: TextStyle(fontSize: 18, letterSpacing: 10),
                      decoration: InputDecoration(
                        labelText: 'Kode OTP',
                        hintText: 'XXXXXX',
                        counterText: "", // Menghilangkan counter default
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kode OTP tidak boleh kosong';
                        }
                        if (value.length < 6) {
                          return 'Kode OTP harus 6 digit';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor:
                          Theme.of(context).primaryColor, // Gunakan warna tema
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed:
                        isLoading
                            ? null
                            : (_codeSent
                                ? _signUpWithPhoneNumber
                                : _verifyPhoneNumber),
                    child: Text(
                      _codeSent ? 'VERIFIKASI & DAFTAR' : 'KIRIM KODE OTP',
                    ),
                  ),
                  if (_codeSent)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: TextButton(
                        onPressed:
                            isLoading
                                ? null
                                : () {
                                  setState(() {
                                    _codeSent = false;
                                    // _phoneNumberController.clear(); // Opsional, biarkan user edit
                                    _smsCodeController.clear();
                                    _verificationId = '';
                                  });
                                },
                        child: Text('Kirim Ulang Kode atau Ubah Nomor'),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.15),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
