import 'package:flutter/material.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _emailValid = true;
  bool _passwordValid = true;

  InputDecoration _buildInputDecoration(String label, bool isValid) {
    return InputDecoration(
      labelStyle: TextStyle(color: Color(0xffA1A4B2), fontSize: 12),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      filled: true,
      fillColor: Color(0xffF2F3F7),
      labelText: label,
      hintText: "Email",
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            decoration: _buildInputDecoration("Email", _emailValid),
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
            obscureText: _obscurePassword,
            decoration: _buildInputDecoration(
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
              } else if (value.length < 8) {
                setState(() {
                  _passwordValid = false;
                });
                return "Password must be at least 8 characters";
              } else if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value)) {
                setState(() {
                  _passwordValid = false;
                });
                return "Password must contain at least 1 uppercase letter";
              } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                setState(() {
                  _passwordValid = false;
                });
                return "Password must contain at least 1 special character (@, #, \$, etc.)";
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
            onPressed: () {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate()) {
                // If the form is valid, display a snackbar. In the real world,
                // you'd often call a server or save the information in a database.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing Data')),
                );
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
