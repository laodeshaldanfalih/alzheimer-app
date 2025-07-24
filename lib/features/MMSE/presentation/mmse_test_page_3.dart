import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:project/features/MMSE/presentation/mmse_test_page_4.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/MMSE/providers/mmse_test_provider.dart';
import 'package:project/core/widgets/test_question_text_widget.dart';
import 'package:project/core/widgets/test_next_button_widget.dart';
import 'package:project/core/widgets/custom_app_bar_widget.dart';

class MMSETestPage3 extends ConsumerStatefulWidget {
  const MMSETestPage3({super.key});

  @override
  ConsumerState<MMSETestPage3> createState() => _MMSETestPage3State();
}

class _MMSETestPage3State extends ConsumerState<MMSETestPage3> {
  final TextEditingController _correctAnswersController =
      TextEditingController();
  final TextEditingController _repetitionsController = TextEditingController();
  final List<String> finalScore = ["0", "1", "2", "3"];
  String? finalScoreAnswer;

  void _updateScores() {
    if (_correctAnswersController.text.isNotEmpty && finalScoreAnswer != null) {
      ref
          .read(mmseTestProvider.notifier)
          .setRegistrationScore(
            int.parse(_correctAnswersController.text),
            int.parse(_repetitionsController.text),
            int.parse(finalScoreAnswer!),
          );
    }
  }

  bool _isPageComplete() {
  return _correctAnswersController.text.isNotEmpty && finalScoreAnswer != null;
  }

  @override
  void dispose() {
    _correctAnswersController.dispose();
    _repetitionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Close keyboard
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: const CustomAppBarWidget(
          title: "Mini-Mental State Exam (MMSE)",
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Registrasi (Nilai max 3)",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const TestQuestionTextWidget(text: "Instruksi:"),
                      const SizedBox(height: 16),
                      _buildInstructionItem(
                        "1. Sebutkan 3 buah nama benda (contoh: jeruk, uang, mawar), tiap benda disebutkan pelan selama jeda 1 detik.",
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionItem(
                        "2. Pasien disuruh mengulangi ketiga nama benda tadi.",
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionItem(
                        "3. Nilai 1 untuk tiap nama benda yang benar. Ulangi sampai pasien dapat menyebutkan dengan benar dan catat jumlah pengulangan.",
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionItem(
                        "4. Pertanyaan ini akan ditanyakan kembali setelah bagian Atensi dan Kalkulasi.",
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _correctAnswersController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration(
                          "Banyak nama benda yang benar?",
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _repetitionsController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration(
                          "Banyak jumlah pengulangan?",
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInstructionItem(
                        "Pemberian nilai final berdasarkan respon pasien:",
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonHideUnderline(
                        child: DropdownButtonFormField2<String>(
                          isExpanded: true,
                          hint: const Text(
                            'Jumlah nilai total (max 3)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9C9DB9),
                            ),
                          ),
                          items:
                              finalScore
                                  .map(
                                    (item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF2D3142),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          value: finalScoreAnswer,
                          onChanged: (value) {
                            setState(() {
                              finalScoreAnswer = value;
                            });
                          },
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
                            offset: const Offset(0, -4),
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF8A94A6),
                            ),
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFE4E4E4),
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
                        ),
                      ),
                    ],
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
                        builder: (context) => const MMSETestPage4(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF2D3142),
        height: 1.5,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9C9DB9), fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE4E4E4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.4),
      ),
    );
  }
}
