import 'package:flutter/material.dart';
import 'package:project/color_game.dart';
import 'package:project/menu_game.dart';
import 'package:project/dump/responsive_mpg.dart';
import 'package:project/responsive/responsive_meal_planning_game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: const MenuGame()
 ,
      
      debugShowCheckedModeBanner: false,
    );
  }
}
