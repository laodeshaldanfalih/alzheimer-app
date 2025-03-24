import 'package:flutter/material.dart';
import 'package:project/color_game.dart';
import 'package:project/responsive/responsive_meal_planning_game.dart';

class MenuGame extends StatelessWidget {
  const MenuGame({super.key});

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar
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
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
              child: isSmallScreen
                  // Layout kolom untuk layar kecil
                  ? Column(
                      children: [
                        Expanded(
                          child: _buildGameCardGesture(
                            context,
                            'Mencocokkan Warna',
                            'Lorem ipsum is a dummy or placeholder text commonly',
                            const ColorGame(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _buildGameCardGesture(
                            context,
                            'Menyusun Makanan',
                            'Lorem ipsum is a dummy or placeholder text commonly',
                            const ResponsiveMealPlanningGame(),
                          ),
                        ),
                      ],
                    )
                  // Layout baris untuk layar besar
                  : Row(
                      children: [
                        Expanded(
                          child: _buildGameCardGesture(
                            context,
                            'Mencocokkan Warna',
                            'Lorem ipsum is a dummy or placeholder text commonly',
                            const ColorGame(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildGameCardGesture(
                            context,
                            'Menyusun Makanan',
                            'Lorem ipsum is a dummy or placeholder text commonly',
                            const ResponsiveMealPlanningGame(),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          _buildBottomNavigationBar(isSmallScreen),
        ],
      ),
    );
  }

  // Widget kartu game dengan gesture detector
  Widget _buildGameCardGesture(
    BuildContext context,
    String title,
    String description,
    Widget destination,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => destination,
          ),
        );
      },
      child: _buildGameCard(title, description),
    );
  }

  Widget _buildGameCard(String title, String description) {
    return Card(
      elevation: 0,
      color: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3A3B45),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 6.0 : 8.0,
          horizontal: isSmallScreen ? 4.0 : 8.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home, 'Beranda', isSelected: true, isSmallScreen: isSmallScreen),
            _buildNavItem(Icons.apps, 'Fitur Menu', isSmallScreen: isSmallScreen),
            _buildNavItem(Icons.article, 'Buletin', isSmallScreen: isSmallScreen),
            _buildNavItem(Icons.person, 'Profil', isSmallScreen: isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool isSelected = false, bool isSmallScreen = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? Colors.blue : Colors.grey,
          size: isSmallScreen ? 20 : 24,
        ),
        const SizedBox(height: 2),
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