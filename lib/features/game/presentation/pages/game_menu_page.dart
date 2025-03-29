import 'package:flutter/material.dart';
import 'package:project/features/game/domain/models/game_menu_item.dart';
import 'package:project/features/game/presentation/pages/menyusun_makanan_page.dart';

class GameMenuPage extends StatelessWidget {
  const GameMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<GameMenuItem> games = [
      GameMenuItem(
        title: 'Menyocokkan Warna',
        description:
            'Permainan menyocokkan warna untuk melatih memori dan konsentrasi',
        imagePath: 'assets/images/google_icons.png',
        onTap: () {
          print('Navigate to Color Matching Game');
        },
      ),
      GameMenuItem(
        title: 'Menyusun Makanan',
        description:
            'Permainan menyusun makanan untuk melatih daya ingat dan pengambilan keputusan',
        imagePath: 'assets/images/google_icons.png',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => MenyusunMakananPage()),
          );
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Permainan', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return _buildGameCard(game);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(GameMenuItem game) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: game.onTap,
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(game.imagePath, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                game.title,
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
                game.description,
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
