import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project/core/providers/auth_provider.dart';
import 'package:project/core/providers/user_profile_provider.dart';
import 'package:project/features/auth/presentation/pages/signin_page.dart';
import 'package:project/features/home/domain/models/quick_feature_item.dart';
import 'package:project/features/buletin/data/article_data.dart';
import 'package:project/features/buletin/models/article_item.dart';
import 'package:project/features/home/presentation/pages/article_detail_page.dart';
import 'dart:async';

class HomePage extends ConsumerStatefulWidget {
  HomePage({super.key});

  final List<QuickFeatureItem> quickFeatures = [
    QuickFeatureItem(
      title: "Analisis Kamera",
      color: Colors.greenAccent,
      onTap: () {
        // TODO: Navigate to Camera Analysis
      },
    ),
    QuickFeatureItem(
      title: "Chatbot",
      color: Colors.pinkAccent,
      onTap: () {
        // TODO: Navigate to Chatbot
      },
    ),
    QuickFeatureItem(
      title: "Musik",
      color: Colors.lightBlueAccent,
      onTap: () {
        // TODO: Navigate to Music
      },
    ),
    QuickFeatureItem(
      title: "Pengingat Obat",
      color: Colors.amber,
      onTap: () {
        // TODO: Navigate to Medicine Reminder
      },
    ),
    QuickFeatureItem(
      title: "Pengingat Kegiatan",
      color: Colors.purpleAccent,
      onTap: () {
        // TODO: Navigate to Activity Reminder
      },
    ),
  ];

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
    final List<String> weekdays = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
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

    final weekday = weekdays[dateTime.weekday - 1];
    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;

    return '$weekday, $day $month $year';
  }

  @override
  Widget build(BuildContext context) {
    // Calculate width for each item (4 items per row)
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth =
        (screenWidth - 60 - (3 * 10)) / 4; // Total padding: 60, gaps: 3 * 10

    final authNotifier = ref.read(authProvider.notifier);
    final user = ref.watch(authProvider);
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "Halo, ${userProfile?.name ?? user?.email ?? 'Pengguna'}",
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authNotifier.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignInPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        color: const Color(0xff4C53B4),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                height: 177,
                width: 210,
                decoration: BoxDecoration(
                  color: const Color(0xff8E97FD),
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
                      child: SvgPicture.asset('assets/svgs/wave.svg'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 27),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fitur',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 10, // Horizontal spacing between items
                        runSpacing: 15, // Vertical spacing between rows
                        children:
                            widget.quickFeatures
                                .map(
                                  (feature) => SizedBox(
                                    width: itemWidth,
                                    child: _buildQuickFeatureItem(feature),
                                  ),
                                )
                                .toList(),
                      ),
                      const SizedBox(height: 43),
                      const Text(
                        'Buletin Artikel',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ...articles
                          .map((article) => _buildArticleItem(context, article))
                          .toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFeatureItem(QuickFeatureItem feature) {
    return InkWell(
      onTap: feature.onTap,
      child: Column(
        children: [
          CircleAvatar(radius: 20, backgroundColor: feature.color),
          const SizedBox(height: 5),
          Text(
            feature.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildArticleItem(BuildContext context, ArticleItem article) {
    return InkWell(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  article.imageUrl != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          article.imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 3,
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
