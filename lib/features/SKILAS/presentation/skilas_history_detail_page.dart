import 'package:flutter/material.dart';
import 'package:project/features/SKILAS/models/skilas_test_entry.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/profile/providers/user_profile_provider.dart';
import 'package:cross_file/cross_file.dart'; // Added for XFile

class SKILASHistoryDetailPage extends ConsumerWidget {
  final SKILASHistoryEntry entry;

  const SKILASHistoryDetailPage({super.key, required this.entry});

  // Status logic for SKILAS
  String get statusText =>
      entry.score == 1 ? 'Sehat' : 'Perlu Konsultasi Lanjutan';
  Color get statusColor =>
      entry.score == 1
          ? const Color(0xFF388E3C)
          : const Color(0xFFD32F2F); // Green for Sehat, Red for Perlu

String _getResultImage() {
  if (entry.score == 1) return 'assets/images/skilas_good1.png';
  if (entry.score == 2) return 'assets/images/skilas_warning.png';
  return 'assets/images/skilas_bad.png';
}

  Future<void> _generateAndSharePDF(BuildContext context, WidgetRef ref) async {
    final userProfile = ref.read(userProfileProvider);

    if (userProfile == null || !userProfile.isProfileComplete) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Profil Belum Lengkap'),
              content: const Text(
                'Anda harus melengkapi data diri pasien terlebih dahulu pada halaman profil untuk mengunduh hasil test.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    final pdf = pw.Document();
    File? profileImageFile;
    if (userProfile.photoUrl != null && userProfile.photoUrl!.isNotEmpty) {
      profileImageFile = File(userProfile.photoUrl!);
    }

    // First page: Profile Info and Status
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context pContext) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Center(
                  child: pw.Text(
                    'Laporan Hasil Penilaian SKILAS',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blueGrey800,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              // Patient Information
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
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
                        color: PdfColors.blueGrey700,
                      ),
                    ),
                    pw.Divider(height: 20, color: PdfColors.grey300),
                    if (profileImageFile != null &&
                        profileImageFile.existsSync())
                      pw.Center(
                        child: pw.ClipOval(
                          child: pw.Image(
                            pw.MemoryImage(profileImageFile.readAsBytesSync()),
                            width: 80,
                            height: 80,
                            fit: pw.BoxFit.cover,
                          ),
                        ),
                      ),
                    if (profileImageFile != null &&
                        profileImageFile.existsSync())
                      pw.SizedBox(height: 10),
                    _buildProfileInfoRowPDF('Nama', userProfile.name ?? '-'),
                    _buildProfileInfoRowPDF(
                      'Gender',
                      userProfile.gender == 'Male' ? 'Laki-laki' : 'Perempuan',
                    ),
                    _buildProfileInfoRowPDF(
                      'Tanggal Lahir',
                      userProfile.birthDate != null
                          ? DateFormat(
                            'dd MMMM yyyy',
                            'id_ID',
                          ).format(userProfile.birthDate!)
                          : '-',
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              // Assessment Results
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(10),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Hasil Penilaian',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey700,
                      ),
                    ),
                    pw.Divider(height: 20, color: PdfColors.grey300),
                    _buildProfileInfoRowPDF(
                      'Tanggal Penilaian',
                      DateFormat('dd MMMM yyyy').format(entry.date),
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          "Status",
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          statusText,
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color:
                                entry.score == 1
                                    ? PdfColors.green700
                                    : PdfColors.red700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Second Page: Detailed Answers
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context pContext) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Jawaban Pertanyaan Detail',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey800,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                "Penurunan Kognitif",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey700,
                ),
              ),
              pw.SizedBox(height: 8),
              _buildSectionContainerPDF([
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
              pw.SizedBox(height: 16),
              pw.Text(
                "Malnutrisi",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey700,
                ),
              ),
              pw.SizedBox(height: 8),
              _buildSectionContainerPDF([
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
              pw.SizedBox(height: 16),
              pw.Text(
                "Depresi",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey700,
                ),
              ),
              pw.SizedBox(height: 8),
              _buildSectionContainerPDF([
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

    final output = await getTemporaryDirectory();
    final file = File(
      '${output.path}/skilas_result_${entry.date.millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Hasil Test SKILAS - ${userProfile.name ?? 'Pasien'}');
  }

  pw.Widget _buildProfileInfoRowPDF(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSectionContainerPDF(List<pw.Widget> children) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(children: children),
    );
  }

  pw.Widget _buildQuestionAnswerPDF(String question, String? answer) {
    return pw.Container(
      color: PdfColors.white,
      child: pw.Column(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 4,
                  child: pw.Text(
                    question,
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    answer ?? "-",
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          pw.Divider(color: PdfColors.grey200, height: 1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2D3142)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Laporan Hasil Penilaian",
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF2D3142)),
            tooltip: "Bagikan Hasil",
            onPressed: () => _generateAndSharePDF(context, ref),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF8FAFB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userProfile != null && userProfile.isProfileComplete)
              _buildPatientInfoCard(userProfile),
            const SizedBox(height: 24),
            _buildScoreCard(),
            const SizedBox(height: 24),
            _buildSection("Penurunan Kognitif", [
              _buildQuestionAnswer(
                "Instruksikan pasien untuk mengingat tiga kata (cont: jeruk, uang, dan mawar).",
                entry.page1Answers[0],
                isLast: false,
              ),
              _buildQuestionAnswer(
                "Sekarang tanggal berapa?",
                entry.page1Answers[1],
                isLast: false,
              ),
              _buildQuestionAnswer(
                "Dimana anda berada sekarang?",
                entry.page1Answers[2],
                isLast: false,
              ),
              _buildQuestionAnswer(
                "Instruksikan pasien untuk mengulangi 3 kata di awal.",
                entry.page1Answers[3],
                isLast: true,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection("Malnutrisi", [
              _buildQuestionAnswer(
                "Apakah berat badan pasien berkurang >3 kg dalam 3 bulan terakhir atau pakaian menjadi lebih longgar?",
                entry.page2Answers[0],
                isLast: false,
              ),
              _buildQuestionAnswer(
                "Apakah pasien hilang nafsu makan Atau mengalami kesulitan makan (misal batuk atau tersedak saat makan, menggunakan selang makan/sonde)?",
                entry.page2Answers[1],
                isLast: false,
              ),
              _buildQuestionAnswer(
                "Apakah ukuran lingkar lengan atas (LiLA) <21 cm?",
                entry.page2Answers[2],
                isLast: true,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection("Depresi", [
              _buildQuestionAnswer(
                "Selama dua minggu terakhir, apakah Anda merasa terganggu oleh perasaan sedih, tertekan, atau putus asa?",
                entry.page3Answers[0],
                isLast: false,
              ),
              _buildQuestionAnswer(
                "Selama dua minggu terakhir, apakah Anda merasa terganggu oleh sedikit minat atau kesenangan dalam melakukan sesuatu?",
                entry.page3Answers[1],
                isLast: true,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard(UserProfile userProfile) {
    return Card(
      color: Colors.white,
      elevation: 0.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Informasi Pasien",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.person_outline,
              "Nama Pasien",
              userProfile.name ?? "-",
            ),
            _buildInfoRow(
              Icons.cake_outlined,
              "Tanggal Lahir",
              userProfile.birthDate != null
                  ? DateFormat(
                    'dd MMMM yyyy',
                    'id_ID',
                  ).format(userProfile.birthDate!)
                  : "-",
            ),
            _buildInfoRow(
              Icons.wc_outlined,
              "Gender",
              userProfile.gender == 'Male' ? 'Laki-laki' : 'Perempuan',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3142),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [statusColor.withOpacity(0.2), Colors.white],
            stops: const [0.0, 0.3],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Status Penilaian SKILAS",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3142),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  _getResultImage(),
                  height: 100,
                  width: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              entry.score == 1
                  ? "Kondisi pasien terindikasi sehat."
                  : "Pasien memerlukan perhatian dan konsultasi lebih lanjut.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Color(0xFF2D3142),
                ),
                const SizedBox(width: 8),
                Text(
                  "Tanggal Penilaian: ${DateFormat('dd MMMM yyyy').format(entry.date)}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2D3142),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      color: Colors.white,
      elevation: 0.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionAnswer(
    String question,
    String? answer, {
    bool isLast = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4, // Adjusted flex to give more space for question
              child: Text(
                question,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(width: 16), // Consistent spacing
            // SKILAS answers are typically "Ya" / "Tidak" or similar short responses.
            // Using the same style as GDS for the answer text.
            Text(
              answer ?? "-",
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (!isLast)
          const Divider(
            height: 28, // Consistent divider height
          )
        else
          const SizedBox(height: 12), // Consistent spacing for the last item
      ],
    );
  }
}
