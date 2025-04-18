import 'package:flutter/material.dart';
import 'package:project/firebase/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project/menu_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Tambahkan ini dulu!
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: const MenuGame(),

      debugShowCheckedModeBanner: false,
    );
  }
}
