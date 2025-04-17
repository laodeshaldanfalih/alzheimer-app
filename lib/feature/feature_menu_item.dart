import 'package:flutter/material.dart';

class FeatureMenuItem {
  final String title;
  final String description;
  final String imagePath;
  final Function(BuildContext) onTap; // Diubah dari VoidCallback

  FeatureMenuItem({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.onTap,
  });
}
