import 'package:flutter/material.dart';
import 'package:project/dump/prayer/prayer_times_page.dart';
import 'package:project/dump/prayer_time_page.dart';
import 'package:project/dump/vertex_ai_page.dart';
import 'package:project/game/color_game.dart';
import 'package:project/feature/feature_menu_item.dart';
import 'package:project/feature/feature_menu_page.dart';

import 'package:project/game/responsive_meal_planning_game.dart';
import 'package:project/sholat/sholat_page.dart';

class MenuGame extends StatelessWidget {
  const MenuGame({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Game',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3A3B45),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
          child:
              isSmallScreen
                  ? Column(children: _buildGameCards(context))
                  : Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: _buildGameCards(context),
                  ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(isSmallScreen),
    );
  }

  List<Widget> _buildGameCards(BuildContext context) {
    final games = [
      {
        'title': 'Mencocokkan Warna',
        'desc': 'Latihan mencocokkan warna dengan cepat dan tepat.',
        'widget': const ColorGame(),
      },
      {
        'title': 'Menyusun Makanan',
        'desc': 'Tantangan menyusun makanan sesuai nutrisi.',
        'widget': const ResponsiveMealPlanningGame(),
      },
      {
        'title': 'Waktu Sholat (1)',
        'desc': 'Lihat waktu sholat harianmu di sini.',
        'widget': const PrayerTimesPage(),
      },
      {
        'title': 'Waktu Sholat (2)',
        'desc': 'Jadwal sholat dan fitur tambahan lainnya.',
        'widget': const PrayerTimePage(),
      },
      {
        'title': 'Waktu Sholat (3)',
        'desc': 'Versi lengkap waktu sholat dengan notifikasi.',
        'widget': const SholatPage(),
      },

      {
        'title': 'Home',
        'desc': 'Versi lengkap waktu sholat dengan notifikasi.',
        'widget': const FeatureMenuPage(),
      },
      {
        'title': 'AI',
        'desc': 'Versi lengkap waktu sholat dengan notifikasi.',
        'widget': const VertexAIPage(),
      },
    ];

    return games
        .map(
          (game) => GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => game['widget'] as Widget),
                ),
            child: _buildGameCard(
              game['title'] as String,
              game['desc'] as String,
            ),
          ),
        )
        .toList();
  }

  Widget _buildGameCard(String title, String description) {
    return SizedBox(
      width: 300,
      child: Card(
        elevation: 2,
        color: Colors.grey[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.games, color: Colors.white, size: 64),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A3B45),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  

  Widget _buildBottomNavigationBar(bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 6.0 : 10.0,
        horizontal: 12.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 'Beranda', true, isSmallScreen),
          _buildNavItem(Icons.apps, 'Fitur Menu', false, isSmallScreen),
          _buildNavItem(Icons.article, 'Buletin', false, isSmallScreen),
          _buildNavItem(Icons.person, 'Profil', false, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isSelected,
    bool isSmallScreen,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? Colors.blue : Colors.grey,
          size: isSmallScreen ? 22 : 26,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 10 : 12,
            color: isSelected ? Colors.blue : Colors.grey,
          ),
        ),
      ],
    );
  }
}


