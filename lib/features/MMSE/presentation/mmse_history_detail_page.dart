import 'package:flutter/material.dart';
import 'package:project/features/MMSE/models/mmse_history_entry.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class MMSEHistoryDetailPage extends StatelessWidget {
  final MMSEHistoryEntry entry;

  const MMSEHistoryDetailPage({super.key, required this.entry});

  Future<Map<String, String>> _getProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('profile_name') ?? '-',
      'age': prefs.getString('profile_age') ?? '-',
      'gender': prefs.getString('profile_gender') ?? '-',
      'birthdate': prefs.getString('profile_birthdate') ?? '-',
      'imagePath': prefs.getString('profile_image_path') ?? '',
    };
  }

  Future<void> _generateAndSharePDF() async {
    final pdf = pw.Document();
    final profileData = await _getProfileData();
    File? profileImage;
    if (profileData['imagePath']!.isNotEmpty) {
      profileImage = File(profileData['imagePath']!);
    }

    // First page with profile info and score
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  'Hasil Test MMSE',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Profile Information
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(10),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Informasi Pasien',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    if (profileImage != null && profileImage.existsSync())
                      pw.Center(
                        child: pw.Image(
                          pw.MemoryImage(profileImage.readAsBytesSync()),
                          width: 100,
                          height: 100,
                        ),
                      ),
                    pw.SizedBox(height: 10),
                    _buildProfileInfoRow('Nama', profileData['name']!),
                    _buildProfileInfoRow('Umur', profileData['age']!),
                    _buildProfileInfoRow(
                      'Gender',
                      profileData['gender'] == 'Male'
                          ? 'Laki-laki'
                          : 'Perempuan',
                    ),
                    _buildProfileInfoRow(
                      'Tanggal Lahir',
                      profileData['birthdate'] != '-'
                          ? DateFormat(
                            'dd MMMM yyyy',
                          ).format(DateTime.parse(profileData['birthdate']!))
                          : '-',
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Score and Date
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(10),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Skor Test: ${entry.score}',
                      style: const pw.TextStyle(fontSize: 18),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Tanggal: ${DateFormat('dd MMMM yyyy').format(entry.date)}',
                      style: const pw.TextStyle(fontSize: 16),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Status: ${entry.score >= 24
                          ? 'Normal'
                          : entry.score >= 18
                          ? 'Ringan'
                          : 'Berat'}',
                      style: const pw.TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Second page with first part of test results
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Detail Hasil Test (1/2)',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),

              // Test Results - Part 1
              _buildSectionPDF('Orientasi Waktu', [
                _buildQuestionAnswerPDF(
                  "Sekarang tahun apa?",
                  entry.orientationTimeAnswers[0],
                ),
                _buildQuestionAnswerPDF(
                  "Sekarang musim apa?",
                  entry.orientationTimeAnswers[1],
                ),
                _buildQuestionAnswerPDF(
                  "Sekarang bulan apa?",
                  entry.orientationTimeAnswers[2],
                ),
                _buildQuestionAnswerPDF(
                  "Sekarang tanggal apa?",
                  entry.orientationTimeAnswers[3],
                ),
                _buildQuestionAnswerPDF(
                  "Sekarang hari apa?",
                  entry.orientationTimeAnswers[4],
                ),
              ]),
              pw.SizedBox(height: 20),

              _buildSectionPDF('Orientasi Tempat', [
                _buildQuestionAnswerPDF(
                  "Kita ada di negara mana?",
                  entry.orientationPlaceAnswers[0],
                ),
                _buildQuestionAnswerPDF(
                  "Kita ada di provinsi mana?",
                  entry.orientationPlaceAnswers[1],
                ),
                _buildQuestionAnswerPDF(
                  "Kita ada di kota mana?",
                  entry.orientationPlaceAnswers[2],
                ),
                _buildQuestionAnswerPDF(
                  "Kita ada di rumah sakit apa?",
                  entry.orientationPlaceAnswers[3],
                ),
                _buildQuestionAnswerPDF(
                  "Kita ada di kamar/lantai berapa?",
                  entry.orientationPlaceAnswers[4],
                ),
              ]),
              pw.SizedBox(height: 20),

              _buildSectionPDF('Registrasi', [
                _buildQuestionAnswerPDF(
                  "Banyak nama benda yang benar",
                  "${entry.registrationScore}",
                ),
                _buildQuestionAnswerPDF(
                  "Banyak jumlah pengulangan",
                  "${entry.registrationRepetitions}",
                ),
              ]),
              pw.SizedBox(height: 20),

              _buildSectionPDF('Atensi dan Kalkulasi', [
                _buildQuestionAnswerPDF(
                  "Hitung mundur kelipatan 7",
                  "${entry.attentionScore}",
                ),
                _buildQuestionAnswerPDF(
                  "Mengingat kembali nama benda",
                  "${entry.recallScore}",
                ),
              ]),
            ],
          );
        },
      ),
    );

    // Third page with final part of test results
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Detail Hasil Test (2/2)',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),

              // Test Results - Part 2
              _buildSectionPDF('Bahasa', [
                _buildQuestionAnswerPDF(
                  "Sebutkan nama benda yang muncul",
                  "${entry.bendaScore}",
                ),
                _buildQuestionAnswerPDF(
                  "Ulangi rangkaian kata",
                  entry.kataAnswer,
                ),
                _buildQuestionAnswerPDF(
                  "Instruksi 3 langkah",
                  "${entry.instruksiScore}",
                ),
                _buildQuestionAnswerPDF(
                  "Angkat tangan kiri",
                  entry.angkatTanganAnswer,
                ),
                _buildQuestionAnswerPDF(
                  "Tulis kalimat",
                  entry.tulisKalimatAnswer,
                ),
                _buildQuestionAnswerPDF("Tiru gambar", entry.tiruGambarAnswer),
              ]),
            ],
          );
        },
      ),
    );

    // Save PDF
    final output = await getTemporaryDirectory();
    final file = File(
      '${output.path}/mmse_result_${entry.date.millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    // Share PDF
    await Share.shareXFiles([XFile(file.path)], text: 'Hasil Test MMSE');
  }

  pw.Widget _buildSectionPDF(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
          ),
          child: pw.Column(children: children),
        ),
      ],
    );
  }

  pw.Widget _buildQuestionAnswerPDF(String question, String? answer) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(question, style: const pw.TextStyle(fontSize: 12)),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              answer ?? "-",
              style: const pw.TextStyle(fontSize: 12),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
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
          "Detail Hasil Test",
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF2D3142)),
            onPressed: _generateAndSharePDF,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8FAFB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreCard(),
            const SizedBox(height: 24),
            _buildSection("Orientasi Waktu", [
              _buildQuestionAnswer(
                "Sekarang tahun apa?",
                entry.orientationTimeAnswers[0],
              ),
              _buildQuestionAnswer(
                "Sekarang musim apa?",
                entry.orientationTimeAnswers[1],
              ),
              _buildQuestionAnswer(
                "Sekarang bulan apa?",
                entry.orientationTimeAnswers[2],
              ),
              _buildQuestionAnswer(
                "Sekarang tanggal apa?",
                entry.orientationTimeAnswers[3],
              ),
              _buildQuestionAnswer(
                "Sekarang hari apa?",
                entry.orientationTimeAnswers[4],
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection("Orientasi Tempat", [
              _buildQuestionAnswer(
                "Kita ada di negara mana?",
                entry.orientationPlaceAnswers[0],
              ),
              _buildQuestionAnswer(
                "Kita ada di provinsi mana?",
                entry.orientationPlaceAnswers[1],
              ),
              _buildQuestionAnswer(
                "Kita ada di kota mana?",
                entry.orientationPlaceAnswers[2],
              ),
              _buildQuestionAnswer(
                "Kita ada di rumah sakit apa?",
                entry.orientationPlaceAnswers[3],
              ),
              _buildQuestionAnswer(
                "Kita ada di kamar/lantai berapa?",
                entry.orientationPlaceAnswers[4],
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection("Registrasi", [
              _buildQuestionAnswer(
                "Banyak nama benda yang benar",
                "${entry.registrationScore}",
              ),
              _buildQuestionAnswer(
                "Banyak jumlah pengulangan",
                "${entry.registrationRepetitions}",
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection("Atensi dan Kalkulasi", [
              _buildQuestionAnswer(
                "Hitung mundur kelipatan 7",
                "${entry.attentionScore}",
              ),
              _buildQuestionAnswer(
                "Mengingat kembali nama benda",
                "${entry.recallScore}",
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection("Bahasa", [
              _buildQuestionAnswer(
                "Sebutkan nama benda yang muncul",
                "${entry.bendaScore}",
              ),
              _buildQuestionAnswer("Ulangi rangkaian kata", entry.kataAnswer),
              _buildQuestionAnswer(
                "Instruksi 3 langkah",
                "${entry.instruksiScore}",
              ),
              _buildQuestionAnswer(
                "Angkat tangan kiri",
                entry.angkatTanganAnswer,
              ),
              _buildQuestionAnswer("Tulis kalimat", entry.tulisKalimatAnswer),
              _buildQuestionAnswer("Tiru gambar", entry.tiruGambarAnswer),
            ]),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.blue.shade50],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Skor Test",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2D3142),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        entry.score >= 24
                            ? const Color(0xFFAFE073).withOpacity(0.1)
                            : entry.score >= 18
                            ? const Color(0xFFFFD54F).withOpacity(0.1)
                            : const Color(0xFFFF8A65).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    entry.score >= 24
                        ? 'Normal'
                        : entry.score >= 18
                        ? 'Ringan'
                        : entry.score >= 10
                        ? 'Berat'
                        : 'Berat',
                    style: TextStyle(
                      color:
                          entry.score >= 24
                              ? const Color(0xFFAFE073)
                              : entry.score >= 18
                              ? const Color(0xFFFFD54F)
                              : entry.score >= 10
                              ? const Color(0xFFFF8A65)
                              : const Color(0xFFE53935),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              entry.score.toString(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Tanggal Test",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF2D3142),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd MMMM yyyy').format(entry.date),
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3142),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionAnswer(String question, String? answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              question,
              style: const TextStyle(fontSize: 14, color: Color(0xFF2D3142)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    answer == "Benar"
                        ? const Color(0xFFAFE073).withOpacity(0.1)
                        : answer == "Salah"
                        ? const Color(0xFFFF8A65).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                answer ?? "-",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      answer == "Benar"
                          ? const Color(0xFFAFE073)
                          : answer == "Salah"
                          ? const Color(0xFFFF8A65)
                          : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildProfileInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 12),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
