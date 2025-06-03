import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/core/providers/shared_providers.dart';
import 'package:project/core/widgets/main_layout_widget.dart';
import 'package:project/features/auth/presentation/pages/signup_page.dart';
import 'package:project/features/auth/presentation/widgets/singin_form.dart';
import 'package:project/features/auth/providers/auth_provider.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  late final ProviderSubscription authSub;

  @override
  void initState() {
    super.initState();

    // ✅ Gunakan listenManual di initState
    authSub = ref.listenManual(authProvider, (previous, next) {
      if (next != null && mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const MainLayout()));
      }
    });
  }

  @override
  void dispose() {
    // ✅ Jangan lupa cancel agar tidak memory leak
    authSub.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);

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
                    const Text(
                      "Login Aplikasi",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(38),
                          side: const BorderSide(width: 1, color: Color(0xffEBEAEC)),
                        ),
                        elevation: 0,
                      ),
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                if (!mounted) return;
                                try {
                                  ref.read(isLoadingProvider.notifier).state =
                                      true;
                                  final authNotifier = ref.read(
                                    authProvider.notifier,
                                  );
                                  await authNotifier.signInWithGoogle();
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Login failed: $e')),
                                  );
                                } finally {
                                  if (mounted) {
                                    ref.read(isLoadingProvider.notifier).state =
                                        false;
                                  }
                                }
                              },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/google_icons.png",
                            width: 24,
                          ),
                          const SizedBox(width: 10),
                          const Text(
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
                    const Text(
                      "Atau login dengan email",
                      style: TextStyle(color: Color(0XFFA1A4B2), fontSize: 12),
                    ),
                    const SizedBox(height: 30),

                    const SignInForm(),

                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap:
                          isLoading
                              ? null
                              : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpPage(),
                                ),
                              ),
                      child: RichText(
                        text: const TextSpan(
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
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
