import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/SKILAS/presentation/skilas_test_page_2.dart';
import 'package:project/features/SKILAS/providers/skilas_test_provider.dart';
import 'package:project/core/widgets/test_dropdown.dart';
import 'package:project/core/widgets/test_question_text.dart';
import 'package:project/core/widgets/test_next_button.dart';

class SKILASPage1 extends ConsumerStatefulWidget {
  const SKILASPage1({super.key});

  @override
  ConsumerState<SKILASPage1> createState() => _SKILASPage1State();
}

class _SKILASPage1State extends ConsumerState<SKILASPage1> {
  final List<String> questions = [
    "Instruksikan pasien untuk mengingat tiga kata (cont: jeruk, uang, dan mawar).",
    "Sekarang tanggal berapa?",
    "Dimana anda berada sekarang?",
    "Instruksikan pasien untuk mengulangi 3 kata di awal.",
  ];

  final List<String?> answers = List.filled(4, null);
  final List<String> options = ["Benar", "Salah"];

  bool _isPageComplete() {
    return !answers.contains(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
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
                "Penurunan Kognitif",
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
                      .setPage1Answers(answers);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SKILASPage2(),
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
