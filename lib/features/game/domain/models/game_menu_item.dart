import 'package:flutter/material.dart';

class GameMenuItem {
  final String title;
  final String description;
  final String imagePath;
  final VoidCallback onTap;

  GameMenuItem({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.onTap,
  });
}
