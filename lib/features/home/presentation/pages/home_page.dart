import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project/core/providers/auth_provider.dart';
import 'package:project/core/providers/user_profile_provider.dart';
import 'package:project/features/MMSE/presentation/mmse_history_page.dart';
import 'package:project/features/MMSE/presentation/mmse_test_page_1.dart';
import 'package:project/features/auth/presentation/pages/signin_page.dart';
import 'package:project/features/buletin/presentation/pages/buletin_page.dart';
import 'package:project/features/buletin/data/article_data.dart';
import 'package:project/features/buletin/models/article_item.dart';
import 'package:project/features/home/presentation/pages/article_detail_page.dart';
import 'package:project/features/reminder/presentation/reminder_menu_page.dart';
import 'package:project/features/alzheimer_scan/presentation/pages/alzheimer_scan_page.dart';
import 'package:project/features/game/presentation/pages/game_menu_page.dart';
import 'dart:async';

import 'package:project/features/reminder/sholat_reminder/presentation/sholat_reminder_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late Timer _timer;
  late String _timeString;
  late String _dateString;

  @override
  void initState() {
    super.initState();
    _timeString = _formatTime(DateTime.now());
    _dateString = _formatDate(DateTime.now());
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) => _getTime(),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    setState(() {
      _timeString = _formatTime(now);
      _dateString = _formatDate(now);
    });
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    final List<String> months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final List<String> days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    return '${days[dateTime.weekday - 1]}, ${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    final user = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "Halo, Selamat datang!",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await authNotifier.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Card
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
                      Positioned(
                        top: 48,
                        left: 0,
                        right: 0,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Column(
                            children: [
                              Text(
                                _timeString,
                                style: const TextStyle(
                                  color: Color(0xffFFECCC),
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _dateString,
                                style: const TextStyle(
                                  color: Color(0xffFFECCC),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: SvgPicture.asset(
                          'assets/svgs/wave.svg',
                          color: Color(0xff898CB0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Fitur Aplikasi Section
              const Text(
                'Fitur Aplikasi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 60,
                    child: _buildFeatureItem(
                      icon: 'assets/svgs/icon_pengingat.svg',
                      label: 'Notifikasi\nPengingat',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReminderMenuPage(),
                            ),
                          ),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: _buildFeatureItem(
                      icon: 'assets/svgs/icon_game.svg',
                      label: 'Game',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GameMenuPage(),
                            ),
                          ),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: _buildFeatureItem(
                      icon: 'assets/svgs/icon_waktu_sholat.svg',
                      label: 'Waktu\nSholat',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SholatPage(),
                            ),
                          ),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: _buildFeatureItem(
                      icon: 'assets/svgs/icon_buletin.svg',
                      label: 'Panduan\nKesehatan',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BuletinPage(),
                            ),
                          ),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: _buildFeatureItem(
                      icon: 'assets/svgs/icon_screening_otak.svg',
                      label: 'Screening\nOtak',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AlzheimerScanPage(),
                            ),
                          ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Asesmen Geriatri Section
              const Text(
                'Asesmen Geriatri',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildAssessmentItem(
                      icon: 'assets/svgs/icon_mmse.svg',
                      title: 'MMSE',
                      subtitle: 'Mini Mental State Exam',
                      color: Colors.pink[100]!,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MMSEHistoryPage(),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAssessmentItem(
                      icon: 'assets/svgs/icon_gds.svg',
                      title: 'GDS',
                      subtitle: 'The Geriatric Depression Scale',
                      color: Colors.purple[100]!,
                      onTap: () {},
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
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Artikel Section
              const Text(
                'Artikel Panduan Kesehatan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 16),
              ...articles.map((article) => _buildArticleItem(context, article)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          SvgPicture.asset(icon, height: 34, width: 34),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF2D3142)),
          ),
        ],
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
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(icon, height: 34, width: 34),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2D3142),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
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
                      articles.where((a) => a != article).toList(),
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
