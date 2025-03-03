import 'package:flutter/material.dart';
import 'package:project/core/providers/navigation_provider.dart';
import 'package:project/features/auth/presentation/widgets/signup_form.dart';

class SingUpPage extends StatelessWidget {
  const SingUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Buat Akun",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(38),
                    side: BorderSide(width: 1, color: Color(0xffEBEAEC)),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  print("Google Sign-In Clicked!");
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/google_icons.png", width: 24),
                    SizedBox(width: 10),
                    Text(
                      "CONTINUE WITH GOOGLE",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                "Atau login dengan email",
                style: TextStyle(color: Color(0XFFA1A4B2), fontSize: 12),
              ),
              SizedBox(child: Column(children: [SignUpForm()])),
              Text(
                "Lupa Password?",
                style: TextStyle(color: Color(0xFFA1A4B2), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
