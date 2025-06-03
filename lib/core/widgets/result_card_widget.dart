// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class ResultCardWidget extends StatelessWidget {
//   final DateTime date;
//   final String title;
//   final String subtitle;
//   final Color backgroundColor;
//   final String? stage;
//   final bool showStageBadge;
//   final VoidCallback? onTap;

//   const ResultCardWidget({
//     super.key,
//     required this.date,
//     required this.title,
//     required this.subtitle,
//     required this.backgroundColor,
//     this.stage,
//     this.showStageBadge = true,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             gradient: LinearGradient(
//               begin: Alignment.topRight,
//               end: Alignment.bottomCenter,
//               colors: [Colors.white, backgroundColor.withOpacity(0.3)],
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: backgroundColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Icon(
//                       backgroundColor == const Color(0xFF4CAF50)
//                           ? Icons.check_circle
//                           : Icons.warning,
//                       color: backgroundColor,
//                       size: 24,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: TextStyle(
//                           color: backgroundColor,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         DateFormat('dd MMMM yyyy').format(date),
//                         style: TextStyle(
//                           color: Colors.grey.shade600,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               if (showStageBadge && stage != null)
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: backgroundColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     stage!,
//                     style: TextStyle(
//                       color: backgroundColor,

//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


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

  const ResultCardWidget({
    super.key,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    this.stage,
    this.showStageBadge = true,
    this.onTap,
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
            // --- Bagian Atas: Ikon, Judul, dan Subjudul ---



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
                    // Logika ikon tetap sama
                    accentColor == const Color(0xFF4CAF50)
                        ? Icons
                            .check_circle_outline // Menggunakan ikon outline
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

                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          if (showStageBadge && stage != null)
                            Container(
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
                      // const SizedBox(height: 4),
                      // Text(
                      //   subtitle,
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     color: Colors.grey.shade600,
                      //     height: 1.4,
                      //   ),
                      // ),

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
              ],
            ),
            // const SizedBox(height: 16),
            const SizedBox(height: 8),
            // --- Bagian Bawah: Tanggal dan Stage Badge ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tanggal

                // Stage Badge
                // if (showStageBadge && stage != null)
                //   Container(
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 12,
                //       vertical: 6,
                //     ),
                //     decoration: BoxDecoration(
                //       color: accentColor.withOpacity(0.1),
                //       borderRadius: BorderRadius.circular(20),
                //     ),
                //     child: Text(
                //       stage!,
                //       style: TextStyle(
                //         color: accentColor,
                //         fontWeight: FontWeight.bold,
                //         fontSize: 12,
                //       ),
                //     ),
                //   ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

