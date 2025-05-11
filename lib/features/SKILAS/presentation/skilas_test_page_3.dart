import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/SKILAS/providers/skilas_test_provider.dart';
import 'package:project/core/widgets/test_dropdown.dart';
import 'package:project/core/widgets/test_question_text.dart';
import 'package:project/core/widgets/test_next_button.dart';
import 'skilas_result_page.dart';

class SKILASPage3 extends ConsumerStatefulWidget {
  const SKILASPage3({super.key});

  @override
  ConsumerState<SKILASPage3> createState() => _SKILASPage3State();
}

class _SKILASPage3State extends ConsumerState<SKILASPage3> {
  final List<String> questions = [
    'Selama dua minggu terakhir, apakah Anda merasa terganggu oleh perasaan sedih, tertekan, atau putus asa?',
    'Selama dua minggu terakhir, apakah Anda merasa terganggu oleh sedikit minat atau kesenangan dalam melakukan sesuatu?',
  ];

  final List<String?> answers = List.filled(2, null);
  final List<String> options = ["Benar", "Salah"];

  bool _isPageComplete() {
    return !answers.contains(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Skrining Lansia Sederhana (SKILAS)",
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
                "Depresi",
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
                        TestQuestionText(text: questions[index]),
                        const SizedBox(height: 8),
                        TestDropdown(
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
              TestNextButton(
                isComplete: _isPageComplete(),
                onPressed: () {
                  ref
                      .read(skilasTestProvider.notifier)
                      .setPage3Answers(answers);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SKILASResultPage(),
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
