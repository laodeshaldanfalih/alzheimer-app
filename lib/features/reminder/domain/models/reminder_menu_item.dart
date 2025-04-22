import 'package:flutter/material.dart';

class ReminderMenuItem {
  final String title;
  final String description;
  final String emoji;
  final VoidCallback onTap;

  const ReminderMenuItem({
    required this.title,
    required this.description,
    required this.emoji,
    required this.onTap,
  });
}
