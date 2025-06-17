import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/GDS/providers/gds_history_provider.dart';
import 'package:project/features/GDS/presentation/gds_test_page.dart';
import 'package:project/core/widgets/start_test_button_widget.dart';
import 'package:project/core/widgets/result_card_widget.dart';
import 'package:project/features/GDS/presentation/gds_history_detail_page.dart';

class GDSHistoryPage extends ConsumerStatefulWidget {
  const GDSHistoryPage({super.key});

  @override
  ConsumerState<GDSHistoryPage> createState() => _GDSHistoryPageState();
}

class _GDSHistoryPageState extends ConsumerState<GDSHistoryPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(gdsHistoryProvider.notifier).loadHistory();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(gdsHistoryProvider.notifier).loadHistory();
  }

  // Method untuk menampilkan dialog konfirmasi penghapusan
  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    dynamic entry,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xffFAF9F6),
          title: const Text('Konfirmasi Hapus'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Apakah Anda yakin ingin menghapus riwayat tes ini?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.black87),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () {
                // Panggil metode deleteEntry pada provider Anda
                // Pastikan provider memiliki metode seperti `deleteEntry`
                // dan `entry` memiliki identifier yang bisa digunakan (misal: entry.id atau entry.date)
                // Contoh: ref.read(gdsHistoryProvider.notifier).deleteEntry(entry);
                // Untuk placeholder, kita akan mengasumsikan ada metode deleteEntry(entry)
                try {
                  ref.read(gdsHistoryProvider.notifier).deleteEntry(entry);
                } catch (e) {
                  // Handle jika metode deleteEntry belum ada atau error lain
                  debugPrint(
                    "Error deleting GDS entry: $e. Pastikan provider memiliki metode 'deleteEntry'.",
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Gagal menghapus riwayat. Metode belum diimplementasi di provider.',
                      ),
                    ),
                  );
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(gdsHistoryProvider);
    final sortedHistory = historyState.sortedHistory;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 24, top: 12, bottom: 8),
              child: Text(
                textAlign: TextAlign.center,
                "Riwayat Tes GDS",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Color(0xFF222B45),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                    historyState.sortByScore
                        ? 'Sort berdasarkan Skor'
                        : 'Sort berdasarkan Tanggal',
                    style: const TextStyle(
                      color: Color(0xFF2D3142),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: () {
                    ref.read(gdsHistoryProvider.notifier).toggleSort();
                  },
                ),
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.only(left: 24, right: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Riwayat² yang muncul di bawah ini dapat dipencet untuk dilihat detailnya",
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child:
                  historyState.isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF2563EB),
                          ),
                        ),
                      )
                      : RefreshIndicator(
                        color: const Color(0xFF2563EB),
                        backgroundColor: Colors.white,
                        onRefresh: _onRefresh,
                        child:
                            sortedHistory.isEmpty
                                ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.history_rounded,
                                        size: 80,
                                        color: Colors.grey.shade300,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Belum ada riwayat tes.',
                                        style: TextStyle(
                                          color: Color(0xFF9C9DB9),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 8,
                                  ),
                                  itemCount: sortedHistory.length,
                                  separatorBuilder:
                                      (_, __) => const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    final entry = sortedHistory[index];
                                    String stage;
                                    Color stageColor;
                                    String subtitle;

                                    if (entry.score > 10) {
                                      stage = 'Depresi';
                                      stageColor = const Color(0xFFD32F2F);
                                      subtitle =
                                          'Skor ≥ 10 mengindikasikan gejala depresi';
                                    } else if (entry.score > 5 &&
                                        entry.score <= 10) {
                                      stage = 'Ada Indikasi';
                                      stageColor = const Color(0xFFFBBC05);
                                      subtitle =
                                          'Skor diantara 5~10 mengindikasikan kecil adanya gejala depresi';
                                    } else if (entry.score <= 5) {
                                      stage = 'Normal';
                                      stageColor = const Color(0xFF4CAF50);
                                      subtitle =
                                          'Skor ≤ 5 mengindikasikan tidak ada gejala depresi';
                                    } else {
                                      stage = '-';
                                      stageColor = Colors.blueGrey;
                                      subtitle = '-';
                                    }

                                    return ResultCardWidget(
                                      date: entry.date,
                                      title: 'Skor: ${entry.score}',
                                      subtitle: subtitle,
                                      accentColor: stageColor,
                                      stage: stage,
                                      showStageBadge: true,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    GDSHistoryDetailPage(
                                                      entry: entry,
                                                    ),
                                          ),
                                        );
                                      },
                                      onDeletePressed: () {
                                        // Tambahkan ini
                                        _showDeleteConfirmationDialog(
                                          context,
                                          entry,
                                        );
                                      },
                                    );
                                  },
                                ),
                      ),
            ),
            StartTestButtonWidget(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GDSTestPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
