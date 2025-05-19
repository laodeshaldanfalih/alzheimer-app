import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/login/auth_provider.dart';
import 'package:project/features/login/phone_signin_page.dart';
import 'package:project/features/login/signup_page.dart';

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
  bool _emailValid = true;
  bool _passwordValid = true;

  InputDecoration _buildInputDecoration(
    String label,
    String hintText,
    bool isValid,
  ) {
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
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Failed'),
          content: Text(message),
          actions: [
            if (message.contains('user-not-found'))
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
                },
                child: Text(
                  'Register Now',
                  style: TextStyle(color: Color(0xff7583CA)),
                ),
              ),
            if (message.contains('Incorrect password'))
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showForgotPasswordDialog(context);
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: Color(0xff7583CA)),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController inputController = TextEditingController();
    String resetMethod = 'email'; // Default to email reset

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Enter your email or phone number to reset your password.'),
                  SizedBox(height: 16),
                  TextField(
                    controller: inputController,
                    decoration: InputDecoration(
                      labelText: resetMethod == 'email' ? 'Email' : 'Nomor Telepon',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: resetMethod == 'email' ? TextInputType.emailAddress : TextInputType.phone,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Reset via:'),
                      Radio<String>(
                        value: 'email',
                        groupValue: resetMethod,
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              resetMethod = value;
                              inputController.clear(); // Clear input when changing method
                            });
                          }
                        },
                      ),
                      Text('Email'),
                      Radio<String>(
                        value: 'phone',
                        groupValue: resetMethod,
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              resetMethod = value;
                               inputController.clear(); // Clear input when changing method
                            });
                          }
                        },
                      ),
                      Text('Nomor Telepon'),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final authNotifier = ref.read(authProvider.notifier);
                  if (resetMethod == 'email') {
                    await authNotifier.resetPasswordByEmail(inputController.text.trim());
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Password reset email sent. Please check your inbox.',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else { // Reset via phone number
                     await authNotifier.resetPasswordByPhoneNumber(inputController.text.trim());
                     Navigator.pop(context);
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'If a user with this phone number exists, a password reset email has been sent to their linked email address.',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to send reset link: ${e.toString()}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(
                'Send Reset Link',
                style: TextStyle(color: Color(0xff7583CA)),
              ),
            ),
          ],
        );
      },
    );
  }


  String _getReadableErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No account found with this email. Would you like to register?';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
       case 'email-not-found for this phone number.': // Custom error from auth_provider
        return 'No email found linked to this phone number.';
      case 'No user found with this phone number.': // Custom error from auth_provider
        return 'No user found with this phone number.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
            decoration: _buildInputDecoration("Email", "Email", _emailValid),
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
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: _buildInputDecoration(
              "Password",
              "Password",
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

              // Check minimum length
              if (value.length < 6) {
                requirements.add("at least 6 characters");
              }

              // Check for uppercase letter
              // if (!value.contains(RegExp(r'[A-Z]'))) {
              //   requirements.add("one uppercase letter");
              // }

              // Check for number
              if (!value.contains(RegExp(r'[0-9]'))) {
                requirements.add("one number");
              }

              // // Check for special character
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
          SizedBox(height: 10), // Adjusted spacing
           Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => _showForgotPasswordDialog(context),
              child: Text(
                "Forgot Password?",
                style: TextStyle(color: Color(0xff7583CA), fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, double.minPositive),
              backgroundColor: Color(0xffD9D9D9),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  final authNotifier = ref.read(authProvider.notifier);
                  await authNotifier.signInWithEmail(
                    _emailController.text.trim(),
                    _passwordController.text,
                  );
                } catch (e) {
                  String errorCode = e.toString();
                  // Extract error code from Firebase error message
                  if (errorCode.contains(']')) {
                    errorCode = errorCode.split('] ').last;
                  }
                  _showErrorDialog(
                    context,
                    _getReadableErrorMessage(errorCode),
                  );
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                'LOG IN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
           SizedBox(height: 20), // Added spacing
          Text(
            "Atau login dengan nomor telepon",
            style: TextStyle(color: Color(0XFFA1A4B2), fontSize: 12),
          ),
          SizedBox(height: 20), // Added spacing
           ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, double.minPositive),
              backgroundColor: Color(0xffD9D9D9),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PhoneSignInPage()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                'LOG IN WITH PHONE NUMBER',
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