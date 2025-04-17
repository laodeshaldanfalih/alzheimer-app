import 'dart:math';
import 'package:flutter/material.dart';

class ResponsiveMealPlanningGame extends StatefulWidget {
  const ResponsiveMealPlanningGame({super.key});

  @override
  State<ResponsiveMealPlanningGame> createState() =>
      _ResponsiveMealPlanningGameState();
}

class _ResponsiveMealPlanningGameState
    extends State<ResponsiveMealPlanningGame> {
  final Map<String, bool> placedItems = {
    'Karbo': false,
    'Lauk': false,
    'Sayur': false,
    'Buah': false,
  };

  // Lists of food options for each category
  final Map<String, List<FoodItem>> foodOptions = {
    'Karbo': [
      FoodItem('Nasi', '🍚'),
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
      FoodItem('Udang Goreng', '🍤'),
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

  // Store the randomly ordered categories
  List<String> categoryOrder = ['Karbo', 'Lauk', 'Sayur', 'Buah'];

  // Define possible layouts for drop targets
  final List<List<String>> possibleLayouts = [
    // Layout 1: Original arrangement
    ['Karbo', 'Buah', 'Sayur', 'Lauk'],
    // Layout 2: Different arrangement
    ['Lauk', 'Sayur', 'Buah', 'Karbo'],
    // Layout 3: Another arrangement
    ['Buah', 'Karbo', 'Lauk', 'Sayur'],
    // Layout 4: Yet another arrangement
    ['Sayur', 'Lauk', 'Karbo', 'Buah'],
  ];

  int currentLayoutIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectRandomFoods();
    _randomizeDropTargetPositions();
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

  void _randomizeDropTargetPositions() {
    final random = Random(seed);

    // Either choose a predefined layout or completely randomize
    if (random.nextBool()) {
      // Use a predefined layout
      currentLayoutIndex = random.nextInt(possibleLayouts.length);
      categoryOrder = List.from(possibleLayouts[currentLayoutIndex]);
    } else {
      // Fully randomize the order
      categoryOrder = List.from(placedItems.keys.toList());
      categoryOrder.shuffle(random);
    }
  }

  void _resetGame() {
    setState(() {
      placedItems.updateAll((key, value) => false);
      seed++;
      _selectRandomFoods();
      _randomizeDropTargetPositions();
    });
  }

  void _checkGameCompletion(BuildContext context) {
    // Check if all items are placed
    if (placedItems.values.every((placed) => placed)) {
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
                      _resetGame();
                    },
                    child: const Text('Main Lagi'),
                  ),
                ],
              ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final screenSize = MediaQuery.of(context).size;
    final bool isWideScreen = screenSize.width >= 600;

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
      body:
          isWideScreen
              ? _buildExpandedLayout(context)
              : _buildMobileLayout(context),
      floatingActionButton: FloatingActionButton(
        onPressed: _resetGame,
        backgroundColor: Colors.lightGreen,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  // Mobile Layout (Original MealPlanningGame)
  Widget _buildMobileLayout(BuildContext context) {
    return Container(
      color: const Color(0xFFB5DCBE),
      child: Column(
        children: [
          // Plate area (Smaller for mobile)
          Expanded(
            flex: 2,
            child: Center(
              child: SizedBox(

                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Plate - white circular plate
                    Container(
                      width: 300,
                      height: 300,
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

                    // Food category positions on plate for mobile (now using randomized positions)
                    SizedBox(
                      height: 280,
                      width: 280,
                      child: _buildRandomizedPlateLayout(context, 80),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Food items to drag (Mobile layout)
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children:
                      currentSelection.entries.map((entry) {
                        final category = entry.key;
                        final food = entry.value;

                        return Draggable<String>(
                          data: category,
                          feedback: Material(
                            color: Colors.transparent,
                            child: _buildFoodItemDragging(food, 50),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: _buildFoodItem(food, "🔳", 50, 16),
                          ),
                          child: _buildFoodItem(
                            placedItems[category]!
                                ? FoodItem(food.name, "✅")
                                : food,
                            category,
                            50,
                            16,
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build the randomized plate layout based on the current categoryOrder
  Widget _buildRandomizedPlateLayout(BuildContext context, double size) {
    // Get the first category for top position
    final topCategory = categoryOrder[0];

    // Get the middle two categories for middle row
    final middleLeft = categoryOrder[1];
    final middleRight = categoryOrder[2];

    // Get the bottom category
    final bottomCategory = categoryOrder[3];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Top position
        _buildDropTarget(context, topCategory, size),

        // Middle row (left and right)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDropTarget(context, middleLeft, size),
            _buildDropTarget(context, middleRight, size),
          ],
        ),

        // Bottom position
        _buildDropTarget(context, bottomCategory, size),
      ],
    );
  }

  // Expanded Layout (MpgExpanded)
  Widget _buildExpandedLayout(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isLandscape = screenSize.width > screenSize.height;

    return SafeArea(
      child:
          isLandscape
              ? _buildLandscapeExpandedLayout(context)
              : _buildPortraitExpandedLayout(context),
    );
  }

  Widget _buildLandscapeExpandedLayout(BuildContext context) {
    return Row(
      children: [
        // Plate area
        Expanded(
          flex: 3,
          child: Container(
            color: const Color(0xFFB5DCBE),
            child: Center(child: _buildExpandedPlateArea(context)),
          ),
        ),

        // Food items to drag
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildExpandedFoodOptions(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitExpandedLayout(BuildContext context) {
    return Column(
      children: [
        // Plate area
        Expanded(
          flex: 3,
          child: Container(
            color: const Color(0xFFB5DCBE),
            child: Center(child: _buildExpandedPlateArea(context)),
          ),
        ),

        // Food items to drag
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildExpandedFoodOptions(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedPlateArea(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 400,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Plate - white circular plate
          Container(
            width: 400,
            height: 400,
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

          // Food category positions (now using randomized positions)
          SizedBox(
            height: 350,
            width: 350,
            child: _buildRandomizedPlateLayout(context, 100),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedFoodOptions(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isWideScreen = screenSize.width >= 600;
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Logika untuk menentukan crossAxisCount
    final int crossAxisCount;
    if (isLandscape && screenSize.width >= 600) {
      crossAxisCount = 2;
    } else if (isWideScreen) {
      crossAxisCount = 4;
    } else {
      crossAxisCount = 2;
    }
    return GridView.count(
      crossAxisCount: crossAxisCount,
      children:
          currentSelection.entries.map((entry) {
            final category = entry.key;
            final food = entry.value;

            return Draggable<String>(
              data: category,
              feedback: Material(
                color: Colors.transparent,
                child: _buildFoodItemDragging(food, 50),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _buildFoodItem(food, "🔳", 50, 16),
              ),
              child: _buildFoodItem(
                placedItems[category]! ? FoodItem(food.name, "✅") : food,
                category,
                50,
                16,
              ),
            );
          }).toList(),
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
        style: TextStyle(fontSize: 60),
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _buildDropTarget(BuildContext context, String category, double size) {
    return DragTarget<String>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border:
                placedItems[category]!
                    ? Border.all(color: Colors.transparent, width: 0)
                    : Border.all(color: Colors.transparent, width: 0),
            borderRadius: BorderRadius.circular(100),
            color:
                placedItems[category]!
                    ? Colors.transparent
                    : Colors.orange[100],
          ),
          child:
              placedItems[category]!
                  ? OverflowBox(
                    maxWidth: size * 1.5,
                    maxHeight: size * 1.5,
                    child: _buildFoodImage(
                      currentSelection[category]!,
                      size * 0.8,
                    ),
                  )
                  : Center(
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: size * 0.15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
        );
      },
      onWillAcceptWithDetails: (data) => data == category && !placedItems[category]!,
      onAcceptWithDetails: (data) {
        setState(() {
          placedItems[category] = true;
          _checkGameCompletion(context);
        });
      },
    );
  }

  Widget _buildFoodItem(
    FoodItem food,
    String category,
    double iconSize,
    double fontSize,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: iconSize * 2, child: _buildFoodImage(food, iconSize)),
        const SizedBox(height: 8),
        Text(
          food.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
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
