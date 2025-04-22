import 'package:flutter/material.dart';

class FeatureMenuItem {
  final String title;
  final String description;
  final String emoji;
  final VoidCallback onTap;

  const FeatureMenuItem({
    required this.title,
    required this.description,
    required this.emoji,
    required this.onTap,
  });
}
