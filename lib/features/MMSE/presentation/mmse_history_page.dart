import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/MMSE/presentation/mmse_history_detail_page.dart';
import 'package:project/features/MMSE/providers/mmse_history_provider.dart';
import 'package:intl/intl.dart';
import 'package:project/features/MMSE/presentation/mmse_test_page_1.dart';
import 'package:project/core/widgets/start_test_button_widget.dart';
import 'package:project/core/widgets/result_card_widget.dart';
import 'package:project/core/widgets/custom_app_bar_widget.dart';

class MMSEHistoryPage extends ConsumerStatefulWidget {
  const MMSEHistoryPage({super.key});

  @override
  ConsumerState<MMSEHistoryPage> createState() => _MMSEHistoryPageState();
}

class _MMSEHistoryPageState extends ConsumerState<MMSEHistoryPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(mmseHistoryProvider.notifier).loadHistory();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(mmseHistoryProvider.notifier).loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(mmseHistoryProvider);
    final sortedHistory = historyState.sortedHistory;

    return Scaffold(
      appBar: CustomAppBarWidget(
        title: "Mini-Mental State Exam (MMSE)",
        showCloseButton: true,
        onClose: () => Navigator.of(context).popUntil((route) => route.isFirst),
      ),
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Column(
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
                    ref.read(mmseHistoryProvider.notifier).toggleSort();
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
                            Color(0xFF2563EB),
                          ),
                        ),
                      )
                      : RefreshIndicator(
                        color: Color(0xFF2563EB),
                        backgroundColor: Colors.white,
                        onRefresh: _onRefresh,
                        child:
                            sortedHistory.isEmpty
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
                                  itemCount: sortedHistory.length,
                                  separatorBuilder:
                                      (_, __) => const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    final entry = sortedHistory[index];
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
                                                    MMSEHistoryDetailPage(
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
                  MaterialPageRoute(
                    builder: (context) => const MMSETestPage1(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
