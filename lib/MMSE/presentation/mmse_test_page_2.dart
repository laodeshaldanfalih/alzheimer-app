import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:project/MMSE/data/mmse_test_state.dart';
import 'package:project/MMSE/presentation/mmse_test_page_3.dart';
import 'package:provider/provider.dart';

class MMSETestPage2 extends StatefulWidget {
  const MMSETestPage2({super.key});

  @override
  State<MMSETestPage2> createState() => _MMSETestPage2State();
}

class _MMSETestPage2State extends State<MMSETestPage2> {
  final List<String> questions = [
    "Kita ada di negara mana?",
    "Kita ada di provinsi mana?",
    "Kita ada di kota mana?",
    "Kita ada di rumah sakit apa?",
    "kita ada di kamar/lantai berapa?",
  ];

  final List<String?> answers = List.filled(5, null);
  final List<String> options = ["Benar", "Salah"];

  void _updateScores() {
    final state = Provider.of<MMSETestState>(context, listen: false);

    // Calculate score for orientation place (max 5 points)
    int score = 0;
    for (String? answer in answers) {
      if (answer == "Benar") {
        score++;
      }
    }
    state.orientationPlaceScore = score;
  }

  bool _isPageComplete() {
    return !answers.contains(null);
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
                        Text(
                          questions[index],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Color(0xFF222B45),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonHideUnderline(
                          child: DropdownButtonFormField2<String>(
                            hint: Expanded(
                              child: Text(
                                'Benar / Salah',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            isExpanded: true,
                            value: answers[index],
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintStyle: TextStyle(
                                color: Color(0xFFB0B8C1),
                                fontSize: 14,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE0E6ED),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2563EB),
                                  width: 1.4,
                                ),
                              ),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                            iconStyleData: const IconStyleData(
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF8A94A6),
                              ),
                            ),
                            items:
                                options
                                    .map(
                                      (opt) => DropdownMenuItem<String>(
                                        value: opt,

                                        child: Text(
                                          opt,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF1F2937),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (val) {
                              setState(() {
                                answers[index] = val;
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isPageComplete()
                            ? const Color(0xFF2563EB)
                            : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed:
                      _isPageComplete()
                          ? () {
                            _updateScores();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MMSETestPage3(),
                              ),
                            );
                          }
                          : null,
                  child: const Text(
                    "Selanjutnya",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
