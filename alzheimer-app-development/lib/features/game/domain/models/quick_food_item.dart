import 'package:flutter/material.dart';

enum FoodCategory { Lauk, Karbo, Buah, Sayur }

class QuickFoodItem {
  final String title;
  final String image;
  final VoidCallback onTap;
  final FoodCategory category;

  QuickFoodItem({
    required this.title,
    required this.image,
    required this.onTap,
    required this.category,
  });
}
