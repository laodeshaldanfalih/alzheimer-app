import 'package:flutter/material.dart';

class GameMenuItem {
  final String title;
  final String description;
  final String emoji;
  final VoidCallback onTap;

  const GameMenuItem({
    required this.title,
    required this.description,
    required this.emoji,
    required this.onTap,
  });
}
