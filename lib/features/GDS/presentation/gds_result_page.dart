import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/features/GDS/data/gds_test_state.dart';
import 'package:project/features/GDS/presentation/gds_history_page.dart';

class GDSResultPage extends StatelessWidget {
  const GDSResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GDSTestState>(context);
    final score = state.currentScore;
    final isDepressed = score >= 5;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Hasil Tes GDS",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                "Hasil Tes",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color(0xFF222B45),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Status",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF8A94A6),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isDepressed
                                    ? const Color(0xFFFFEBEE)
                                    : const Color(0xFFE6F4EA),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isDepressed ? "Depresi" : "Tidak Depresi",
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  isDepressed
                                      ? const Color(0xFFC62828)
                                      : const Color(0xFF1E7E34),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Skor",
                      style: TextStyle(fontSize: 16, color: Color(0xFF8A94A6)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      score.toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222B45),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isDepressed
                          ? "Skor ≥ 5 mengindikasikan gejala depresi"
                          : "Skor < 5 mengindikasikan tidak ada gejala depresi",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8A94A6),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GDSHistoryPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Lihat Riwayat",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
