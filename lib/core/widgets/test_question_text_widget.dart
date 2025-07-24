import 'package:flutter/material.dart';

class TestQuestionTextWidget extends StatelessWidget {
  final String text;

  const TestQuestionTextWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 15,
        color: Color(0xFF222B45),
      ),
    );
  }
}
