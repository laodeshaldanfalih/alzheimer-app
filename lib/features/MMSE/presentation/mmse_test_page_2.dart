import 'package:flutter/material.dart';
import 'package:project/core/widgets/custom_app_bar_widget.dart';
import 'package:project/features/MMSE/presentation/mmse_test_page_3.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/MMSE/providers/mmse_test_provider.dart';
import 'package:project/core/widgets/test_dropdown_widget.dart';
import 'package:project/core/widgets/test_question_text_widget.dart';
import 'package:project/core/widgets/test_next_button_widget.dart';

class MMSETestPage2 extends ConsumerStatefulWidget {
  const MMSETestPage2({super.key});

  @override
  ConsumerState<MMSETestPage2> createState() => _MMSETestPage2State();
}

class _MMSETestPage2State extends ConsumerState<MMSETestPage2> {
  final List<String> questions = [
    "Sekarang kita berada di mana?",
    "Sekarang kita berada di kota apa?",
    "Sekarang kita berada di provinsi apa?",
    "Sekarang kita berada di negara apa?",
    "Sekarang kita berada di lantai berapa?",
  ];

  final List<String?> answers = List.filled(5, null);
  final List<String> options = ["Benar", "Salah"];

  bool _isPageComplete() {
    return !answers.contains(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarWidget(title: "Mini-Mental State Exam (MMSE)"),
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                "Orientasi 2 (Nilai Max 5)",
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
                      .setOrientationPlaceAnswers(answers);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MMSETestPage3(),
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
