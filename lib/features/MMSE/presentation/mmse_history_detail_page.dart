import 'package:flutter/material.dart';
import 'package:project/features/MMSE/models/mmse_history_entry.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/profile/providers/user_profile_provider.dart';

class MMSEHistoryDetailPage extends ConsumerWidget {
  final MMSEHistoryEntry entry;

  const MMSEHistoryDetailPage({super.key, required this.entry});

  Color getStatusColor(int score) {
    if (score >= 24) return const Color(0xFF388E3C);
    if (score >= 18) return const Color(0xFFFFA000);
    return const Color(0xFFD32F2F);
  }

  String getResultDescription(int score) {
    if (score >= 24) {
      return 'Hasil tes menunjukkan bahwa fungsi kognitif Anda berada dalam kisaran normal. Tidak ada indikasi gangguan kognitif pada tingkat ini. Terus pertahankan gaya hidup sehat untuk mendukung kesehatan otak.';
    } else if (score >= 17) {
      return 'Hasil tes menunjukkan kemungkinan adanya gangguan kognitif ringan. Meskipun tidak pasti, kami sarankan untuk berkonsultasi lebih lanjut dengan profesional medis untuk evaluasi yang lebih mendalam.';
    } else {
      return 'Hasil tes menunjukkan adanya gangguan kognitif yang signifikan. Penting untuk segera berkonsultasi dengan profesional medis untuk mendapatkan penanganan lebih lanjut dan rencana perawatan yang sesuai.';
    }
  }

  String getStatusText(int score) {
    if (score >= 24) {
      return 'Normal';
    } else if (score >= 18) {
      return 'Ringan';
    } else {
      return 'Berat';
    }
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
    File? profileImage;
    if (userProfile.photoUrl != null && userProfile.photoUrl!.isNotEmpty) {
      profileImage = File(userProfile.photoUrl!);
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
                    _buildProfileInfoRow('Nama', userProfile.name ?? '-'),
                    _buildProfileInfoRow(
                      'Gender',
                      userProfile.gender == 'Male' ? 'Laki-laki' : 'Perempuan',
                    ),
                    _buildProfileInfoRow(
                      'Tanggal Lahir',
                      userProfile.birthDate != null
                          ? DateFormat(
                            'dd MMMM yyyy',
                          ).format(userProfile.birthDate!)
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
                _buildQuestionAnswerPDF(
                  "Nilai Akhir registrasi",
                  "${entry.finalScoreAnswer}",
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
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final statusColor = getStatusColor(entry.score);
    final statusText = getStatusText(entry.score);

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
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF2D3142)),
            onPressed: () => _generateAndSharePDF(context, ref),
          ),
        ],
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
            _buildScoreCard(statusColor, statusText),
            const SizedBox(height: 24),
            _buildSection("Orientasi Waktu", [
              _buildQuestionAnswer(
                "Sekarang tahun apa?",
                entry.orientationTimeAnswers[0],
                isLast: false,
              ),
              _buildQuestionAnswer(
                "Sekarang musim apa?",
                entry.orientationTimeAnswers[1],
                isLast: false,
              ),
              _buildQuestionAnswer(
                "Sekarang bulan apa?",
                entry.orientationTimeAnswers[2],
                isLast: false,
              ),
              _buildQuestionAnswer(
                "Sekarang tanggal apa?",
                entry.orientationTimeAnswers[3],
                isLast: false,
              ),
              _buildQuestionAnswer(
                "Sekarang hari apa?",
                entry.orientationTimeAnswers[4],
                isLast: true,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection("Orientasi Tempat", [
              _buildQuestionAnswer(
                "Kita ada di negara mana?",
                entry.orientationPlaceAnswers[0],
                isLast: false,
              ),
              _buildQuestionAnswer(
                "Kita ada di provinsi mana?",
                entry.orientationPlaceAnswers[1],
                isLast: false,
              ),
              _buildQuestionAnswer(
                "Kita ada di kota mana?",
                entry.orientationPlaceAnswers[2],
                isLast: false,
              ),
              _buildQuestionAnswer(
                "Kita ada di rumah sakit apa?",
                entry.orientationPlaceAnswers[3],
                isLast: false,
              ),
              _buildQuestionAnswer(
                "Kita ada di kamar/lantai berapa?",
                entry.orientationPlaceAnswers[4],
                isLast: true,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection("Registrasi", [
              const Text(
                "Perulangan 3 kata objek",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              _buildQuestionAnswer(
                "Banyak nama benda yang benar",
                "${entry.registrationScore}",
                isLast: true,
              ),
              _buildQuestionAnswer(
                "Banyak jumlah pengulangan",
                "${entry.registrationRepetitions}",
                isLast: false,
              ),
              _buildQuestionAnswer(
                "Nilai Akhir registrasi",
                "${entry.finalScoreAnswer}",
                isLast: true,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection("Atensi dan Kalkulasi", [
              _buildQuestionAnswer(
                "Hitung mundur kelipatan 7",
                "${entry.attentionScore}",
                isLast: false,
              ),
              _buildQuestionAnswer(
                "Mengingat kembali nama benda",
                "${entry.recallScore}",
                isLast: true,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection("Bahasa", [
              _buildQuestionAnswer(
                "Sebutkan nama benda yang muncul",
                "${entry.bendaScore}",
                isLast: false,
              ),
              _buildQuestionAnswer(
                "Ulangi rangkaian kata",
                entry.kataAnswer,
                isLast: false,
              ),
              _buildQuestionAnswer(
                "Instruksi 3 langkah",
                "${entry.instruksiScore}",
                isLast: false,
              ),
              _buildQuestionAnswer(
                "Angkat tangan kiri",
                entry.angkatTanganAnswer,
                isLast: false,
              ),
              _buildQuestionAnswer(
                "Tulis kalimat",
                entry.tulisKalimatAnswer,
                isLast: false,
              ),
              _buildQuestionAnswer(
                "Tiru gambar",
                entry.tiruGambarAnswer,
                isLast: true,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  // Widget Informasi Pasien (sama dengan GDS)
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
                  ? DateFormat('dd MMMM yyyy').format(userProfile.birthDate!)
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

  // Baris Informasi (sama dengan GDS)
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

  // Widget Kartu Skor (diadaptasi dari GDS)
  Widget _buildScoreCard(Color statusColor, String statusText) {
    final statusColor = getStatusColor(entry.score);
    final statusText = getStatusText(entry.score);
    final resultText = getResultDescription(entry.score);
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
              "Status Kesehatan Mental",
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
            const Text(
              "Skor MMSE",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              entry.score.toString(),
              style: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
            Text(
              "dari 30 total poin",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 16),

            Text(
              resultText,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
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
                  "Tanggal Penilaian: ${DateFormat('dd MMMM yyyy', 'id_ID').format(entry.date)}",

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

  // Widget Bagian (sama dengan GDS)
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

  // Widget Pertanyaan-Jawaban (sama dengan GDS)
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
              flex: 4,
              child: Text(
                question,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(width: 16),
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
        if (!isLast) const Divider(height: 28) else const SizedBox(height: 12),
      ],
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
