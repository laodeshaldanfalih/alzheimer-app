import 'package:flutter/material.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _emailValid = true;
  bool _passwordValid = true;
  bool _confirmPasswordValid = true;
  String? _confirmPasswordError;
  bool isChecked = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  InputDecoration _buildInputDecoration(
    String label,
    String hintText,
    bool isValid, [
    String? errorText,
  ]) {
    return InputDecoration(
      labelStyle: TextStyle(color: Color(0xffA1A4B2), fontSize: 12),
      hintStyle: TextStyle(color: Color(0xffA1A4B2), fontSize: 12),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      filled: true,
      fillColor: Color(0xffF2F3F7),
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
        borderSide: BorderSide(color: Colors.red, width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
      errorText: errorText, // Show error message dynamically
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          // ✅ Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _buildInputDecoration(
              "Email",
              "Enter your email",
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
              return isValid ? null : "Enter a valid email";
            },
          ),
          SizedBox(height: 20),

          // ✅ Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: _buildInputDecoration(
              "Password",
              "Enter your password",
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
                return "Password cannot be empty";
              } else if (value.length < 8) {
                return "Password must be at least 8 characters";
              } else if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value)) {
                return "Password must contain at least 1 uppercase letter";
              } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                return "Password must contain at least 1 special character (@, #, \$, etc.)";
              }
              return null;
            },
          ),
          SizedBox(height: 20),

          // ✅ Confirm Password Field (Live Validation)
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: _buildInputDecoration(
              "Confirm Password",
              "Re-enter your password",
              _confirmPasswordValid,
              _confirmPasswordError, // Dynamic error message
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
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  _confirmPasswordValid = false;
                  _confirmPasswordError = "Please confirm your password";
                } else if (value != _passwordController.text) {
                  _confirmPasswordValid = false;
                  _confirmPasswordError = "Passwords do not match";
                } else {
                  _confirmPasswordValid = true;
                  _confirmPasswordError = null;
                }
              });
            },
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  text: "I have read the ",
                  style: TextStyle(
                    color: Color(0xFFA1A4B2),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: "Privacy Policy",
                      style: TextStyle(
                        color: Color(0xff7583CA),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
          SizedBox(height: 30),
          // ✅ Sign Up Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, double.minPositive),
              backgroundColor: Color(0xffD9D9D9),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing Data')),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
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
