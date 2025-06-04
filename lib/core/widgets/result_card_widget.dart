import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResultCardWidget extends StatelessWidget {
  final DateTime date;
  final String title;
  final String subtitle;
  final Color accentColor; // Mengganti nama backgroundColor menjadi accentColor
  final String? stage;
  final bool showStageBadge;
  final VoidCallback? onTap;
  final VoidCallback? onDeletePressed; // Tombol callback baru untuk delete

  const ResultCardWidget({
    super.key,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    this.stage,
    this.showStageBadge = true,
    this.onTap,
    this.onDeletePressed, // Tambahkan parameter ini
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    accentColor == const Color(0xFF4CAF50)
                        ? Icons.check_circle_outline
                        : Icons.warning_amber_rounded,
                    color: accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (showStageBadge && stage != null)
                            Container(
                              margin: const EdgeInsets.only(
                                left: 8,
                              ), // Margin untuk stage badge
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                stage!,
                                style: TextStyle(
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        DateFormat('dd MMMM yyyy').format(date),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                if (onDeletePressed !=
                    null) // Tampilkan tombol hapus jika callback disediakan
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 4.0,
                    ), // Sedikit padding kiri
                    child: IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red.shade600,
                        size: 24,
                      ),
                      onPressed: onDeletePressed,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ), // Ukuran tap target
                      tooltip: 'Hapus Riwayat',
                      splashRadius: 20,
                    ),
                  ),
              ],
            ),
            // Hapus Row kosong di bawah jika tidak digunakan lagi
            // const SizedBox(height: 8),
            // const Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [],
            // ),
          ],
        ),
      ),
    );
  }
}
