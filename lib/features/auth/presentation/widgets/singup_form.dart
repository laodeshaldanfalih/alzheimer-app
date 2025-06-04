import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/auth/providers/auth_provider.dart';

class SignUpForm extends ConsumerStatefulWidget {
  const SignUpForm({super.key});

  @override
  ConsumerState<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends ConsumerState<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  // HAPUS: final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  // HAPUS: bool _usernameValid = true;
  bool _emailValid = true;
  bool _passwordValid = true;
  bool _confirmPasswordValid = true;
  String? _confirmPasswordError;
  bool isChecked = false;

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
          backgroundColor: const Color(0xffFAF9F6),
            title: const Text('Ketentuan & Kebijakan Privasi'),
            content: SingleChildScrollView(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: privacyPolicyText,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff7583CA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }

  // Teks kebijakan privasi aplikasi
  final String privacyPolicyText = '''
Aplikasi Kesehatan Alzheimer ("Kami") berkomitmen untuk melindungi privasi pengguna. Kebijakan ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi pribadi Anda.

1. Informasi yang Kami Kumpulkan:
- Data profil pengguna (nama, email, foto profil)
- Data kesehatan (hasil klasifikasi otak, asesmen geriatri)
- Data penggunaan (interaksi dengan fitur dasbor kesehatan)
- Data perangkat (untuk notifikasi pengingat)

2. Penggunaan Data:
- Memberikan layanan personalisasi (artikel kesehatan, pengingat)
- Meningkatkan akurasi klasifikasi kondisi otak
- Mengembangkan fitur baru (asesmen geriatri)
- Mengirim pembaruan dan informasi kesehatan

3. Perlindungan Data:
- Enkripsi data selama penyimpanan dan transmisi
- Akses terbatas hanya untuk stah medis terkait
- Penyimpanan data di server dengan sertifikat keamanan

4. Hak Pengguna:
- Mengakses dan memperbarui data profil
- Menghapus akun dan data pribadi
- Menerima salinan data kesehatan Anda
- Menolak pengumpulan data tertentu

5. Data Kesehatan:
- Hasil klasifikasi otak hanya digunakan untuk tujuan medis
- Data asesmen geriatri disimpan terpisah dengan identifikasi unik
- Informasi kesehatan tidak akan dijual/dibagikan ke pihak ketiga tanpa persetujuan

6. Perubahan Kebijakan:
Kebijakan ini dapat diperbarui secara berkala. Versi terbaru akan selalu tersedia di aplikasi.

Dengan menggunakan aplikasi ini, Anda menyetujui pengumpulan dan penggunaan informasi sesuai kebijakan ini.

''';

  InputDecoration _buildInputDecoration(
    String label,
    String hintText,
    bool isValid, [
    String? errorText,
  ]) {
    return InputDecoration(
      labelStyle: const TextStyle(color: Color(0xffA1A4B2), fontSize: 12),
      hintStyle: const TextStyle(color: Color(0xffA1A4B2), fontSize: 12),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      filled: true,
      fillColor: const Color(0xffF2F3F7),
      labelText: label,
      hintText: hintText,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(15),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: isValid ? Colors.transparent : Colors.red,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
      errorText: errorText,
    );
  }

  @override
  void dispose() {
    // HAPUS: _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _buildInputDecoration(
              "Email",
              "Mohon isi dengan email yang valid",
              _emailValid,
            ),
            validator: (value) {
              bool isValid =
                  value != null &&
                  value.isNotEmpty &&
                  RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);
              setState(() {
                _emailValid = isValid;
              });
              return isValid ? null : "Email harus valid!";
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: _buildInputDecoration(
              "Password",
              "Min. 6 karakter dengan angka",
              _passwordValid,
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  size: 20,
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: _passwordValid ? Colors.grey : Colors.red,
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
                setState(() {
                  _passwordValid = false;
                });
                return "Password tidak boleh kosong!";
              }

              List<String> requirements = [];
              if (value.length < 6) {
                requirements.add("Min. 6 karakter dengan angka");
              }
              // if (!value.contains(RegExp(r'[A-Z]'))) {
              //   requirements.add("one uppercase letter");
              // }
              if (!value.contains(RegExp(r'[0-9]'))) {
                requirements.add("angka");
              }
              // if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
              //   requirements.add("one special character");
              // }

              if (requirements.isNotEmpty) {
                setState(() {
                  _passwordValid = false;
                });
                return "Password harus mengandung ${requirements.join(", ")}";
              }

              setState(() {
                _passwordValid = true;
              });
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: _buildInputDecoration(
              "Konfirmasi Password",
              "Masukkan ulang password",
              _confirmPasswordValid,
              _confirmPasswordError,
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  size: 20,
                  _obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: _confirmPasswordValid ? Colors.grey : Colors.red,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value != _passwordController.text) {
                setState(() {
                  _confirmPasswordValid = false;
                  _confirmPasswordError = "Password tidak sesuai";
                });
                return "Password tidak sesuai";
              }
              setState(() {
                _confirmPasswordValid = true;
                _confirmPasswordError = null;
              });
              return null;
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                // Tambahkan Flexible untuk teks panjang
                child: RichText(
                  text: TextSpan(
                    text: "Saya telah membaca ",
                    style: const TextStyle(
                      color: Color(0xFFA1A4B2),
                      fontSize: 16, // Mungkin sedikit kecilkan jika perlu
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: "Ketentuan & Kebijakan privasi",
                        style: const TextStyle(
                          color: Color(0xff7583CA),
                          fontWeight: FontWeight.w500,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _showPrivacyPolicy,
                        // Anda bisa menambahkan recognizer di sini untuk membuka halaman Privacy Policy
                      ),
                    ],
                  ),
                ),
              ),
              Checkbox(
                checkColor: Colors.white,
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 30),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, double.minPositive),
              backgroundColor: const Color(0xff7583CA),
              foregroundColor: Colors.white, // Warna teks tombol
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate() && isChecked) {
                try {
                  final authNotifier = ref.read(authProvider.notifier);
                  await authNotifier.signUpWithEmail(
                    _emailController.text.trim(),
                    _passwordController.text,
                    // HAPUS: _usernameController.text.trim(),
                  );
                } catch (e) {
                  if (mounted) {
                    // Pastikan widget masih mounted sebelum menampilkan SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Registration failed: ${e.toString()}'),
                      ),
                    );
                  }
                }
              } else if (!isChecked) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Tolong setujui kotak ketentuan & kebijakan privasi ',
                      ),
                    ),
                  );
                }
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),

              child: Text(
                'SIGN UP',
                style: TextStyle(
                  color: Colors.white,
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
