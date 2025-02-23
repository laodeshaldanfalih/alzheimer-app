import 'package:flutter/material.dart';
import 'package:project/features/auth/presentation/pages/signin_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SignInPage());
  }
}
