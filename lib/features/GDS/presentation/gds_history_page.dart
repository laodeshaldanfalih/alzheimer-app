import 'package:flutter/material.dart';
import 'package:project/features/GDS/presentation/gds_test_page.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:project/features/GDS/models/gds_test_entry.dart';
import 'package:project/core/widgets/custom_app_bar.dart';
import 'package:project/core/widgets/result_card.dart';

class GDSHistoryPage extends StatefulWidget {
  const GDSHistoryPage({super.key});

  @override
  State<GDSHistoryPage> createState() => _GDSHistoryPageState();
}

class _GDSHistoryPageState extends State<GDSHistoryPage> {
  List<GDSHistoryEntry> _history = [];
  bool _sortByScore = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('gds_history') ?? [];
    setState(() {
      _history =
          data.map((e) => GDSHistoryEntry.fromJson(json.decode(e))).toList();
      _sortHistory();
    });
  }

  void _sortHistory() {
    if (_sortByScore) {
      _history.sort((a, b) => b.score.compareTo(a.score));
    } else {
      _history.sort((a, b) => b.date.compareTo(a.date));
    }
  }

  void _toggleSort() {
    setState(() {
      _sortByScore = !_sortByScore;
      _sortHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Riwayat GDS", showCloseButton: true),
      backgroundColor: const Color(0xFFF8FAFB),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              "Riwayat Tes GDS",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Color(0xFF222B45),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE4E4E4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                  ),
                  icon: const Icon(Icons.sort, color: Color(0xFF2D3142)),
                  label: Text(
                    _sortByScore
                        ? 'Sort berdasarkan Skor'
                        : 'Sort berdasarkan Tanggal',
                    style: const TextStyle(
                      color: Color(0xFF2D3142),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: _toggleSort,
                ),
              ),
            ),
            Expanded(
              child:
                  _history.isEmpty
                      ? const Center(
                        child: Text(
                          "Belum ada riwayat tes",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8A94A6),
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final result = _history[index];
                          return ResultCard(
                            date: result.date,
                            title: "Skor: ${result.score}",
                            subtitle:
                                result.isDepressed
                                    ? "Pasien menunjukkan tanda-tanda depresi"
                                    : "Pasien tidak menunjukkan tanda-tanda depresi",
                            backgroundColor:
                                result.isDepressed
                                    ? const Color(0xFFD32F2F)
                                    : const Color(0xFF4CAF50),
                            onTap: null,
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
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GDSTestPage(),
                    ),
                  );
                },
                child: const Text(
                  "Mulai Tes Baru",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
