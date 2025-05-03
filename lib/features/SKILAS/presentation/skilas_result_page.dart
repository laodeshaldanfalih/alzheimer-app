import 'package:flutter/material.dart';
import 'package:project/features/SKILAS/models/skilas_test_entry.dart';
import 'package:provider/provider.dart';
import '../data/skilas_test_state.dart';
import 'skilas_history_page.dart';

class SKILASResultPage extends StatelessWidget {
  const SKILASResultPage({super.key});

  Future<void> _saveHistory(BuildContext context, bool isBad) async {
    final historyProvider = SKILASHistoryProvider();
    await historyProvider.loadHistory();
    await historyProvider.addEntry(
      SKILASHistoryEntry(score: isBad ? 0 : 1, date: DateTime.now()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final skilasState = Provider.of<SKILASTestState>(context, listen: false);
    final isBad = skilasState.isAnyAnswerWrong;
    _saveHistory(context, isBad); // Save history on build
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        title: const Text(
          'Skrining Lansia Sederhana (SKILAS)',
          style: TextStyle(
            color: Color(0xFF222B45),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
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
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color:
                        isBad
                            ? const Color(0xFFFFE0E0)
                            : const Color(0xFFE0F7D9),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      isBad
                          ? 'assets/images/skilas_bad.png'
                          : 'assets/images/skilas_good.png',
                      height: 90,
                      width: 90,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  isBad
                      ? 'Pasien perlu ke rumah sakit'
                      : 'Pasien dalam kondisi normal!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Color(0xFF222B45),
                  ),
                ),
                const SizedBox(height: 16),
                // Description
                Text(
                  isBad
                      ? 'Hasil tes menunjukkan adanya gangguan kognitif yang signifikan. Penting untuk segera berkonsultasi dengan profesional medis untuk mendapatkan penanganan lebih lanjut dan rencana perawatan yang sesuai.'
                      : 'Berdasarkan hasil pemeriksaan, pasien tidak memerlukan rujukan ke Puskesmas saat ini. Anda dapat melanjutkan perawatan sesuai dengan rekomendasi yang diberikan.',
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
                      Navigator.of(context).popUntil((route) => route.isFirst);
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
    );
  }
}
