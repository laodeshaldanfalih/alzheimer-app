import 'package:flutter/material.dart';

class QuickFeatureItem {
  final String title;
  final Color color;
  final void Function(BuildContext context) onTap;

  const QuickFeatureItem({
    required this.title,
    required this.color,
    required this.onTap,
  });
}
