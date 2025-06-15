// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:project/core/widgets/geometric_shape_page_widget.dart';
import 'package:project/core/widgets/live_clock_widget.dart';
import 'package:project/features/GDS/presentation/gds_tab_view_page.dart';
import 'package:project/features/MMSE/presentation/mmse_tab_view_page.dart';
import 'package:project/features/SKILAS/presentation/skilas_tab_view_page.dart';
import 'package:project/features/alzheimer_scan/presentation/pages/alzheimer_scan_page.dart';
import 'package:project/features/article/data/article_ag_data.dart';
import 'package:project/features/article/data/article_data.dart';
import 'package:project/features/article/models/article_item.dart';
import 'package:project/features/article/presentation/pages/article_buletin_page.dart';
import 'package:project/features/game/presentation/pages/game_menu_page.dart';
import 'package:project/features/health_dashboard/presentation/health_page.dart';
import 'package:project/features/article/presentation/pages/article_detail_page.dart';
import 'package:project/features/reminder/presentation/reminder_page.dart';
import 'package:project/features/sholat/presentation/sholat_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  // bool _showFade = true;

  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollListener();
      } else if (mounted) {
        final position = _scrollController.position;
        if (position.maxScrollExtent == 0) {
          if (_showLeftArrow || _showRightArrow) {
            setState(() {
              _showLeftArrow = false;
              _showRightArrow = false;
            });
          }
        }
      }
    });
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    bool newShowLeftArrow =
        position.pixels >
        position.minScrollExtent + 10; // Add a small threshold
    bool newShowRightArrow =
        position.pixels <
        position.maxScrollExtent - 10; // Add a small threshold

    // If there's no scroll extent (content fits), no arrows should be shown.
    if (position.maxScrollExtent == 0) {
      newShowLeftArrow = false;
      newShowRightArrow = false;
    }

    if (newShowLeftArrow != _showLeftArrow ||
        newShowRightArrow != _showRightArrow) {
      if (mounted) {
        setState(() {
          _showLeftArrow = newShowLeftArrow;
          _showRightArrow = newShowRightArrow;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);

    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          "Halo, Selamat datang!",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            const GeometricBackgroundWidget(),

            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 177,
                      width: 210,
                      decoration: BoxDecoration(
                        color: const Color(0xffB5BED4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          const Positioned(
                            top: 20,
                            left: 0,
                            right: 0,
                            child: Align(
                              alignment: Alignment.topCenter,
                              // GUNAKAN WIDGET BARU DI SINI
                              child: LiveClockWidget(),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: SvgPicture.asset(
                              'assets/svgs/wave.svg',
                              color: const Color(
                                0xff898CB0,
                              ), // Perbaiki warna jika sebelumnya salah ketik
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // White background container starts here
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fitur Aplikasi Section
                        const Text(
                          'Fitur Aplikasi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Center(
                          child: Stack(
                            children: [
                              Scrollbar(
                                thumbVisibility: true,
                                radius: const Radius.circular(10),
                                controller: _scrollController,
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),

                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 26),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 80,
                                          child: _buildFeatureItem(
                                            icon:
                                                'assets/svgs/icon_kesehatan_medikal.svg',
                                            label: 'Dasbor\nKesehatan',
                                            onTap:
                                                () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            const HealthPage(),
                                                  ),
                                                ),
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        SizedBox(
                                          width: 80,
                                          child: _buildFeatureItem(
                                            icon:
                                                'assets/svgs/icon_pengingat.svg',
                                            label: 'Pengingat Jadwal Kegiatan',
                                            onTap:
                                                () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            const ReminderPage(),
                                                  ),
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        SizedBox(
                                          width: 80,
                                          child: _buildFeatureItem(
                                            icon:
                                                'assets/svgs/icon_buletin.svg',
                                            label: 'Panduan Aplikasi',
                                            onTap:
                                                () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            const ArticleBuletinPage(),
                                                  ),
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        SizedBox(
                                          width: 80,
                                          child: _buildFeatureItem(
                                            icon:
                                                'assets/svgs/icon_screening_otak_hitam.svg',
                                            label: 'Klasifikasi\nCitra MRI',
                                            onTap:
                                                () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            const AlzheimerScanPage(),
                                                  ),
                                                ),
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        SizedBox(
                                          width: 80,
                                          child: _buildFeatureItem(
                                            icon: 'assets/svgs/icon_game.svg',
                                            label: 'Game',
                                            onTap:
                                                () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            const GameMenuPage(),
                                                  ),
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        SizedBox(
                                          width: 80,
                                          child: _buildFeatureItem(
                                            icon:
                                                'assets/svgs/icon_waktu_sholat_biru.svg',
                                            label: 'Waktu\nSholat',
                                            onTap:
                                                () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            const SholatPage(),
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              if (_showLeftArrow)
                                Positioned(
                                  left: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 3,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back,
                                      size: 18,
                                      color: Color(0xFF2D3142),
                                    ),
                                  ),
                                ),
                              if (_showRightArrow)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 3,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward,
                                      size: 18,
                                      color: Color(0xFF2D3142),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Asesmen Geriatri Section
                        const Text(
                          'Formulir Tes Penilaian Kesehatan Lansia',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildAssessmentItem(
                                icon: 'assets/svgs/icon_mmse.svg',
                                title: 'Tes Mini Mental (MMSE)',
                                subtitle: 'Mini Mental State Exam',
                                color: Colors.pink[100]!,
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const MmseTabViewPage(),
                                      ),
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _buildAssessmentItem(
                                icon: 'assets/svgs/icon_gds.svg',
                                title: 'Tes Skala Depresi (GDS)',
                                subtitle: 'The Geriatric Depression Scale',
                                color: Colors.purple[100]!,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const GdsTabViewPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildAssessmentItem(
                                icon: 'assets/svgs/icon_skilas.svg',
                                title: 'SKILAS',
                                subtitle: 'Skrining Lansia Sederhana',
                                color: Colors.green[100]!,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const SkilasTabViewPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Artikel Section
                        const Text(
                          'Artikel Panduan Aplikasi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...articlesAG.map(
                          (article) => _buildArticleItem(context, article),
                        ),

                        const SizedBox(height: 24),

                        // Artikel Section
                        const Text(
                          'Artikel Panduan Kesehatan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...articlesH.map(
                          (article) => _buildArticleItem(context, article),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: Colors.grey.withOpacity(0.3),
        highlightColor: Colors.grey.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              SvgPicture.asset(icon, height: 48, width: 48),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Color(0xFF2D3142)),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentItem({
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2), // Shadow di bagian bawah
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(8),
        //   side: BorderSide(color: Colors.grey.shade300, width: 1),
        // ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          splashColor: Colors.grey.withOpacity(0.3),
          highlightColor: Colors.grey.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 6, bottom: 6, left: 6),
                  child: SvgPicture.asset(icon, height: 40, width: 40),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticleItem(BuildContext context, ArticleItem article) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ArticleDetailPage(
                  article: article,
                  recommendedArticles:
                      articlesH.where((a) => a != article).toList(),
                ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                article.imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
