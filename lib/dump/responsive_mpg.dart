import 'package:flutter/material.dart';
import 'package:project/dump/state/meal_planning_game_state.dart';
import 'package:provider/provider.dart';
import 'package:project/dump/meal_planning_game.dart';
import 'package:project/dump/mpg_expaned.dart';
import 'package:project/dump/responsive_layout.dart';

class ResponsiveMpg extends StatefulWidget {
  const ResponsiveMpg({super.key});

  @override
  State<ResponsiveMpg> createState() => _ResponsiveMpgState();
}

class _ResponsiveMpgState extends State<ResponsiveMpg> {
  final gameState = MealPlanningGameState();
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: gameState,
      child: Scaffold(
        body: ResponsiveLayout(
          mobileBody: MealPlanningGame(),
          extendedBody: MpgExpaned(),
        ),
      ),
    );
  }
}