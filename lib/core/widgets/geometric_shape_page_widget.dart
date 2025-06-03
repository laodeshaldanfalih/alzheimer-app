import 'dart:math' as Math;

import 'package:flutter/material.dart';

class GeometricBackgroundWidget extends StatelessWidget {
  const GeometricBackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar untuk menyesuaikan posisi bentuk
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: size.height * 0.7, // Menggunakan tinggi dari kode pertama
      color: const Color(0xFF7C7E93), // Warna background #7C7E93
      child: Stack(
        children: [
          // Lingkaran besar dengan pola grid (kiri atas) - dari kode pertama
          Positioned(
            left: -50,
            top: -50,
            child: ClipOval(
              child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A4C5C).withOpacity(0.9),
                ),
                child: CustomPaint(
                  painter: GridPainter(
                    color: const Color(0xFF5D5F71),
                    strokeWidth: 1.0,
                    spacing: 15,
                  ),
                ),
              ),
            ),
          ),

          // Large dark circle with grid pattern - dari kode kedua
          Positioned(
            left: size.width * 0.6,
            top: -30,
            child: ClipOval(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFF898CB0).withOpacity(0.9),
                ),
                child: CustomPaint(
                  painter: GridPainter(
                    color: const Color(0xFF898CB0).withOpacity(0.9),
                    strokeWidth: 1.0,
                    spacing: 15,
                  ),
                ),
              ),
            ),
          ),

          // Persegi panjang besar dengan pola titik (kanan atas) - dari kode pertama
          Positioned(
            right: -10,
            top: -30,
            child: Container(
              width: 200,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: DotsPainter(
                  color: Colors.grey[400]!,
                  dotSize: 2,
                  spacing: 15,
                ),
              ),
            ),
          ),

          // Square with dots pattern (top right) - dari kode kedua
          Positioned(
            right: -20,
            top: 210,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF8D8FA6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: DotsPainter(
                  color: Colors.white.withOpacity(0.3),
                  dotSize: 2,
                  spacing: 15,
                ),
              ),
            ),
          ),

          // Medium circle with chevron pattern - dari kode kedua
          Positioned(
            right: 20,
            top: 100,
            child: ClipOval(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFFB5BED4).withOpacity(0.5),
                ),
                child: CustomPaint(
                  painter: ChevronPainter(
                    color: const Color(0xFF898CB0).withOpacity(0.5),
                    strokeWidth: 1.5,
                    spacing: 12,
                  ),
                ),
              ),
            ),
          ),

          // Lingkaran tengah dengan pola chevron - dari kode pertama
          Positioned(
            left: 40,
            top: 100,
            child: ClipOval(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFAAADC4).withOpacity(0.7),
                ),
                child: CustomPaint(
                  painter: ChevronPainter(
                    color: const Color(0xFF898CB0),
                    strokeWidth: 1.5,
                    spacing: 12,
                  ),
                ),
              ),
            ),
          ),

          // BENTUK BARU DI TENGAH LAYAR
          // Hexagon di tengah layar dengan pola campuran
          Positioned(
            left: size.width / 2 - 75, // Tengah layar
            top: size.height * 0.35 - 75, // Tengah area background
            child: ClipPath(
              clipper: HexagonClipper(),
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFFB5BED4), const Color(0xFF4A4C5C)],
                  ),
                ),
                child: CustomPaint(
                  painter: CombinedPatternPainter(
                    gridColor: Colors.white.withOpacity(0.4),
                    dotColor: Colors.white.withOpacity(0.6),
                    lineWidth: 1.0,
                    spacing: 12,
                    dotSize: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Persegi panjang besar dengan pola grid (kanan bawah) - dari kode pertama
          // Positioned(
          //   right: 5,
          //   top: 200,
          //   child: Container(
          //     width: 220,
          //     height: 120,
          //     decoration: BoxDecoration(
          //       color: const Color(0xFF4A4C5C),
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     child: CustomPaint(
          //       painter: GridPainter(
          //         color: const Color(0xFF5D5F71),
          //         strokeWidth: 1.0,
          //         spacing: 15,
          //       ),
          //     ),
          //   ),
          // ),

          // Persegi panjang putih dengan garis diagonal (kiri bawah) - dari kode pertama
          Positioned(
            left: -20,
            bottom: 130,
            child: Container(
              width: 200,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: DiagonalPainter(
                  color: Colors.grey[300]!,
                  strokeWidth: 1,
                  spacing: 10,
                ),
              ),
            ),
          ),

          // Small square with diagonal lines - dari kode kedua
          Positioned(
            left: 50,
            bottom: 60,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFB5BED4).withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: DiagonalPainter(
                  color: const Color(0xFF898CB0).withOpacity(0.5),
                  strokeWidth: 1,
                  spacing: 8,
                ),
              ),
            ),
          ),

          // Persegi kecil dengan garis diagonal (tengah bawah) - dari kode pertama
          Positioned(
            left: 150,
            bottom: 30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF8D8FA6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: DiagonalPainter(
                  color: const Color(0xFF7C7E93),
                  strokeWidth: 1,
                  spacing: 8,
                ),
              ),
            ),
          ),

          // Persegi kecil putih dengan garis diagonal (bawah kanan) - dari kode pertama
          Positioned(
            right: 60,
            bottom: 20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: DiagonalPainter(
                  color: Colors.grey[300]!,
                  strokeWidth: 1,
                  spacing: 6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom clipper untuk bentuk hexagon
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    final centerX = width / 2;
    final centerY = height / 2;
    final radius = width / 2;

    // Membuat hexagon
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * (3.14159 / 180); // Konversi derajat ke radian
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Custom painter untuk pola grid
class GridPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double spacing;

  GridPainter({
    required this.color,
    required this.strokeWidth,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (double i = 0; i <= size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Draw horizontal lines
    for (double i = 0; i <= size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter untuk pola titik
class DotsPainter extends CustomPainter {
  final Color color;
  final double dotSize;
  final double spacing;

  DotsPainter({
    required this.color,
    required this.dotSize,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    for (double y = spacing; y < size.height; y += spacing) {
      for (double x = spacing; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter untuk pola chevron (zig-zag)
class ChevronPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double spacing;

  ChevronPainter({
    required this.color,
    required this.strokeWidth,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    // Drawing horizontal zigzag lines
    for (double y = 0; y < size.height; y += spacing * 2) {
      final path = Path();
      path.moveTo(0, y);

      double x = 0;
      bool up = false;

      while (x < size.width) {
        x += spacing;
        if (x > size.width) break;
        path.lineTo(x, up ? y - spacing / 2 : y + spacing / 2);

        up = !up;
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter untuk garis diagonal
class DiagonalPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double spacing;

  DiagonalPainter({
    required this.color,
    required this.strokeWidth,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    for (double i = -size.height; i <= size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter untuk pola kombinasi (grid + dots) untuk bentuk di tengah
class CombinedPatternPainter extends CustomPainter {
  final Color gridColor;
  final Color dotColor;
  final double lineWidth;
  final double spacing;
  final double dotSize;

  CombinedPatternPainter({
    required this.gridColor,
    required this.dotColor,
    required this.lineWidth,
    required this.spacing,
    required this.dotSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Grid lines
    final gridPaint =
        Paint()
          ..color = gridColor
          ..strokeWidth = lineWidth
          ..style = PaintingStyle.stroke;

    // Vertical lines - hanya sebagian untuk efek partial grid
    for (double i = 0; i < size.width / 2; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }

    // Dots pattern di bagian kanan
    final dotPaint =
        Paint()
          ..color = dotColor
          ..style = PaintingStyle.fill;

    for (double y = spacing; y < size.height; y += spacing) {
      for (double x = size.width / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, dotPaint);
      }
    }

    // Garis diagonal di sepanjang tengah untuk memisahkan kedua pola
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      Paint()
        ..color = Colors.white.withOpacity(0.7)
        ..strokeWidth = lineWidth * 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Helper function untuk trigonometri (untuk membuat hexagon)
double cos(double radians) {
  return Math.cos(radians);
}

double sin(double radians) {
  return Math.sin(radians);
}

// Import Math dari dart:math
