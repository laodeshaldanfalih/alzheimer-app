import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/features/GDS/models/gds_history_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/profile/providers/user_profile_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class GDSHistoryDetailPage extends ConsumerWidget {
  final GDSHistoryEntry entry;
  const GDSHistoryDetailPage({super.key, required this.entry});

  static const List<String> questions = [
    "Apakah Anda pada dasarnya puas dengan hidup Anda?",
    "Apakah Anda telah melepaskan banyak kegiatan dan minat Anda?",
    "Apakah Anda merasa hidup Anda kosong?",
    "Apakah Anda sering merasa bosan?",
    "Apakah Anda dalam suasana hati yang baik hampir sepanjang waktu?",
    "Apakah Anda takut bahwa sesuatu yang buruk akan terjadi pada Anda?",
    "Apakah Anda merasa bahagia hampir sepanjang waktu?",
    "Apakah Anda sering merasa tidak berdaya?",
    "Apakah Anda lebih suka tinggal di rumah daripada pergi keluar dan melakukan hal-hal baru?",
    "Apakah Anda merasa memiliki lebih banyak masalah dengan ingatan daripada kebanyakan orang?",
    "Apakah Anda berpikir bahwa sekarang ini adalah waktu yang indah untuk hidup?",
    "Apakah Anda merasa tidak berharga seperti sekarang ini?",
    "Apakah Anda merasa penuh energi?",
    "Apakah Anda merasa situasi Anda tidak ada harapan?",
    "Apakah Anda berpikir bahwa kebanyakan orang lebih baik daripada Anda?",
  ];

  Color get statusColor =>
      entry.isDepressed ? const Color(0xFFD32F2F) : const Color(0xFF4CAF50);
  String get statusText => entry.isDepressed ? 'Depresi' : 'Normal';

  Future<void> _generateAndSharePDF(BuildContext context, WidgetRef ref) async {
    final userProfile = ref.read(userProfileProvider);

    if (userProfile == null || !userProfile.isProfileComplete) {
      final missingFields = userProfile?.missingProfileFields ?? 'profil';
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Profil Belum Lengkap'),
              content: Text(
                'Anda harus melengkapi data diri pasien terlebih dahulu pada halaman profil untuk mengunduh hasil test.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
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
                  'Hasil Test GDS',
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
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Nama',
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.Text(
                          userProfile.name ?? '-',
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.blue,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Gender',
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.Text(
                          userProfile.gender == 'Male'
                              ? 'Laki-laki'
                              : 'Perempuan',
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.blue,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Tanggal Lahir',
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.Text(
                          userProfile.birthDate != null
                              ? DateFormat(
                                'dd MMMM yyyy',
                              ).format(userProfile.birthDate!)
                              : '-',
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.blue,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // ... rest of the existing PDF generation code ...
            ],
          );
        },
      ),
    );

    // ... rest of the existing PDF generation code ...
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      ),
      backgroundColor: const Color(0xFFF8FAFB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreCard(),
            const SizedBox(height: 24),
            _buildSection("Geriatric Depression Scale (GDS)", [
              ...List.generate(
                questions.length,
                (i) => _buildQuestionAnswer(
                  questions[i],
                  entry.answers.length > i ? entry.answers[i] : '-',
                ),
              ),
            ]),
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
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
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
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Text(
              answer ?? "-",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF2D3142)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF2563EB),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
