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
                return "Password cannot be empty";
              }

              List<String> requirements = [];
              if (value.length < 6) {
                requirements.add("at least 6 characters");
              }
              // if (!value.contains(RegExp(r'[A-Z]'))) {
              //   requirements.add("one uppercase letter");
              // }
              if (!value.contains(RegExp(r'[0-9]'))) {
                requirements.add("one number");
              }
              // if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
              //   requirements.add("one special character");
              // }

              if (requirements.isNotEmpty) {
                setState(() {
                  _passwordValid = false;
                });
                return "Password must contain ${requirements.join(", ")}";
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
                  _confirmPasswordError = "Passwords do not match";
                });
                return "Passwords do not match";
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
                  text: const TextSpan(
                    text: "Saya telah membaca ",
                    style: TextStyle(
                      color: Color(0xFFA1A4B2),
                      fontSize: 16, // Mungkin sedikit kecilkan jika perlu
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: "Ketentuan & Kebijakan privasi",
                        style: TextStyle(
                          color: Color(0xff7583CA),
                          fontWeight: FontWeight.w500,
                        ),
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
                    SnackBar(content: Text('Please accept the Privacy Policy')),
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
