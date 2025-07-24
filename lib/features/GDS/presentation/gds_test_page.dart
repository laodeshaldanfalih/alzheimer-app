import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/core/widgets/custom_app_bar_widget.dart';
import 'package:project/core/widgets/test_dropdown_widget_gds.dart';
import 'package:project/core/widgets/test_question_text_widget.dart';
import 'package:project/core/widgets/test_next_button_widget.dart';
import 'package:project/features/GDS/providers/gds_test_provider.dart';
import 'package:project/features/GDS/presentation/gds_result_page.dart';

class GDSTestPage extends ConsumerStatefulWidget {
  const GDSTestPage({super.key});

  @override
  ConsumerState<GDSTestPage> createState() => _GDSTestPageState();
}

class _GDSTestPageState extends ConsumerState<GDSTestPage> {
  final List<String> questions = [
    "1. Apakah Anda pada dasarnya puas dengan hidup Anda?",
    "2. Apakah Anda telah melepaskan banyak kegiatan dan minat Anda?",
    "3. Apakah Anda merasa hidup Anda kosong?",
    "4. Apakah Anda sering merasa bosan?",
    "5. Apakah Anda dalam suasana hati yang baik hampir sepanjang waktu?",
    "6. Apakah Anda takut bahwa sesuatu yang buruk akan terjadi pada Anda?",
    "7. Apakah Anda merasa bahagia hampir sepanjang waktu?",
    "8. Apakah Anda sering merasa tidak berdaya?",
    "9. Apakah Anda lebih suka tinggal di rumah daripada pergi keluar dan melakukan hal-hal baru?",
    "10. Apakah Anda merasa memiliki lebih banyak masalah dengan ingatan daripada kebanyakan orang?",
    "11. Apakah Anda berpikir bahwa sekarang ini adalah waktu yang indah untuk hidup?",
    "12. Apakah Anda merasa tidak berharga seperti sekarang ini?",
    "13. Apakah Anda merasa penuh energi?",
    "14. Apakah Anda merasa situasi Anda tidak ada harapan?",
    "15. Apakah Anda berpikir bahwa kebanyakan orang lebih baik daripada Anda?",
  ];

  final List<String?> answers = List.filled(15, null);
  final List<String> options = ["Ya", "Tidak"];

  bool _isPageComplete() {
    return !answers.contains(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarWidget(title: "Geriatric Depression Scale (GDS)"),
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                "Pertanyaan GDS (Nilai Max 15)",
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
                        TestDropdownWidgetGds(
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
                  ref.read(gdsTestProvider.notifier).setAnswers(answers);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GDSResultPage(),
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
