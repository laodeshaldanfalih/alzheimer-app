import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project/core/providers/auth_provider.dart';
import 'package:project/features/auth/presentation/pages/signin_page.dart';

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(
      authProvider.notifier,
    ); // Use Riverpod for auth

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          "Halo, Afanda Mirza Lutfirahman",
          style: TextStyle(fontSize: 12, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authNotifier.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignInPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        color: const Color(0xff4C53B4), // Set entire background to purple
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                height: 177,
                width: 210,
                decoration: BoxDecoration(
                  color: const Color(0xff8E97FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 48,
                      left: 0,
                      right: 0,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Column(
                          children: const [
                            Text(
                              "14:30",
                              style: TextStyle(
                                color: Color(0xffFFECCC),
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Rabu, 5 Februari 2025",
                              style: TextStyle(
                                color: Color(0xffFFECCC),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: SvgPicture.asset('assets/svgs/wave.svg'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 27),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fitur',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _featureItem("Analisis Kamera", Colors.greenAccent),
                          _featureItem("Chatbot", Colors.pinkAccent),
                          _featureItem("Musik", Colors.lightBlueAccent),
                          _featureItem("Pengingat Obat", Colors.amber),
                        ],
                      ),
                      const SizedBox(height: 43),
                      const Text(
                        'Buletin Artikel',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _articleItem(),
                      _articleItem(),
                      _articleItem(),
                      _articleItem(),
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

  Widget _featureItem(String title, Color color) {
    return Column(
      children: [
        CircleAvatar(radius: 20, backgroundColor: color),
        const SizedBox(height: 5),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _articleItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Text(
              "Lorem ipsum dolor sit amet, vel eu omnes postea commune, discere nostrum fastidii et vis.",
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
