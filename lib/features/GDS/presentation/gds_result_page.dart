import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/GDS/providers/gds_test_provider.dart';
import 'package:project/features/GDS/providers/gds_history_provider.dart';
import 'package:project/features/GDS/models/gds_history_entry.dart';
import 'package:project/features/GDS/presentation/gds_history_page.dart';

class GDSResultPage extends ConsumerStatefulWidget {
  const GDSResultPage({super.key});

  @override
  ConsumerState<GDSResultPage> createState() => _GDSResultPageState();
}

class _GDSResultPageState extends ConsumerState<GDSResultPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final state = ref.read(gdsTestProvider);
      final score = state.totalScore ?? 0;
      final isDepressed = score >= 5;
      final answers = state.answers.map((e) => e ?? '-').toList();
      ref
          .read(gdsHistoryProvider.notifier)
          .addEntry(
            GDSHistoryEntry(
              date: DateTime.now(),
              score: score,
              isDepressed: isDepressed,
              answers: answers,
            ),
          );
    });
  }

  String _getResultTitle(int score) {
    if (score < 5) {
      return 'Pasien mendapatkan skor <5!';
    } else {
      return 'Pasien mendapatkan skor >5!';
    }
  }

  String _getResultDescription(int score) {
    if (score < 5) {
      return 'Hasil tes menunjukkan bahwa kesehatan mental depresi Anda berada dalam kisaran normal. Tidak ada indikasi gangguan depresi yang signifikan pada tingkat ini. Terus pertahankan gaya hidup sehat untuk mendukung kesehatan.';
    } else {
      return 'Hasil tes menunjukkan kemungkinan adanya gejala depresi. Meskipun tidak pasti, kami sarankan untuk berkonsultasi lebih lanjut dengan profesional medis untuk evaluasi yang lebih mendalam.';
    }
  }

  String _getResultImage(int score) {
    if (score < 5) {
      return 'assets/images/gds_happy.png';
    } else {
      return 'assets/images/gds_sad.png';
    }
  }

  Color _getResultColor(int score) {
    if (score < 5) {
      return const Color(0xFFB2E59E); // green
    } else {
      return const Color(0xFFFFE082); // yellow
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gdsTestProvider);
    final score = state.totalScore ?? 0;
    final title = _getResultTitle(score);
    final description = _getResultDescription(score);
    final image = _getResultImage(score);
    final color = _getResultColor(score);

    return PopScope(
      canPop: false,

      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: false,
          title: const Text(
            'Geriatric Depression Scale (GDS)',
            style: TextStyle(
              color: Color(0xFF222B45),
              fontWeight: FontWeight.w600,
              fontSize: 18,
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
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          image,
                          height: 80,
                          width: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    Text(
                      title,
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
                              builder: (context) => const GDSHistoryPage(),
                            ),
                            (route) => route.isFirst,
                          );
                        },
                        child: const Text(
                          'Kembali ke Halaman Utama',
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
            ),
          ),
        ),
      ),
    );
  }
}
