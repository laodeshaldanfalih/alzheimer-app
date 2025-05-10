import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:project/features/MMSE/presentation/mmse_test_page_5.dart';
import 'package:provider/provider.dart';
import 'package:project/features/MMSE/data/mmse_test_state.dart';

class MMSETestPage4 extends StatefulWidget {
  const MMSETestPage4({super.key});

  @override
  State<MMSETestPage4> createState() => _MMSETestPage4State();
}

class _MMSETestPage4State extends State<MMSETestPage4> {
  String? attentionAnswer;
  String? recallAnswer;
  final List<String> options = ["0", "1", "2", "3", "4", "5"];
  final List<String> recallOptions = ["0", "1", "2", "3"];

  void _updateScores() {
    final state = Provider.of<MMSETestState>(context, listen: false);

    // Convert answers to scores and save to state
    if (attentionAnswer != null) {
      state.attentionScore = int.parse(attentionAnswer!);
    }
    if (recallAnswer != null) {
      state.recallScore = int.parse(recallAnswer!);
    }
  }

  bool _isPageComplete() {
    return attentionAnswer != null && recallAnswer != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3142)),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Atensi dan Kalkulasi (Nilai max 5)",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInstructionItem(
                        "1. Hitung mundur kelipatan 7 mulai dari 100 dan stop pada angka ke-5. Jawaban: (100, 93, 86, 79, 72)",
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionItem(
                        '2. Alternatifnya, mengeja terbalik sebuah kata (cont: "wahyu", nilai diberi pada huruf yang benar sebelum kesalahan; misalnya uyahw=2 nilai)',
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonHideUnderline(
                        child: DropdownButtonFormField2<String>(
                          isExpanded: true,
                          hint: Text(
                            'Berapa banyak yang benar?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9C9DB9),
                            ),
                          ),
                          items:
                              options
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
                          value: attentionAnswer,
                          onChanged: (value) {
                            setState(() {
                              attentionAnswer = value;
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
                              horizontal: 12,
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
                      const SizedBox(height: 32),
                      const Text(
                        "Mengingat Kembali / Recall\n(Nilai Max 3)",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInstructionItem(
                        "1. Sebutkan 3 buah nama benda yang telah disebutkan pada bagian registrasi",
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonHideUnderline(
                        child: DropdownButtonFormField2<String>(
                          isExpanded: true,
                          hint: Text(
                            'Berapa banyak yang benar?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9C9DB9),
                            ),
                          ),
                          items:
                              recallOptions
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
                          value: recallAnswer,
                          onChanged: (value) {
                            setState(() {
                              recallAnswer = value;
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
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
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
                                builder: (context) => const MMSETestPage5(),
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
            ),
          ],
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
}
