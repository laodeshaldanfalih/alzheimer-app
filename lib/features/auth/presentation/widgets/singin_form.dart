import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/core/providers/shared_providers.dart';
import 'package:project/features/auth/presentation/pages/signup_page.dart';
import 'package:project/features/auth/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInForm extends ConsumerStatefulWidget {
  const SignInForm({super.key});

  @override
  ConsumerState<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String label, String hintText) {
    // Menggunakan Color(0xff7583CA) sebagai warna primer dari kode Anda
    const primaryColor = Color(0xff7583CA);
    const hintColor = Color(0xffA1A4B2);
    const fillColor = Color(0xffF2F3F7);

    return InputDecoration(
      labelStyle: const TextStyle(color: hintColor, fontSize: 12),
      hintStyle: const TextStyle(color: hintColor, fontSize: 12),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      filled: true,
      fillColor: fillColor,
      labelText: label,
      hintText:
          hintText, // Jika labelText ada, hintText mungkin tidak terlihat kecuali field kosong
      border: OutlineInputBorder(
        // Default, unfocused, no error
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(15),
      ),
      focusedBorder: OutlineInputBorder(
        // Focused, no error
        // Memberikan sedikit indikasi fokus dengan warna primer yang lebih transparan
        // atau Anda bisa menggunakan BorderSide.none jika tidak ingin ada border saat fokus & valid
        borderSide: BorderSide(color: primaryColor.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      errorBorder: OutlineInputBorder(
        // Unfocused, with error
        borderSide: const BorderSide(color: Colors.red, width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedErrorBorder: OutlineInputBorder(
        // Focused, with error
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
    );
  }

  void _showErrorDialog(
    BuildContext context,
    String errorCode,
    String fullErrorMessage,
  ) {
    final readableMessage = _getReadableErrorMessage(
      errorCode,
      fullErrorMessage,
    );
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Login Gagal'),
          content: Text(readableMessage),
          actions: [
            if (errorCode == 'user-not-found')
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Dismiss error dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                child: const Text(
                  'Daftar Sekarang',
                  style: TextStyle(color: Color(0xff7583CA)),
                ),
              ),
            if (errorCode == 'wrong-password' ||
                errorCode == 'INVALID_PASSWORD') // Firebase Auth v9+ vs older
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Dismiss error dialog
                  _showForgotPasswordDialog(context);
                },
                child: const Text(
                  'Lupa Password?',
                  style: TextStyle(color: Color(0xff7583CA)),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController inputController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xffFAF9F6),
          // backgroundColor: Colors.white,
          title: const Text('Reset Password'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          contentPadding: const EdgeInsets.all(20.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Masukkan email Anda untuk dikirimi tautan reset password.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: inputController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border:
                      OutlineInputBorder(), // Menggunakan border standar dari tema
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff7583CA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () async {
                // Menggunakan ref dari ConsumerState untuk mengakses provider
                final authNotifier = ref.read(authProvider.notifier);

                if (inputController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    // Menggunakan dialogContext agar snackbar muncul di atas dialog jika memungkinkan
                    const SnackBar(
                      content: Text('Email tidak boleh kosong.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                try {
                  await authNotifier.resetPasswordByEmail(
                    // Pastikan method ini ada di AuthNotifier Anda
                    inputController.text.trim(),
                  );
                  Navigator.pop(
                    dialogContext,
                  ); // Dismiss forgot password dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    // Menggunakan context utama untuk snackbar
                    const SnackBar(
                      content: Text(
                        'Email reset password telah dikirim. Silakan periksa kotak masuk Anda.',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  // Tetap tampilkan error di dalam dialog forgot password jika masih terbuka
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Gagal mengirim tautan reset: ${e.toString()}',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Kirim Tautan'),
            ),
          ],
        );
      },
    );
  }

  String _getReadableErrorMessage(
    String errorCode,
    String firebaseFullMessage,
  ) {
    // Firebase v9+ error codes (seringkali sama dengan yang lama tapi bisa berbeda)
    // seperti 'auth/user-not-found', 'auth/wrong-password', 'auth/invalid-email'

    // Menghilangkan prefix 'auth/' jika ada untuk konsistensi
    final cleanErrorCode =
        errorCode.startsWith('auth/') ? errorCode.substring(5) : errorCode;

    switch (cleanErrorCode) {
      case 'user-not-found':
      case 'INVALID_LOGIN_CREDENTIALS': // Ini kode baru Firebase untuk user-not-found ATAU wrong-password
        // Coba deteksi lebih lanjut dari pesan error firebase jika kodenya INVALID_LOGIN_CREDENTIALS
        if (firebaseFullMessage.toLowerCase().contains("user") ||
            firebaseFullMessage.toLowerCase().contains("email")) {
          return 'Tidak ada akun yang ditemukan dengan email ini. Apakah Anda ingin mendaftar?';
        }
        return 'Email atau password salah. Silakan coba lagi.'; // Pesan umum untuk INVALID_LOGIN_CREDENTIALS
      case 'wrong-password': // Kode lama, mungkin masih muncul dari beberapa SDK/kasus
        return 'Password salah. Silakan coba lagi.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan gagal. Silakan coba lagi nanti.';
      // Hapus error terkait telepon karena sudah tidak relevan
      // case 'email-not-found for this phone number.':
      //   return 'No email found linked to this phone number.';
      // case 'No user found with this phone number.':
      //   return 'No user found with this phone number.';
      default:
        return 'Terjadi kesalahan. Silakan coba lagi. ($cleanErrorCode)';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Untuk memantau state loading dari provider jika ada
    // final authState = ref.watch(authProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _buildInputDecoration(
              "Email",
              "Masukkan alamat email Anda",
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Email tidak boleh kosong";
              }
              // Regex sederhana untuk validasi email
              bool isValid = RegExp(
                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
              ).hasMatch(value);
              if (!isValid) {
                return "Masukkan format email yang valid";
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: _buildInputDecoration(
              "Password",
              "Masukkan password Anda",
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  size: 20,
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xffA1A4B2), // Warna netral untuk ikon
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Password tidak boleh kosong";
              }

              List<String> requirements = [];
              if (value.length < 6) {
                requirements.add("minimal 6 karakter");
              }
              if (!value.contains(RegExp(r'[0-9]'))) {
                requirements.add("satu angka");
              }
              // Tambahkan validasi lain jika perlu (misal: huruf besar, simbol)
              // if (!value.contains(RegExp(r'[A-Z]'))) {
              //   requirements.add("satu huruf besar");
              // }

              if (requirements.isNotEmpty) {
                return "Password harus memiliki ${requirements.join(", ")}";
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => _showForgotPasswordDialog(context),
              child: const Text(
                "Lupa Password?",
                style: TextStyle(
                  color: Color(0xff7583CA),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: const Color(0xff7583CA),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              disabledBackgroundColor: const Color(0xff7583CA).withOpacity(0.7),
            ),
            onPressed:
                isLoading
                    ? null
                    : () async {
                      // Tutup keyboard jika terbuka
                      FocusScope.of(context).unfocus();

                      if (_formKey.currentState!.validate()) {
                        ref.read(isLoadingProvider.notifier).state = true;

                        try {
                          final authNotifier = ref.read(authProvider.notifier);
                          await authNotifier.signInWithEmail(
                            _emailController.text.trim(),
                            _passwordController.text,
                          );
                          // Jika sukses, navigasi atau aksi lain akan ditangani oleh listener pada authState
                          // ref.read(authProvider.notifier).setLoading(false);
                        } on FirebaseAuthException catch (e) {
                          // Tangkap FirebaseAuthException secara spesifik
                          // ref.read(authProvider.notifier).setLoading(false);
                          _showErrorDialog(
                            context,
                            e.code,
                            e.message ?? e.toString(),
                          );
                        } catch (e) {
                          if (mounted) {
                            _showErrorDialog(
                              context,
                              'unknown-error',
                              e.toString(),
                            );
                          }
                        } finally {
                          // Set loading state menjadi false setelah selesai
                          if (mounted) {
                            ref.read(isLoadingProvider.notifier).state = false;
                          }
                        }
                      }
                    },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              // Ganti child berdasarkan state isLoading
              child:
                  isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                      : const Text(
                        'LOG IN',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
