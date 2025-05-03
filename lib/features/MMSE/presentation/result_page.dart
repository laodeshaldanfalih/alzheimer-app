import 'package:flutter/material.dart';

class MMSEResultPage extends StatelessWidget {
  final int score;
  final String description;

  const MMSEResultPage({
    super.key,
    required this.score,
    required this.description,
  });

  String _getResultImage() {
    if (score >= 24) {
      return 'assets/images/good_result.png';
    } else if (score >= 18) {
      return 'assets/images/mid_result.png';
    } else {
      return 'assets/images/bad_result.png';
    }
  }

  Color _getResultColor() {
    if (score >= 24) {
      return const Color(0xFFAFE073);
    } else if (score >= 18) {
      return const Color(0xFFFFD54F);
    } else {
      return const Color(0xFFFF8A65);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FCFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        title: const Text(
          'Mini–Mental State Exam (MMSE)',
          style: TextStyle(
            color: Color(0xFF222B45),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: _getResultColor(),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        _getResultImage(),
                        height: 60,
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  Text(
                    'Pasien mendapatkan skor $score!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF222B45),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      child: const Text(
                        'Kembali ke Halaman Utama',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
