import 'package:flutter/material.dart';

class QuickFeatureItem {
  final String title;
  final Color color;
  final VoidCallback onTap;

  QuickFeatureItem({
    required this.title,
    required this.color,
    required this.onTap,
  });
}
