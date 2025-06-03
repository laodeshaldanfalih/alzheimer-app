import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/SKILAS/providers/skilas_history_provider.dart';
import 'package:project/core/widgets/custom_app_bar_widget.dart';
import 'package:project/core/widgets/result_card_widget.dart';
import 'package:project/core/widgets/start_test_button_widget.dart';
import 'skilas_test_page_1.dart';
import 'skilas_history_detail_page.dart';

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

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(skilasHistoryProvider);

    return Scaffold(
      appBar: const CustomAppBarWidget(
        title: "Skrining Lansia Sederhana (SKILAS)",
        showCloseButton: true,
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
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                      onRefresh: _onRefresh,
                      child:
                          historyState.history.isEmpty
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
                                itemCount: historyState.sortedHistory.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final entry =
                                      historyState.sortedHistory[index];
                                  return ResultCardWidget(
                                    date: entry.date,
                                    title: 'Skor: ${entry.score}',
                                    subtitle:
                                        entry.score == 1
                                            ? 'Pasien tidak menunjukkan tanda-tanda gangguan kognitif'
                                            : 'Pasien menunjukkan tanda-tanda gangguan kognitif',
                                    accentColor:
                                        entry.score == 1
                                            ? const Color(0xFF4CAF50)
                                            : const Color(0xFFD32F2F),
                                    stage:
                                        entry.score == 1
                                            ? 'Sehat'
                                            : 'Perlu ke RS',
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
