import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/SKILAS/models/skilas_test_entry.dart';
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
              score: isBad ? 0 : 1,
              date: DateTime.now(),
              page1Answers: skilasState.page1Answers,
              page2Answers: skilasState.page2Answers,
              page3Answers: skilasState.page3Answers,
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final skilasState = ref.watch(skilasTestProvider);
    final isBad = skilasState.isAnyAnswerWrong;

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color:
                      isBad
                          ? const Color(0xFFFF8A65).withOpacity(0.1)
                          : const Color(0xFFAFE073).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isBad ? Icons.warning_rounded : Icons.check_circle_rounded,
                  size: 60,
                  color:
                      isBad ? const Color(0xFFFF8A65) : const Color(0xFFAFE073),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isBad ? 'Perlu ke Rumah Sakit' : 'Sehat',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color:
                      isBad ? const Color(0xFFFF8A65) : const Color(0xFFAFE073),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isBad
                    ? 'Pasien menunjukkan tanda-tanda gangguan kognitif'
                    : 'Pasien tidak menunjukkan tanda-tanda gangguan kognitif',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 32),
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
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SKILASHistoryPage(),
                      ),
                      (route) => route.isFirst,
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
      ),
    );
  }
}
