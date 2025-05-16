import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/core/providers/auth_provider.dart';
import 'package:project/features/auth/presentation/pages/signup_page.dart';

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
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter your email to receive a password reset link.'),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
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
                  await authNotifier.resetPassword(emailController.text.trim());
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Password reset email sent. Please check your inbox.',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to send reset email. Please try again.',
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
              setState(() {
                _passwordValid = true;
              });
              return null;
            },
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
        ],
      ),
    );
  }
}
