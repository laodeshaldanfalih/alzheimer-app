import 'package:flutter/material.dart';
import 'package:project/features/SKILAS/models/skilas_test_entry.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class SKILASHistoryDetailPage extends StatelessWidget {
  final SKILASHistoryEntry entry;

  const SKILASHistoryDetailPage({super.key, required this.entry});

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
                  'Hasil Test SKILAS',
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
                      'Status: ${entry.score == 1 ? 'Sehat' : 'Perlu ke Rumah Sakit'}',
                      style: const pw.TextStyle(fontSize: 18),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Tanggal: ${DateFormat('dd MMMM yyyy').format(entry.date)}',
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

    // Second page with test results
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Detail Hasil Test',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),

              // Test Results
              _buildSectionPDF('Penurunan Kognitif', [
                _buildQuestionAnswerPDF(
                  "Instruksikan pasien untuk mengingat tiga kata (cont: jeruk, uang, dan mawar).",
                  entry.page1Answers[0],
                ),
                _buildQuestionAnswerPDF(
                  "Sekarang tanggal berapa?",
                  entry.page1Answers[1],
                ),
                _buildQuestionAnswerPDF(
                  "Dimana anda berada sekarang?",
                  entry.page1Answers[2],
                ),
                _buildQuestionAnswerPDF(
                  "Instruksikan pasien untuk mengulangi 3 kata di awal.",
                  entry.page1Answers[3],
                ),
              ]),
              pw.SizedBox(height: 20),

              _buildSectionPDF('Malnutrisi', [
                _buildQuestionAnswerPDF(
                  "Apakah berat badan pasien berkurang >3 kg dalam 3 bulan terakhir atau pakaian menjadi lebih longgar?",
                  entry.page2Answers[0],
                ),
                _buildQuestionAnswerPDF(
                  "Apakah pasien hilang nafsu makan Atau mengalami kesulitan makan (misal batuk atau tersedak saat makan, menggunakan selang makan/sonde)?",
                  entry.page2Answers[1],
                ),
                _buildQuestionAnswerPDF(
                  "Apakah ukuran lingkar lengan atas (LiLA) <21 cm?",
                  entry.page2Answers[2],
                ),
              ]),
              pw.SizedBox(height: 20),

              _buildSectionPDF('Depresi', [
                _buildQuestionAnswerPDF(
                  "Selama dua minggu terakhir, apakah Anda merasa terganggu oleh perasaan sedih, tertekan, atau putus asa?",
                  entry.page3Answers[0],
                ),
                _buildQuestionAnswerPDF(
                  "Selama dua minggu terakhir, apakah Anda merasa terganggu oleh sedikit minat atau kesenangan dalam melakukan sesuatu?",
                  entry.page3Answers[1],
                ),
              ]),
            ],
          );
        },
      ),
    );

    // Save PDF
    final output = await getTemporaryDirectory();
    final file = File(
      '${output.path}/skilas_result_${entry.date.millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    // Share PDF
    await Share.shareXFiles([XFile(file.path)], text: 'Hasil Test SKILAS');
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
            _buildSection("Penurunan Kognitif", [
              _buildQuestionAnswer(
                "Instruksikan pasien untuk mengingat tiga kata (cont: jeruk, uang, dan mawar).",
                entry.page1Answers[0],
              ),
              _buildQuestionAnswer(
                "Sekarang tanggal berapa?",
                entry.page1Answers[1],
              ),
              _buildQuestionAnswer(
                "Dimana anda berada sekarang?",
                entry.page1Answers[2],
              ),
              _buildQuestionAnswer(
                "Instruksikan pasien untuk mengulangi 3 kata di awal.",
                entry.page1Answers[3],
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection("Malnutrisi", [
              _buildQuestionAnswer(
                "Apakah berat badan pasien berkurang >3 kg dalam 3 bulan terakhir atau pakaian menjadi lebih longgar?",
                entry.page2Answers[0],
              ),
              _buildQuestionAnswer(
                "Apakah pasien hilang nafsu makan Atau mengalami kesulitan makan (misal batuk atau tersedak saat makan, menggunakan selang makan/sonde)?",
                entry.page2Answers[1],
              ),
              _buildQuestionAnswer(
                "Apakah ukuran lingkar lengan atas (LiLA) <21 cm?",
                entry.page2Answers[2],
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection("Depresi", [
              _buildQuestionAnswer(
                "Selama dua minggu terakhir, apakah Anda merasa terganggu oleh perasaan sedih, tertekan, atau putus asa?",
                entry.page3Answers[0],
              ),
              _buildQuestionAnswer(
                "Selama dua minggu terakhir, apakah Anda merasa terganggu oleh sedikit minat atau kesenangan dalam melakukan sesuatu?",
                entry.page3Answers[1],
              ),
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
                  "Status Test",
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
                        entry.score == 1
                            ? const Color(0xFFAFE073).withOpacity(0.1)
                            : const Color(0xFFFF8A65).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    entry.score == 1 ? 'Sehat' : 'Perlu ke Rumah Sakit',
                    style: TextStyle(
                      color:
                          entry.score == 1
                              ? const Color(0xFFAFE073)
                              : const Color(0xFFFF8A65),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
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
}
