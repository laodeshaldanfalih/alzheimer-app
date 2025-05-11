import 'package:flutter/material.dart';
import 'package:project/features/MMSE/presentation/mmse_result_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/MMSE/providers/mmse_test_provider.dart';
import 'package:project/core/widgets/test_question_text.dart';
import 'package:project/core/widgets/test_next_button.dart';
import 'package:project/core/widgets/test_dropdown.dart';

class MMSETestPage5 extends ConsumerStatefulWidget {
  const MMSETestPage5({super.key});

  @override
  ConsumerState<MMSETestPage5> createState() => _MMSETestPage5State();
}

class _MMSETestPage5State extends ConsumerState<MMSETestPage5> {
  int? bendaScore;
  String? kataAnswer;
  int? instruksiScore;
  String? angkatTanganAnswer;
  String? tulisKalimatAnswer;
  String? tiruGambarAnswer;

  final List<String> options = ["Benar", "Salah"];

  bool _isPageComplete() {
    return bendaScore != null &&
        kataAnswer != null &&
        instruksiScore != null &&
        angkatTanganAnswer != null &&
        tulisKalimatAnswer != null &&
        tiruGambarAnswer != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mini-Mental State Exam (MMSE)",
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
                "Bahasa (Nilai Max 9)",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color(0xFF222B45),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TestQuestionText(text: "Menamai benda (Nilai Max 2):"),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "Jawaban (0-2)",
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE4E4E4),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF2563EB),
                                    width: 1.4,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  setState(() {
                                    bendaScore = int.parse(value);
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TestQuestionText(text: "Mengulang kata (Nilai Max 1):"),
                      const SizedBox(height: 8),
                      TestDropdown(
                        value: kataAnswer,
                        options: options,
                        onChanged: (val) {
                          setState(() {
                            kataAnswer = val;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      TestQuestionText(
                        text: "Mengikuti perintah 3 tahap (Nilai Max 3):",
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "Jawaban (0-3)",
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE4E4E4),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF2563EB),
                                    width: 1.4,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  setState(() {
                                    instruksiScore = int.parse(value);
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TestQuestionText(
                        text: "Membaca dan mengikuti perintah (Nilai Max 1):",
                      ),
                      const SizedBox(height: 8),
                      TestDropdown(
                        value: angkatTanganAnswer,
                        options: options,
                        onChanged: (val) {
                          setState(() {
                            angkatTanganAnswer = val;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      TestQuestionText(text: "Menulis kalimat (Nilai Max 1):"),
                      const SizedBox(height: 8),
                      TestDropdown(
                        value: tulisKalimatAnswer,
                        options: options,
                        onChanged: (val) {
                          setState(() {
                            tulisKalimatAnswer = val;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      TestQuestionText(text: "Meniru gambar (Nilai Max 1):"),
                      const SizedBox(height: 8),
                      TestDropdown(
                        value: tiruGambarAnswer,
                        options: options,
                        onChanged: (val) {
                          setState(() {
                            tiruGambarAnswer = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TestNextButton(
                isComplete: _isPageComplete(),
                onPressed: () {
                  ref
                      .read(mmseTestProvider.notifier)
                      .setLanguageAnswers(
                        bendaScore: bendaScore,
                        kataAnswer: kataAnswer,
                        instruksiScore: instruksiScore,
                        angkatTanganAnswer: angkatTanganAnswer,
                        tulisKalimatAnswer: tulisKalimatAnswer,
                        tiruGambarAnswer: tiruGambarAnswer,
                      );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MMSEResultPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
