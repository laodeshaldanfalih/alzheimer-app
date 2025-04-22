import 'package:flutter/material.dart';
import 'package:project/features/game/presentation/pages/game_menu_page.dart';
import 'package:project/features/menu/domain/models/feature_menu_item.dart';
import 'package:project/features/reminder/presentation/reminder_menu_page.dart';
import 'package:project/features/alzheimer_scan/presentation/pages/alzheimer_scan_page.dart';

class FeatureMenuPage extends StatelessWidget {
  const FeatureMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<FeatureMenuItem> features = [
      FeatureMenuItem(
        title: 'Pengingat Obat',
        description: 'Lorem ipsum is a dummy or placeholder text commonly',
        emoji: '💊',
        onTap: () {
          // TODO: Navigate to Medicine Reminder page
        },
      ),
      FeatureMenuItem(
        title: 'Pengingat Kegiatan',
        description: 'Lorem ipsum is a dummy or placeholder text commonly',
        emoji: '📅',
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => ReminderMenuPage()));
        },
      ),
      FeatureMenuItem(
        title: 'Game',
        description: 'Lorem ipsum is a dummy or placeholder text commonly',
        emoji: '🎮',
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => GameMenuPage()));
        },
      ),
      FeatureMenuItem(
        title: 'Musik',
        description: 'Lorem ipsum is a dummy or placeholder text commonly',
        emoji: '🎵',
        onTap: () {
          // TODO: Navigate to Music page
        },
      ),
      FeatureMenuItem(
        title: 'Alzheimer Scan',
        description: 'Lorem ipsum is a dummy or placeholder text commonly',
        emoji: '🧠',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AlzheimerScanPage()),
          );
        },
      ),
      FeatureMenuItem(
        title: 'Artikel Kesehatan',
        description: 'Lorem ipsum is a dummy or placeholder text commonly',
        emoji: '📰',
        onTap: () {
          // TODO: Navigate to Health Article page
        },
      ),
      FeatureMenuItem(
        title: 'Chatbot',
        description: 'Lorem ipsum is a dummy or placeholder text commonly',
        emoji: '🤖',
        onTap: () {
          // TODO: Navigate to Chatbot page
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Fitur Aplikasi',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: features.length,
                  itemBuilder: (context, index) {
                    final feature = features[index];
                    return _buildFeatureCard(feature);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(FeatureMenuItem feature) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: feature.onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      feature.emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                feature.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 3),
              Text(
                feature.description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  height: 1.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
