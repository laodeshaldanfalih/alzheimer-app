import 'package:flutter/material.dart';
import 'package:project/features/MMSE/presentation/mmse_test_page_5.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/MMSE/providers/mmse_test_provider.dart';
import 'package:project/core/widgets/test_question_text.dart';
import 'package:project/core/widgets/test_next_button.dart';

class MMSETestPage4 extends ConsumerStatefulWidget {
  const MMSETestPage4({super.key});

  @override
  ConsumerState<MMSETestPage4> createState() => _MMSETestPage4State();
}

class _MMSETestPage4State extends ConsumerState<MMSETestPage4> {
  int? attentionScore;
  int? recallScore;
  final List<String> words = ["Kursi", "Pintu", "Jendela"];
  final List<bool> rememberedWords = List.filled(3, false);

  bool _isPageComplete() {
    return attentionScore != null && recallScore != null;
  }

  void _checkRecallAnswers() {
    int correctCount = rememberedWords.where((word) => word).length;
    recallScore = correctCount;
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
                "Atensi dan Kalkulasi (Nilai Max 5)",
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
                      TestQuestionText(
                        text: "Hitung mundur dari 100 dengan pengurangan 7:",
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "Jawaban (0-5)",
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
                                    attentionScore = int.parse(value);
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      TestQuestionText(
                        text: "Sebutkan kembali 3 benda yang tadi disebutkan:",
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
                                    _checkRecallAnswers();
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
                      .setAttentionAndRecallScore(
                        attentionScore!,
                        recallScore!,
                      );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MMSETestPage5(),
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
