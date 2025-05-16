import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/core/providers/auth_provider.dart';
import 'package:project/core/providers/shared_providers.dart';
import 'package:project/core/widgets/main_layout.dart';
import 'package:project/features/auth/presentation/pages/signup_page.dart';
import 'package:project/features/auth/presentation/widgets/signin_form.dart';

class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);

    // Listen to auth state changes
    ref.listen(authProvider, (previous, next) {
      if (next != null) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => MainLayout()));
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      "Login Aplikasi",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
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
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                try {
                                  ref.read(isLoadingProvider.notifier).state =
                                      true;
                                  final authNotifier = ref.read(
                                    authProvider.notifier,
                                  );
                                  await authNotifier.signInWithGoogle();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Login failed: $e')),
                                  );
                                } finally {
                                  ref.read(isLoadingProvider.notifier).state =
                                      false;
                                }
                              },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/google_icons.png",
                            width: 24,
                          ),
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
                    const SizedBox(height: 30),
                    Text(
                      "Atau login dengan email",
                      style: TextStyle(color: Color(0XFFA1A4B2), fontSize: 12),
                    ),
                    const SizedBox(height: 30),
                    SignInForm(),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap:
                          isLoading
                              ? null
                              : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUpPage(),
                                ),
                              ),
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
