// Langkah 1: Buat sebuah provider/state manager untuk menyimpan status game
import 'package:flutter/material.dart';
import 'dart:math';

// Langkah 2: Buat class untuk mengelola state game
class MealPlanningGameState extends ChangeNotifier {
  // Data yang ingin dipertahankan antar layout
  final Map<String, bool> placedItems = {
    'Karbo': false,
    'Lauk': false,
    'Sayur': false,
    'Buah': false,
  };

  Map<String, FoodItem> currentSelection = {};
  int seed = 0;

  // Lists of food options yang sama dengan yang ada di class game
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

  MealPlanningGameState() {
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

  void placeItem(String category) {
    placedItems[category] = true;
    notifyListeners();
  }

  void resetGame() {
    placedItems.updateAll((key, value) => false);
    seed++;
    _selectRandomFoods();
    notifyListeners();
  }

  bool isGameCompleted() {
    return placedItems.values.every((placed) => placed);
  }
}

class FoodItem {
  final String name;
  final String image;

  FoodItem(this.name, this.image);
}

