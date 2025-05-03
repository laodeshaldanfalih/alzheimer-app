import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:project/features/MMSE/models/mmse_history_entry.dart';
import 'package:project/features/MMSE/presentation/result_page.dart';
import 'package:provider/provider.dart';
import 'package:project/features/MMSE/data/mmse_test_state.dart';
import 'package:project/features/MMSE/presentation/mmse_history_page.dart';

class MMSETestPage5 extends StatefulWidget {
  const MMSETestPage5({super.key});

  @override
  State<MMSETestPage5> createState() => _MMSETestPage5State();
}

class _MMSETestPage5State extends State<MMSETestPage5> {
  String? bendaAnswer;
  String? kataAnswer;
  String? instruksiAnswer;
  String? angkatTanganAnswer;
  String? tulisKalimatAnswer;
  String? tiruGambarAnswer;

  final List<String> benarSalahOptions = ["Benar", "Salah"];
  final List<String> jumlahBenarOptions = ["0", "1", "2"];
  final List<String> jumlahBenarOptions3 = ["0", "1", "2", "3"];

  void _updateScores() {
    final state = Provider.of<MMSETestState>(context, listen: false);

    // Convert answers to scores
    state.bendaScore = bendaAnswer != null ? int.parse(bendaAnswer!) : null;
    state.kataScore =
        kataAnswer == "Benar" ? 1 : (kataAnswer == "Salah" ? 0 : null);
    state.instruksiScore =
        instruksiAnswer != null ? int.parse(instruksiAnswer!) : null;
    state.angkatTanganScore =
        angkatTanganAnswer == "Benar"
            ? 1
            : (angkatTanganAnswer == "Salah" ? 0 : null);
    state.tulisKalimatScore =
        tulisKalimatAnswer == "Benar"
            ? 1
            : (tulisKalimatAnswer == "Salah" ? 0 : null);
    state.tiruGambarScore =
        tiruGambarAnswer == "Benar"
            ? 1
            : (tiruGambarAnswer == "Salah" ? 0 : null);
  }

  bool _isPageComplete() {
    return bendaAnswer != null &&
        kataAnswer != null &&
        instruksiAnswer != null &&
        angkatTanganAnswer != null &&
        tulisKalimatAnswer != null &&
        tiruGambarAnswer != null;
  }

