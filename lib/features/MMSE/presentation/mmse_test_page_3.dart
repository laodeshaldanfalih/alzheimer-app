import 'package:flutter/material.dart';
import 'package:project/features/MMSE/presentation/mmse_test_page_4.dart';

class MMSETestPage3 extends StatefulWidget {
  const MMSETestPage3({super.key});

  @override
  State<MMSETestPage3> createState() => _MMSETestPage3State();
}

class _MMSETestPage3State extends State<MMSETestPage3> {
  final TextEditingController _correctAnswersController =
      TextEditingController();
  final TextEditingController _repetitionsController = TextEditingController();

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
                      const Text(
                        "Instruksi:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3142),
                        ),
                      ),
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
                    ],
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
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MMSETestPage4(),
                        ),
                      );
                    },
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
