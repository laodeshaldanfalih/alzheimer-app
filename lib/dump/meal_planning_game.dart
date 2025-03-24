import 'dart:math';
import 'package:flutter/material.dart';
import 'package:project/dump/state/meal_planning_game_state.dart';
import 'package:provider/provider.dart';

class MealPlanningGame extends StatefulWidget {
  const MealPlanningGame({super.key});

  @override
  State<MealPlanningGame> createState() => _MealPlanningGameState();
}

class _MealPlanningGameState extends State<MealPlanningGame> {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<MealPlanningGameState>(context);

    final size = 50;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menyusun Menu Makan'),
        backgroundColor: Colors.white, // Mint green color from design
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        color: Color(0xFFB5DCBE), // Mint green background
        child: Column(
          children: [
            // Plate area
            Expanded(
              flex: 3,
              child: Center(
                child: SizedBox(
                  width: 1000,
                  height: 1000,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Plate - white circular plate
                      Container(
                        width: 1000,
                        height: 1000,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                      ),

                      // Food category positions on plate
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Positioned(
                            child: _buildDropTarget('Buah', size),
                          ),
                          Positioned(
                            child: _buildDropTarget('Sayur', size),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Positioned(
                            child: _buildDropTarget('Karbo', size),
                          ),
                          Positioned(
                            child: _buildDropTarget('Lauk', size),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Food items to drag
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children:
                        gameState.currentSelection.entries.map((entry) {
                          final category = entry.key;
                          final food = entry.value;

                          return Draggable<String>(
                            data: category,
                            feedback: Material(
                              color: Colors.transparent,
                              child: _buildFoodItemDragging(food, size),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: _buildFoodItem(food, category, size),
                            ),
                            child: _buildFoodItem(food, category, size),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 150, right: 16.0),
          child: FloatingActionButton(
            onPressed: gameState.resetGame,
            backgroundColor: Colors.lightGreen,
            child: const Icon(Icons.refresh, color: Colors.white,),
          ),
        ),
      ),
    );
  }


  Widget _buildFoodItemDragging(FoodItem food, num size) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 100, width: 100, child: _buildFoodImage(food)),
      ],
    );
  }

  Widget _buildFoodImage(FoodItem food) {
    // Check if it's an emoji or an asset path
    if (food.image.startsWith('assets/')) {
      return Image.asset(food.image, fit: BoxFit.contain);
    } else {
      return Text(
        food.image, // Fallback to emoji if asset not available
        style: TextStyle(fontSize: 40),
        textAlign: TextAlign.center,
      );
    }
  }

Widget _buildDropTarget(String category, num size) {
  final double dropTargetSize = 75;
  final gameState = Provider.of<MealPlanningGameState>(context);

  return DragTarget<String>(
    builder: (context, candidateData, rejectedData) {
      return Container(
        width: dropTargetSize,
        height: dropTargetSize,
        decoration: BoxDecoration(
          // Only show border when no item is placed
          border: gameState.placedItems[category]! 
              ? Border.all(color: Colors.transparent, width: 0)
              : Border.all(color: Colors.black, width: 2,),
          borderRadius: BorderRadius.circular(10),
          color: gameState.placedItems[category]! 
              ? Colors.green.withOpacity(0.1) 
              : Colors.transparent,
        ),
        child: Center(
          child: gameState.placedItems[category]!
              // Show the image when an item is placed
              ? SizedBox(
                  height: 100, // Adjusted height to fit better
                  width: 100,  // Adjusted width to fit better
                  child: _buildFoodImage(gameState.currentSelection[category]!),
                )
              // Show category text when no item is placed
              : Text(
                  category,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
        ),
      );
    },
      onWillAccept: (data) => data == category && !gameState.placedItems[category]!,
      onAccept: (data) {
        setState(() {
          gameState.placedItems[category] = true;

          // Check if all items are placed
          if (gameState.isGameCompleted()) {
            Future.delayed(const Duration(milliseconds: 800), () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Selamat!'),
                      content: const Text(
                        'Anda telah berhasil menyusun menu makanan yang lengkap!',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            gameState.resetGame();
                          },
                          child: const Text('Main Lagi'),
                        ),
                      ],
                    ),
              );
            });
          }
        });
      },
    );
  }

  Widget _buildFoodItem(FoodItem food, String category, num size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 100, child: _buildFoodImage(food)),
        const SizedBox(height: 8),
        Text(
          food.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}


