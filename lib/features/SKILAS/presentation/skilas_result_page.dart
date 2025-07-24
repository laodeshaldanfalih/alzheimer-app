import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/SKILAS/models/skilas_test_entry.dart';
import 'package:project/features/SKILAS/presentation/skilas_tab_view_page.dart';
import 'package:project/features/SKILAS/providers/skilas_test_provider.dart';
import 'package:project/features/SKILAS/providers/skilas_history_provider.dart';
import 'skilas_history_page.dart';

class SKILASResultPage extends ConsumerStatefulWidget {
  const SKILASResultPage({super.key});

  @override
  ConsumerState<SKILASResultPage> createState() => _SKILASResultPageState();
}

class _SKILASResultPageState extends ConsumerState<SKILASResultPage> {
  @override
  void initState() {
    super.initState();
    // Save history after the widget is built
    Future.microtask(() {
      final skilasState = ref.read(skilasTestProvider);
      final isBad = skilasState.isAnyAnswerWrong;
      ref
          .read(skilasHistoryProvider.notifier)
          .addEntry(
            SKILASHistoryEntry(
              score: isBad ? 0 : 1, // 0 for bad, 1 for good
              date: DateTime.now(),
              page1Answers: skilasState.page1Answers,
              page2Answers: skilasState.page2Answers,
              page3Answers: skilasState.page3Answers,
            ),
          );
    });
  }

  String _getResultImage(bool isAnyAnswerWrong) {
    return isAnyAnswerWrong
        ? 'assets/images/skilas_bad.png'
        : 'assets/images/skilas_good1.png';
  }

  Color _getResultColor(bool isAnyAnswerWrong) {
    return isAnyAnswerWrong
        ? const Color(0xFFFF8A65).withOpacity(0.1)
        : const Color(0xFFAFE073).withOpacity(0.1);
  }

  @override
  Widget build(BuildContext context) {
    final skilasState = ref.watch(skilasTestProvider);
    final isBad = skilasState.isAnyAnswerWrong;
    final image = _getResultImage(isBad);
    final color = _getResultColor(isBad);

    return PopScope(
      canPop: false,
      child: Scaffold(
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 12,
              ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
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
                          height: 120,
                          width: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    Text(
                      isBad
                          ? 'Perlu Pemeriksaan Lebih ke Instansi Kesehatan'
                          : 'Terindikasi Sehat!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color:
                            isBad
                                ? const Color(0xFFFF8A65)
                                : const Color(0xFFAFE073),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Description
                    Text(
                      isBad
                          ? 'Pasien menunjukkan tanda-tanda gangguan kognitif'
                          : 'Pasien tidak menunjukkan tanda-tanda gangguan kognitif',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    const Text(
                      'Klik tombol di bawah untuk kembali ke halaman riwayat!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2563EB),
                        height: 1.5,
                        fontWeight: FontWeight.w600,
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
                              builder: (context) => const SkilasTabViewPage(),
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
