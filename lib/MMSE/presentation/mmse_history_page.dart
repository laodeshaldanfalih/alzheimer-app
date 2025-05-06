import 'package:flutter/material.dart';
import 'package:project/MMSE/models/mmse_history_entry.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'mmse_test_page_1.dart';

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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF2D3142)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Mini–Mental State Exam (MMSE)",
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
                                (_, __) => const Divider(
                                  height: 32,
                                  color: Color(0xFFB0B8C1),
                                ),
                            itemBuilder: (context, index) {
                              final entry = prov.history[index];
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Skor: ${entry.score}',
                                    style: const TextStyle(
                                      color: Color(0xFF2D3142),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(entry.date),
                                    style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
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
                            builder: (context) => const MMSETestPage1(),
                          ),
                        );
                      },
                      child: const Text(
                        "Mulai Test",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}
