import 'package:flutter/material.dart';
import 'package:project/features/SKILAS/models/skilas_test_entry.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'skilas_test_page_1.dart';
import 'skilas_history_detail_page.dart';
import 'package:project/core/widgets/custom_app_bar.dart';
import 'package:project/core/widgets/result_card.dart';
import 'package:project/core/widgets/start_test_button.dart';

class SKILASHistoryProvider extends ChangeNotifier {
  List<SKILASHistoryEntry> _history = [];
  bool _sortByScore = false;

  List<SKILASHistoryEntry> get history {
    List<SKILASHistoryEntry> sorted = List.from(_history);
    if (_sortByScore) {
      sorted.sort((a, b) => b.score.compareTo(a.score));
    } else {
      sorted.sort((a, b) => b.date.compareTo(a.date));
    }
    return sorted;
  }

  bool get sortByScore => _sortByScore;

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('skilas_history') ?? [];
    _history =
        data.map((e) => SKILASHistoryEntry.fromJson(json.decode(e))).toList();
    notifyListeners();
  }

  Future<void> addEntry(SKILASHistoryEntry entry) async {
    _history.add(entry);
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      'skilas_history',
      _history.map((e) => json.encode(e.toJson())).toList(),
    );
    notifyListeners();
  }

  void toggleSort() {
    _sortByScore = !_sortByScore;
    notifyListeners();
  }
}

class SKILASHistoryPage extends StatefulWidget {
  const SKILASHistoryPage({super.key});

  @override
  State<SKILASHistoryPage> createState() => _SKILASHistoryPageState();
}

class _SKILASHistoryPageState extends State<SKILASHistoryPage> {
  late SKILASHistoryProvider provider;

  @override
  void initState() {
    super.initState();
    provider = SKILASHistoryProvider();
    provider.loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Skrining Lansia Sederhana (SKILAS)",
        showCloseButton: true,
      ),
      backgroundColor: const Color(0xFFF8FAFB),
      body: ChangeNotifierProvider<SKILASHistoryProvider>(
        create: (_) => provider,
        child: Consumer<SKILASHistoryProvider>(
          builder: (context, prov, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 24, top: 24, bottom: 8),
                  child: Text(
                    "Riwayat Test",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Color(0xFF222B45),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
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
                        prov.sortByScore
                            ? 'Sort berdasarkan Skor'
                            : 'Sort berdasarkan Tanggal',
                        style: const TextStyle(
                          color: Color(0xFF2D3142),
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      onPressed: () {
                        prov.toggleSort();
                      },
                    ),
                  ),
                ),
                Expanded(
                  child:
                      prov.history.isEmpty
                          ? const Center(
                            child: Text(
                              'Belum ada riwayat test.',
                              style: TextStyle(
                                color: Color(0xFF9C9DB9),
                                fontSize: 16,
                              ),
                            ),
                          )
                          : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            itemCount: prov.history.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final entry = prov.history[index];
                              return ResultCard(
                                date: entry.date,
                                title: 'Skor: ${entry.score}',
                                subtitle:
                                    entry.score == 1
                                        ? 'Pasien tidak menunjukkan tanda-tanda gangguan kognitif'
                                        : 'Pasien menunjukkan tanda-tanda gangguan kognitif',
                                backgroundColor:
                                    entry.score == 1
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFFD32F2F),
                                stage:
                                    entry.score == 1 ? 'Sehat' : 'Perlu ke RS',
                                showStageBadge: true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => SKILASHistoryDetailPage(
                                            entry: entry,
                                          ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                ),
                StartTestButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SKILASPage1(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
