import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/GDS/providers/gds_history_provider.dart';
import 'package:project/features/GDS/presentation/gds_test_page.dart';
import 'package:project/core/widgets/start_test_button_widget.dart';
import 'package:project/core/widgets/result_card_widget.dart';
import 'package:project/core/widgets/custom_app_bar_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(gdsHistoryProvider);
    final sortedHistory = historyState.sortedHistory;

    return Scaffold(
      appBar: CustomAppBarWidget(
        title: "Geriatric Depression Scale (GDS)",
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
                    ref.read(gdsHistoryProvider.notifier).toggleSort();
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
                        color: const Color(0xFF2563EB),
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

                                    if (entry.isDepressed) {
                                      stage = 'Depresi';
                                      stageColor = const Color(0xFFD32F2F);
                                      subtitle =
                                          'Skor ≥ 5 mengindikasikan gejala depresi';
                                    } else {
                                      stage = 'Normal';
                                      stageColor = const Color(0xFF4CAF50);
                                      subtitle =
                                          'Skor < 5 mengindikasikan tidak ada gejala depresi';
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
