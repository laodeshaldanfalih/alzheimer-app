import 'package:flutter/material.dart';
import 'package:project/core/providers/navigation_provider.dart';
import 'package:project/features/auth/presentation/widgets/signin_form.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Login Aplikasi",
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
              SizedBox(child: Column(children: [SignInForm()])),
              GestureDetector(
                onTap: () => navigateToRegister(context),
                child: RichText(
                  text: TextSpan(
                    text: "Belum punya akun? ",
                    style: TextStyle(
                      color: Color(0xFFA1A4B2),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: "Daftar Disini!",
                        style: TextStyle(
                          color: Color(0xff7583CA),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
