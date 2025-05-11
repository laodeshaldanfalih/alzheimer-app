import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'mmse_test_page_1.dart';
import 'package:project/features/MMSE/models/mmse_history_entry.dart';
import 'mmse_history_detail_page.dart';
import 'package:project/core/widgets/custom_app_bar.dart';
import 'package:project/core/widgets/result_card.dart';
import 'package:project/core/widgets/start_test_button.dart';

class MMSEHistoryProvider extends ChangeNotifier {
  List<MMSEHistoryEntry> _history = [];
  bool _sortByScore = false;

  List<MMSEHistoryEntry> get history {
    List<MMSEHistoryEntry> sorted = List.from(_history);
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
    final data = prefs.getStringList('mmse_history') ?? [];
    _history =
        data.map((e) => MMSEHistoryEntry.fromJson(json.decode(e))).toList();
    notifyListeners();
  }

  Future<void> addEntry(MMSEHistoryEntry entry) async {
    _history.add(entry);
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      'mmse_history',
      _history.map((e) => json.encode(e.toJson())).toList(),
    );
    notifyListeners();
  }

  void toggleSort() {
    _sortByScore = !_sortByScore;
    notifyListeners();
  }
}

class MMSEHistoryPage extends StatefulWidget {
  const MMSEHistoryPage({super.key});

  @override
  State<MMSEHistoryPage> createState() => _MMSEHistoryPageState();
}

class _MMSEHistoryPageState extends State<MMSEHistoryPage> {
  late MMSEHistoryProvider provider;

  @override
  void initState() {
    super.initState();
    provider = MMSEHistoryProvider();
    provider.loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Mini–Mental State Exam (MMSE)",
        showCloseButton: true,
      ),
      backgroundColor: const Color(0xFFF8FAFB),
      body: ChangeNotifierProvider<MMSEHistoryProvider>(
        create: (_) => provider,
        child: Consumer<MMSEHistoryProvider>(
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
                              String stage;
                              Color stageColor;
                              String subtitle;

                              if (entry.score >= 24) {
                                stage = 'Normal';
                                stageColor = const Color(0xFF4CAF50);
                                subtitle =
                                    'Pasien tidak menunjukkan tanda-tanda gangguan kognitif';
                              } else if (entry.score >= 18) {
                                stage = 'Ringan';
                                stageColor = const Color(0xFFFFD54F);
                                subtitle =
                                    'Pasien menunjukkan tanda-tanda gangguan kognitif ringan';
                              } else {
                                stage = 'Berat';
                                stageColor = const Color(0xFFD32F2F);
                                subtitle =
                                    'Pasien menunjukkan tanda-tanda gangguan kognitif berat';
                              }

                              return ResultCard(
                                date: entry.date,
                                title: 'Skor: ${entry.score}',
                                subtitle: subtitle,
                                backgroundColor: stageColor,
                                stage: stage,
                                showStageBadge: true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => MMSEHistoryDetailPage(
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
                        builder: (context) => const MMSETestPage1(),
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
