import 'package:flutter/material.dart';

class TestNextButton extends StatelessWidget {
  final bool isComplete;
  final VoidCallback onPressed;

  const TestNextButton({
    super.key,
    required this.isComplete,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isComplete ? const Color(0xFF2563EB) : Colors.grey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: isComplete ? onPressed : null,
        child: const Text(
          "Selanjutnya",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
