import 'package:flutter/material.dart';
import 'package:project/core/widgets/custom_app_bar_widget.dart';
import 'package:project/features/MMSE/presentation/mmse_test_page_2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/MMSE/providers/mmse_test_provider.dart';
import 'package:project/core/widgets/test_dropdown_widget.dart';
import 'package:project/core/widgets/test_question_text_widget.dart';
import 'package:project/core/widgets/test_next_button_widget.dart';

class MMSETestPage1 extends ConsumerStatefulWidget {
  const MMSETestPage1({super.key});

  @override
  ConsumerState<MMSETestPage1> createState() => _MMSETestPage1State();
}

class _MMSETestPage1State extends ConsumerState<MMSETestPage1> {
  final List<String> questions = [
    "Sekarang tahun berapa?",
    "Sekarang musim apa?",
    "Sekarang bulan apa?",
    "Sekarang tanggal berapa?",
    "Sekarang hari apa?",
  ];

  final List<String?> answers = List.filled(5, null);
  final List<String> options = ["Benar", "Salah"];

  bool _isPageComplete() {
    return !answers.contains(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarWidget(
        title: "Mini-Mental State Examination (MMSE)",
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
                "Orientasi 1 (Nilai Max 5)",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color(0xFF222B45),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: questions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TestQuestionTextWidget(text: questions[index]),
                        const SizedBox(height: 8),
                        TestDropdownWidget(
                          value: answers[index],
                          options: options,
                          onChanged: (val) {
                            setState(() {
                              answers[index] = val;
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              TestNextButtonWidget(
                isComplete: _isPageComplete(),
                onPressed: () {
                  ref
                      .read(mmseTestProvider.notifier)
                      .setOrientationTimeAnswers(answers);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MMSETestPage2(),
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