  void _showImageDialog1() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 60,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                _buildImageBlock("Gambar 1", 'assets/images/pensil.png'),
                const SizedBox(height: 20),
                _buildImageBlock("Gambar 2", 'assets/images/arloji.png'),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImageDialog2() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 60,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                _buildImageBlock(null, 'assets/images/tiru_gambar.png'),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageBlock(String? title, String assetPath) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 8),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: screenHeight * 0.30,
            width: double.infinity,
            child: Image.asset(assetPath, fit: BoxFit.cover),
          ),
        ),
      ],
    );
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
                        "Bahasa",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 1. Sebutkan nama benda yang muncul
                      const Text(
                        "1. Sebutkan nama benda yang muncul.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _showImageDialog1,
                          child: const Text(
                            "Tampilkan gambar",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonHideUnderline(
                        child: DropdownButtonFormField2<String>(
                          isExpanded: true,
                          hint: const Text(
                            'Berapa banyak yang benar?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9C9DB9),
                            ),
                          ),
                          items:
                              jumlahBenarOptions
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
                          value: bendaAnswer,
                          onChanged: (value) {
                            setState(() {
                              bendaAnswer = value;
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
                      const SizedBox(height: 28),
                      // 2. Ulangi rangkaian kata
                      const Text(
                        '2. Ulangi rangkaian kata (cont: "tanpa kalau dan atau tetapi")',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonHideUnderline(
                        child: DropdownButtonFormField2<String>(
                          isExpanded: true,
                          hint: const Text(
                            'Benar / Salah',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9C9DB9),
                            ),
                          ),
                          items:
                              benarSalahOptions
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
                          value: kataAnswer,
                          onChanged: (value) {
                            setState(() {
                              kataAnswer = value;
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
                      const SizedBox(height: 28),
                      // 3. Instruksikan pasien
                      const Text(
                        '3. Instruksikan pasien "Ambil kertas ini dengan tangan kanan, lipatlah menjadi dua dan letakkan di lantai".',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonHideUnderline(
                        child: DropdownButtonFormField2<String>(
                          isExpanded: true,
                          hint: const Text(
                            'Berapa banyak yang benar?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9C9DB9),
                            ),
                          ),
                          items:
                              jumlahBenarOptions3
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
                          value: instruksiAnswer,
                          onChanged: (value) {
                            setState(() {
                              instruksiAnswer = value;
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
                      const SizedBox(height: 28),
                      // 4. Instruksikan pasien "Angkatlah tangan kiri anda".
                      const Text(
                        '4. Instruksikan pasien "Angkatlah tangan kiri anda".',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonHideUnderline(
                        child: DropdownButtonFormField2<String>(
                          isExpanded: true,
                          hint: const Text(
                            'Benar / Salah',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9C9DB9),
                            ),
                          ),
                          items:
                              benarSalahOptions
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
                          value: angkatTanganAnswer,
                          onChanged: (value) {
                            setState(() {
                              angkatTanganAnswer = value;
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
                      const SizedBox(height: 28),
                      // 5. Instruksikan pasien untuk menulis sebuah kalimat (minimal terdiri dari subject + predikat).
                      const Text(
                        '5. Instruksikan pasien untuk menulis sebuah kalimat (minimal terdiri dari subject + predikat).',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonHideUnderline(
                        child: DropdownButtonFormField2<String>(
                          isExpanded: true,
                          hint: const Text(
                            'Benar / Salah',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9C9DB9),
                            ),
                          ),
                          items:
                              benarSalahOptions
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
                          value: tulisKalimatAnswer,
                          onChanged: (value) {
                            setState(() {
                              tulisKalimatAnswer = value;
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
                      const SizedBox(height: 28),
                      // 6. Instruksikan pasien untuk meniru gambar ini.
                      const Text(
                        '6. Instruksikan pasien untuk meniru gambar ini.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _showImageDialog2,
                          child: const Text(
                            "Tampilkan gambar",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonHideUnderline(
                        child: DropdownButtonFormField2<String>(
                          isExpanded: true,
                          hint: const Text(
                            'Benar / Salah',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9C9DB9),
                            ),
                          ),
                          items:
                              benarSalahOptions
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
                          value: tiruGambarAnswer,
                          onChanged: (value) {
                            setState(() {
                              tiruGambarAnswer = value;
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
                          ? () async {
                            _updateScores();
                            final state = Provider.of<MMSETestState>(
                              context,
                              listen: false,
                            );
                            // Inject: Save to history
                            final historyProvider = MMSEHistoryProvider();
                            await historyProvider.loadHistory();
                            await historyProvider.addEntry(
                              MMSEHistoryEntry(
                                score: state.totalScore,
                                date: DateTime.now(),
                              ),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => MMSEResultPage(
                                      score: state.totalScore,
                                      description: _getResultDescription(
                                        state.totalScore,
                                      ),
                                    ),
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

  String _getResultDescription(int score) {
    if (score >= 24) {
      return 'Hasil tes menunjukkan bahwa fungsi kognitif Anda berada dalam kisaran normal. Tidak ada indikasi gangguan kognitif pada tingkat ini. Terus pertahankan gaya hidup sehat untuk mendukung kesehatan otak.';
    } else if (score >= 17) {
      return 'Hasil tes menunjukkan kemungkinan adanya gangguan kognitif ringan. Meskipun tidak pasti, kami sarankan untuk berkonsultasi lebih lanjut dengan profesional medis untuk evaluasi yang lebih mendalam.';
    } else {
      return 'Hasil tes menunjukkan adanya gangguan kognitif yang signifikan. Penting untuk segera berkonsultasi dengan profesional medis untuk mendapatkan penanganan lebih lanjut dan rencana perawatan yang sesuai.';
    }
  }
}
