import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/MMSE/providers/mmse_test_provider.dart';
import 'package:project/features/MMSE/providers/mmse_history_provider.dart';
import 'package:project/features/MMSE/models/mmse_history_entry.dart';
import 'package:project/features/MMSE/presentation/mmse_history_page.dart';

class MMSEResultPage extends ConsumerWidget {
  const MMSEResultPage({super.key});

  String _getResultDescription(int score) {
    if (score >= 24) {
      return 'Hasil tes menunjukkan bahwa fungsi kognitif Anda berada dalam kisaran normal. Tidak ada indikasi gangguan kognitif pada tingkat ini. Terus pertahankan gaya hidup sehat untuk mendukung kesehatan otak.';
    } else if (score >= 17) {
      return 'Hasil tes menunjukkan kemungkinan adanya gangguan kognitif ringan. Meskipun tidak pasti, kami sarankan untuk berkonsultasi lebih lanjut dengan profesional medis untuk evaluasi yang lebih mendalam.';
    } else {
      return 'Hasil tes menunjukkan adanya gangguan kognitif yang signifikan. Penting untuk segera berkonsultasi dengan profesional medis untuk mendapatkan penanganan lebih lanjut dan rencana perawatan yang sesuai.';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testState = ref.watch(mmseTestProvider);
    final score = testState.totalScore;
    final description = _getResultDescription(score);

    // Save to history
    ref
        .read(mmseHistoryProvider.notifier)
        .addEntry(
          MMSEHistoryEntry(
            score: score,
            date: DateTime.now(),
            orientationTimeAnswers: testState.orientationTimeAnswers,
            orientationPlaceAnswers: testState.orientationPlaceAnswers,
            registrationScore: testState.registrationScore,
            registrationRepetitions: testState.registrationRepetitions,
            attentionScore: testState.attentionScore,
            recallScore: testState.recallScore,
            bendaScore: testState.bendaScore,
            kataAnswer: testState.kataAnswer,
            instruksiScore: testState.instruksiScore,
            angkatTanganAnswer: testState.angkatTanganAnswer,
            tulisKalimatAnswer: testState.tulisKalimatAnswer,
            tiruGambarAnswer: testState.tiruGambarAnswer,
          ),
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Hasil MMSE",
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF2D3142)),
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
                "Hasil Test",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color(0xFF222B45),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
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
                          const Text(
                            "Total Skor",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF8A94A6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$score",
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF222B45),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Interpretasi",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF8A94A6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF222B45),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MMSEHistoryPage(),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
