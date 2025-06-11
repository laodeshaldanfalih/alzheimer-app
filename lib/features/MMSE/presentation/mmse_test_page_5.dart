import 'package:flutter/material.dart';
import 'package:project/core/widgets/test_dropdown_widget_mmse.dart';
import 'package:project/features/MMSE/presentation/mmse_result_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/MMSE/providers/mmse_test_provider.dart';
import 'package:project/core/widgets/test_question_text_widget.dart';
import 'package:project/core/widgets/test_dropdown_widget.dart';
import 'package:project/core/widgets/test_next_button_widget.dart';
import 'package:project/core/widgets/custom_app_bar_widget.dart';

class MMSETestPage5 extends ConsumerStatefulWidget {
  const MMSETestPage5({super.key});

  @override
  ConsumerState<MMSETestPage5> createState() => _MMSETestPage5State();
}

class _MMSETestPage5State extends ConsumerState<MMSETestPage5> {
  String? bendaAnswer;
  String? kataAnswer;
  String? instruksiAnswer;
  String? angkatTanganAnswer;
  String? tulisKalimatAnswer;
  String? tiruGambarAnswer;

  final List<String> benarSalahOptions = ["Benar", "Salah"];
  final List<String> jumlahBenarOptions = ["0", "1", "2"];
  final List<String> jumlahBenarOptions3 = ["0", "1", "2", "3"];

  void _updateScores() {
    ref
        .read(mmseTestProvider.notifier)
        .setLanguageScores(
          bendaAnswer != null ? int.parse(bendaAnswer!) : null,
          kataAnswer,
          instruksiAnswer != null ? int.parse(instruksiAnswer!) : null,
          angkatTanganAnswer,
          tulisKalimatAnswer,
          tiruGambarAnswer,
        );
  }

  bool _isPageComplete() {
    return bendaAnswer != null &&
        kataAnswer != null &&
        instruksiAnswer != null &&
        angkatTanganAnswer != null &&
        tulisKalimatAnswer != null &&
        tiruGambarAnswer != null;
  }

  void _showImageDialog1() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 60,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                _buildImageBlock("Gambar 1", 'assets/images/pensil.png'),
                const SizedBox(height: 20),
                _buildImageBlock("Gambar 2", 'assets/images/arloji.png'),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImageDialog2() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 60,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                _buildImageBlock(null, 'assets/images/tiru_gambar.png'),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageBlock(String? title, String assetPath) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 8),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: screenHeight * 0.30,
            width: double.infinity,
            child: Image.asset(assetPath, fit: BoxFit.cover),
          ),
        ),
      ],
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarWidget(title: "Mini-Mental State Exam (MMSE)"),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Bahasa",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 1. Sebutkan nama benda yang muncul
                      const TestQuestionTextWidget(
                        text: "1. Sebutkan nama benda yang muncul.",
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _showImageDialog1,
                          child: const Text(
                            "Tampilkan gambar",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TestDropdownWidgetMmse(
                        value: bendaAnswer,
                        options: jumlahBenarOptions,
                        onChanged: (value) {
                          setState(() {
                            bendaAnswer = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      // 2. Ulangi rangkaian kata
                      const TestQuestionTextWidget(
                        text:
                            '2. Ulangi rangkaian kata (cont: "tanpa kalau dan atau tetapi")',
                      ),
                      const SizedBox(height: 12),
                      TestDropdownWidget(
                        value: kataAnswer,
                        options: benarSalahOptions,
                        onChanged: (value) {
                          setState(() {
                            kataAnswer = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      // 3. Instruksikan pasien
                      const TestQuestionTextWidget(
                        text:
                            '3. Instruksikan pasien "Ambil kertas ini dengan tangan kanan, lipatlah menjadi dua dan letakkan di lantai".',
                      ),
                      const SizedBox(height: 12),
                      TestDropdownWidgetMmse(
                        value: instruksiAnswer,
                        options: jumlahBenarOptions3,
                        onChanged: (value) {
                          setState(() {
                            instruksiAnswer = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      // 4. Instruksikan pasien "Angkatlah tangan kiri anda".
                      const TestQuestionTextWidget(
                        text:
                            '4. Instruksikan pasien "Angkatlah tangan kiri anda".',
                      ),
                      const SizedBox(height: 12),
                      TestDropdownWidget(
                        value: angkatTanganAnswer,
                        options: benarSalahOptions,
                        onChanged: (value) {
                          setState(() {
                            angkatTanganAnswer = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      // 5. Instruksikan pasien untuk menulis sebuah kalimat
                      const TestQuestionTextWidget(
                        text:
                            '5. Instruksikan pasien untuk menulis sebuah kalimat (minimal terdiri dari subject + predikat).',
                      ),
                      const SizedBox(height: 12),
                      TestDropdownWidget(
                        value: tulisKalimatAnswer,
                        options: benarSalahOptions,
                        onChanged: (value) {
                          setState(() {
                            tulisKalimatAnswer = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      // 6. Instruksikan pasien untuk meniru gambar ini.
                      const TestQuestionTextWidget(
                        text: '6. Instruksikan pasien untuk meniru gambar ini.',
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _showImageDialog2,
                          child: const Text(
                            "Tampilkan gambar",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TestDropdownWidget(
                        value: tiruGambarAnswer,
                        options: benarSalahOptions,
                        onChanged: (value) {
                          setState(() {
                            tiruGambarAnswer = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TestNextButtonWidget(
                isComplete: _isPageComplete(),
                onPressed: () {
                  _updateScores();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MMSEResultPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
