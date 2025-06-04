import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/MMSE/providers/mmse_test_provider.dart';
import 'package:project/features/MMSE/providers/mmse_history_provider.dart';
import 'package:project/features/MMSE/models/mmse_history_entry.dart';
import 'package:project/features/MMSE/presentation/mmse_history_page.dart';

class MMSEResultPage extends ConsumerStatefulWidget {
  const MMSEResultPage({super.key});

  @override
  ConsumerState<MMSEResultPage> createState() => _MMSEResultPageState();
}

class _MMSEResultPageState extends ConsumerState<MMSEResultPage> {
  @override
  void initState() {
    super.initState();
    // Save to history after the widget is built
    Future(() {
      final testState = ref.read(mmseTestProvider);
      ref
          .read(mmseHistoryProvider.notifier)
          .addEntry(
            MMSEHistoryEntry(
              score: testState.totalScore,
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
    });
  }

  String _getResultDescription(int score) {
    if (score >= 24) {
      return 'Hasil tes menunjukkan bahwa fungsi kognitif Anda berada dalam kisaran normal. Tidak ada indikasi gangguan kognitif pada tingkat ini. Terus pertahankan gaya hidup sehat untuk mendukung kesehatan otak.';
    } else if (score >= 17) {
      return 'Hasil tes menunjukkan kemungkinan adanya gangguan kognitif ringan. Meskipun tidak pasti, kami sarankan untuk berkonsultasi lebih lanjut dengan profesional medis untuk evaluasi yang lebih mendalam.';
    } else {
      return 'Hasil tes menunjukkan adanya gangguan kognitif yang signifikan. Penting untuk segera berkonsultasi dengan profesional medis untuk mendapatkan penanganan lebih lanjut dan rencana perawatan yang sesuai.';
    }
  }

  String _getResultImage(int score) {
    if (score >= 24) {
      return 'assets/images/good_result.png';
    } else if (score >= 17) {
      return 'assets/images/mid_result.png';
    } else {
      return 'assets/images/bad_result.png';
    }
  }

  Color _getResultColor(int score) {
    if (score >= 24) {
      return const Color(0xFFAFE073);
    } else if (score >= 17) {
      return const Color(0xFFFFD54F);
    } else {
      return const Color(0xFFFF8A65);
    }
  }

  @override
  Widget build(BuildContext context) {
    final testState = ref.watch(mmseTestProvider);
    final score = testState.totalScore;
    final description = _getResultDescription(score);

    return PopScope(
      canPop: false,
      child: Scaffold(
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
                        color: _getResultColor(score),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          _getResultImage(score),
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
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MMSEHistoryPage(),
                            ),
                            (route) => route.isFirst,
                          );},
                        child: const Text(
                          'Lihat Riwayat',
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
      ),
    );
  }
}
