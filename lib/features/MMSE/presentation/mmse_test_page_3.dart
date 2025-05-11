import 'package:flutter/material.dart';
import 'package:project/features/MMSE/presentation/mmse_test_page_4.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/MMSE/providers/mmse_test_provider.dart';
import 'package:project/core/widgets/test_question_text.dart';
import 'package:project/core/widgets/test_next_button.dart';

class MMSETestPage3 extends ConsumerStatefulWidget {
  const MMSETestPage3({super.key});

  @override
  ConsumerState<MMSETestPage3> createState() => _MMSETestPage3State();
}

class _MMSETestPage3State extends ConsumerState<MMSETestPage3> {
  int? score;
  int repetitions = 0;
  final List<String> words = ["Kursi", "Pintu", "Jendela"];
  final List<bool> rememberedWords = List.filled(3, false);

  bool _isPageComplete() {
    return score != null;
  }

  void _checkAnswers() {
    int correctCount = rememberedWords.where((word) => word).length;
    score = correctCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mini-Mental State Exam (MMSE)",
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
                "Registrasi (Nilai Max 3)",
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
                    TestQuestionText(
                      text:
                          "Saya akan menyebutkan 3 benda. Silakan Anda mengingatnya:",
                    ),
                    const SizedBox(height: 16),
                    ...words.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Text(
                              "${entry.key + 1}. ${entry.value}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF222B45),
                              ),
                            ),
                            const Spacer(),
                            Checkbox(
                              value: rememberedWords[entry.key],
                              onChanged: (val) {
                                setState(() {
                                  rememberedWords[entry.key] = val ?? false;
                                  _checkAnswers();
                                });
                              },
                              activeColor: const Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                    TestQuestionText(
                      text:
                          "Berapa kali pengucapan kata-kata tersebut diulang?",
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed:
                              repetitions > 0
                                  ? () {
                                    setState(() {
                                      repetitions--;
                                    });
                                  }
                                  : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: const Color(0xFF2563EB),
                        ),
                        Text(
                          "$repetitions",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF222B45),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              repetitions++;
                            });
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          color: const Color(0xFF2563EB),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TestNextButton(
                isComplete: _isPageComplete(),
                onPressed: () {
                  ref
                      .read(mmseTestProvider.notifier)
                      .setRegistrationScore(score!, repetitions);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MMSETestPage4(),
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
