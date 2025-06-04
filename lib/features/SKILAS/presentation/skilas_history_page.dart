import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/SKILAS/providers/skilas_history_provider.dart';
import 'package:project/core/widgets/custom_app_bar_widget.dart';
import 'package:project/core/widgets/result_card_widget.dart';
import 'package:project/core/widgets/start_test_button_widget.dart';
import 'skilas_test_page_1.dart';
import 'skilas_history_detail_page.dart';
// Asumsi SKILASHistoryEntry adalah tipe data untuk entri riwayat SKILAS
// import 'package:project/features/SKILAS/models/skilas_history_entry.dart'; // Anda mungkin perlu import modelnya

class SKILASHistoryPage extends ConsumerStatefulWidget {
  const SKILASHistoryPage({super.key});

  @override
  ConsumerState<SKILASHistoryPage> createState() => _SKILASHistoryPageState();
}

class _SKILASHistoryPageState extends ConsumerState<SKILASHistoryPage> {
  Future<void> _onRefresh() async {
    await ref.read(skilasHistoryProvider.notifier).loadHistory();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(skilasHistoryProvider.notifier).loadHistory(),
    );
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
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () {
                // Panggil metode deleteEntry pada provider Anda
                // Contoh: ref.read(skilasHistoryProvider.notifier).deleteEntry(entry);
                try {
                  ref.read(skilasHistoryProvider.notifier).deleteEntry(entry);
                } catch (e) {
                  debugPrint(
                    "Error deleting SKILAS entry: $e. Pastikan provider memiliki metode 'deleteEntry'.",
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
    final historyState = ref.watch(skilasHistoryProvider);
    // Menggunakan sortedHistory dari state jika ada, jika tidak, fallback ke history
    final sortedHistory = historyState.sortedHistory;

    return Scaffold(
      appBar: CustomAppBarWidget(
        // Menambahkan onClose untuk konsistensi
        title: "Skrining Lansia Sederhana (SKILAS)",
        showCloseButton: true,
        onClose: () => Navigator.of(context).popUntil((route) => route.isFirst),
      ),
      backgroundColor: const Color(0xFFF8FAFB),
      body: Column(
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
                  ref.read(skilasHistoryProvider.notifier).toggleSort();
                },
              ),
            ),
          ),
          Expanded(
            child:
                historyState.isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF2563EB), // Menggunakan warna yang konsisten
                        ),
                      ),
                    )
                    : RefreshIndicator(
                      color: const Color(
                        0xFF2563EB,
                      ), // Menggunakan warna yang konsisten
                      backgroundColor: Colors.white,
                      onRefresh: _onRefresh,
                      child:
                          sortedHistory
                                  .isEmpty // Menggunakan sortedHistory
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
                                itemCount:
                                    sortedHistory
                                        .length, // Menggunakan sortedHistory
                                separatorBuilder:
                                    (_, __) => const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final entry =
                                      sortedHistory[index]; // Menggunakan sortedHistory
                                  return ResultCardWidget(
                                    date: entry.date,
                                    title: 'Skor: ${entry.score}',
                                    subtitle:
                                        entry.score ==
                                                1 // Asumsi dari kode asli, nilai 1 adalah sehat
                                            ? 'Pasien tidak menunjukkan tanda-tanda gangguan kognitif'
                                            : 'Pasien menunjukkan tanda-tanda gangguan kognitif',
                                    accentColor:
                                        entry.score == 1
                                            ? const Color(
                                              0xFF4CAF50,
                                            ) // Hijau untuk sehat
                                            : const Color(
                                              0xFFD32F2F,
                                            ), // Merah untuk tidak sehat
                                    stage:
                                        entry.score == 1
                                            ? 'Sehat'
                                            : 'Tidak Sehat',
                                    showStageBadge: true,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  SKILASHistoryDetailPage(
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
                MaterialPageRoute(builder: (context) => const SKILASPage1()),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
