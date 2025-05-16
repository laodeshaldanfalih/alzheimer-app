import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:project/features/GDS/presentation/gds_history_page.dart';
import 'package:project/features/GDS/models/gds_test_entry.dart';

class GDSTestPage extends StatefulWidget {
  const GDSTestPage({super.key});

  @override
  State<GDSTestPage> createState() => _GDSTestPageState();
}

class _GDSTestPageState extends State<GDSTestPage> {
  final List<String> questions = [
    "Apakah Anda pada dasarnya puas dengan hidup Anda?",
    "Apakah Anda telah meninggalkan banyak kegiatan dan minat Anda?",
    "Apakah Anda merasa hidup Anda kosong?",
    "Apakah Anda sering merasa bosan?",
    "Apakah Anda dalam semangat yang baik sebagian besar waktu?",
    "Apakah Anda takut bahwa sesuatu yang buruk akan terjadi pada Anda?",
    "Apakah Anda merasa bahagia sebagian besar waktu?",
    "Apakah Anda sering merasa tidak berdaya?",
    "Apakah Anda lebih suka tinggal di rumah daripada keluar dan melakukan hal-hal baru?",
    "Apakah Anda merasa memiliki lebih banyak masalah dengan ingatan dibandingkan kebanyakan orang?",
    "Apakah Anda berpikir bahwa hidup saat ini sangat menyenangkan?",
    "Apakah Anda merasa tidak berharga dengan kondisi Anda sekarang?",
    "Apakah Anda merasa penuh energi?",
    "Apakah Anda merasa situasi Anda tidak ada harapan?",
    "Apakah Anda berpikir bahwa kebanyakan orang lebih baik keadaannya daripada Anda?",
  ];

  final List<String?> answers = List.filled(15, null);
  final List<String> options = ["Ya", "Tidak"];

  Future<void> _updateScores() async {
    int score = 0;
    for (String? answer in answers) {
      if (answer == "Ya") {
        score++;
      }
    }

    final result = GDSHistoryEntry(
      date: DateTime.now(),
      score: score,
      isDepressed: score >= 5,
    );

    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('gds_history') ?? [];
    history.add(json.encode(result.toJson()));
    await prefs.setStringList('gds_history', history);
  }

  bool _isPageComplete() {
    return !answers.contains(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Geriatric Depression Scale (GDS)",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                "Tes GDS",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color(0xFF222B45),
                ),
              ),
              const SizedBox(height: 18),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Instruksi",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF222B45),
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          ": Untuk setiap jawaban \"Tidak\" memberi nilai 1. Apabila skor total mencapai 5 atau lebih, mengindikasikan gejala depresi.",
                      style: TextStyle(fontSize: 12, color: Color(0xFF222B45)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: questions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${index + 1}. ${questions[index]}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Color(0xFF222B45),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonHideUnderline(
                          child: DropdownButtonFormField2<String>(
                            hint: const Expanded(
                              child: Text(
                                'Ya / Tidak',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            isExpanded: true,
                            value: answers[index],
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintStyle: const TextStyle(
                                color: Color(0xFFB0B8C1),
                                fontSize: 14,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE0E6ED),
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
                            items:
                                options
                                    .map(
                                      (opt) => DropdownMenuItem<String>(
                                        value: opt,
                                        child: Text(
                                          opt,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF1F2937),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (val) {
                              setState(() {
                                answers[index] = val;
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
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
                            await _updateScores();
                            if (mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const GDSHistoryPage(),
                                ),
                              );
                            }
                          }
                          : null,
                  child: const Text(
                    "Selesai",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
