import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/features/GDS/models/gds_history_entry.dart';

class GDSHistoryDetailPage extends StatelessWidget {
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
}
