import 'dart:math';
import 'package:flutter/material.dart';

class MpgExpaned extends StatefulWidget {
  const MpgExpaned({super.key});

  @override
  State<MpgExpaned> createState() => _MealPlanningGameState();
}

class _MealPlanningGameState extends State<MpgExpaned> {
  final Map<String, bool> placedItems = {
    'Karbo': false,
    'Lauk': false,
    'Sayur': false,
    'Buah': false,
  };

  // Lists of food options for each category
  final Map<String, List<FoodItem>> foodOptions = {
    'Karbo': [
      FoodItem('Nasi', 'assets/images/nasi.webp'),
      FoodItem('Roti', '🍞'),
      FoodItem('Kentang', '🥔'),
      FoodItem('Mie', '🍜'),
      FoodItem('Jagung', '🌽'),
    ],
    'Lauk': [
      FoodItem('Daging Sapi', '🥩'),
      FoodItem('Ayam', '🍗'),
      FoodItem('Ikan', '🐟'),
      FoodItem('Telur', '🥚'),
      FoodItem('Tempe', '🧀'),
    ],
    'Sayur': [
      FoodItem('Bayam', '🥬'),
      FoodItem('Wortel', '🥕'),
      FoodItem('Tomat', '🍅'),
      FoodItem('Brokoli', '🥦'),
      FoodItem('Terong', '🍆'),
    ],
    'Buah': [
      FoodItem('Pisang', '🍌'),
      FoodItem('Apel', '🍎'),
      FoodItem('Jeruk', '🍊'),
      FoodItem('Anggur', '🍇'),
      FoodItem('Semangka', '🍉'),
    ],
  };

  Map<String, FoodItem> currentSelection = {};
  int seed = 0;

  @override
  void initState() {
    super.initState();
    _selectRandomFoods();
  }

  void _selectRandomFoods() {
    final random = Random(seed);
    currentSelection = {
      'Karbo':
          foodOptions['Karbo']![random.nextInt(foodOptions['Karbo']!.length)],
      'Lauk': foodOptions['Lauk']![random.nextInt(foodOptions['Lauk']!.length)],
      'Sayur':
          foodOptions['Sayur']![random.nextInt(foodOptions['Sayur']!.length)],
      'Buah': foodOptions['Buah']![random.nextInt(foodOptions['Buah']!.length)],
    };
  }

  void _resetGame() {
    setState(() {
      placedItems.updateAll((key, value) => false);
      seed++;
      _selectRandomFoods();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final screenSize = MediaQuery.of(context).size;
    final bool isLandscape = screenSize.width > screenSize.height;
    final bool isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menyusun Menu Makan'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: isLandscape 
          ? _buildLandscapeLayout(screenSize, isSmallScreen)
          : _buildPortraitLayout(screenSize, isSmallScreen),
      floatingActionButton: FloatingActionButton(
        onPressed: _resetGame,
        backgroundColor: Colors.lightGreen,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildLandscapeLayout(Size screenSize, bool isSmallScreen) {
    return SafeArea(
      child: Row(
        children: [
          // Plate area
          Expanded(
            flex: 3,
            child: Container(
              color: const Color(0xFFB5DCBE),
              child: Center(
                child: _buildPlateArea(isSmallScreen),
              ),
            ),
          ),

          // Food items to drag
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildFoodOptionsArea(isSmallScreen),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitLayout(Size screenSize, bool isSmallScreen) {
    return SafeArea(
      child: Column(
        children: [
          // Plate area
          Expanded(
            flex: 3,
            child: Container(
              color: const Color(0xFFB5DCBE),
              child: Center(
                child: _buildPlateArea(isSmallScreen),
              ),
            ),
          ),

          // Food items to drag
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildFoodOptionsArea(isSmallScreen),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlateArea(bool isSmallScreen) {
    // Adjust plate size based on screen size
    final double plateSize = isSmallScreen ? 280 : 350;
    final double dropTargetSize = isSmallScreen ? 70 : 100;

    return Container(
      width: plateSize,
      height: plateSize,
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
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: plateSize * 0.9,
          height: plateSize * 0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDropTarget('Karbo', dropTargetSize),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDropTarget('Buah', dropTargetSize),
                  _buildDropTarget('Sayur', dropTargetSize),
                ],
              ),
              _buildDropTarget('Lauk', dropTargetSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodOptionsArea(bool isSmallScreen) {
    // Adjust layout based on screen size
    final int crossAxisCount = isSmallScreen ? 2 : 1;
    final double fontSize = isSmallScreen ? 12 : 16;
    final double iconSize = isSmallScreen ? 30 : 40;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.0,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: currentSelection.length,
      itemBuilder: (context, index) {
        final category = currentSelection.keys.elementAt(index);
        final food = currentSelection[category]!;
        
        return Draggable<String>(
          data: category,
          feedback: Material(
            color: Colors.transparent,
            child: _buildFoodItemDragging(food, iconSize),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _buildFoodItem(food, category, iconSize, fontSize),
          ),
          child: _buildFoodItem(food, category, iconSize, fontSize),
        );
      },
    );
  }

  Widget _buildFoodItemDragging(FoodItem food, double size) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: size * 2,
          width: size * 2,
          child: _buildFoodImage(food, size),
        ),
      ],
    );
  }

  Widget _buildFoodImage(FoodItem food, double size) {
    // Check if it's an emoji or an asset path
    if (food.image.startsWith('assets/')) {
      return Image.asset(food.image, fit: BoxFit.contain);
    } else {
      return Text(
        food.image, // Fallback to emoji if asset not available
        style: TextStyle(fontSize: size),
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _buildDropTarget(String category, double size) {
    return DragTarget<String>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: placedItems[category]!
                ? Border.all(color: Colors.transparent, width: 0)
                : Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(10),
            color: placedItems[category]!
                ? Colors.green.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Center(
            child: placedItems[category]!
                ? SizedBox(
                    height: size * 0.8,
                    width: size * 0.8,
                    child: _buildFoodImage(currentSelection[category]!, size * 0.5),
                  )
                : Text(
                    category,
                    style: TextStyle(
                      fontSize: size * 0.15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
      onWillAccept: (data) => data == category && !placedItems[category]!,
      onAccept: (data) {
        setState(() {
          placedItems[category] = true;

          // Check if all items are placed
          if (placedItems.values.every((placed) => placed)) {
            Future.delayed(const Duration(milliseconds: 800), () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Selamat!'),
                  content: const Text(
                    'Anda telah berhasil menyusun menu makanan yang lengkap!',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _resetGame();
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

  Widget _buildFoodItem(FoodItem food, String category, double iconSize, double fontSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: iconSize * 2,
          child: _buildFoodImage(food, iconSize),
        ),
        const SizedBox(height: 4),
        Text(
          food.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class FoodItem {
  final String name;
  final String image;

  FoodItem(this.name, this.image);
}