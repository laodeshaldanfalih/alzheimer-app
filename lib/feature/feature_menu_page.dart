import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:project/feature/feature_menu_item.dart';
import 'package:project/firebase/firebase_image_handler.dart';
import 'package:project/menu_game.dart';
import 'package:project/sholat/sholat_page.dart';

class FeatureMenuPage extends StatelessWidget {
  const FeatureMenuPage({super.key});

  List<FeatureMenuItem> get features => [
    FeatureMenuItem(
      title: 'Pengingat Obat',
      description: 'Lorem ipsum is a dummy or placeholder text commonly',
      imagePath: 'assets/images/gallery.png',
      onTap: (context) {
        // TODO: Navigate to Medicine Reminder page
      },
    ),
    FeatureMenuItem(
      title: 'Pengingat Kegiatan',
      description: 'Lorem ipsum is a dummy or placeholder text commonly',
      imagePath: 'assets/images/gallery.png',
      onTap: (context) {
        // TODO: Navigate to Activity Reminder page
      },
    ),
    FeatureMenuItem(
      title: 'Game',
      description: 'Lorem ipsum is a dummy or placeholder text commonly',
      imagePath: 'assets/images/gallery.png',
      onTap: (context) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const MenuGame()));
      },
    ),
    FeatureMenuItem(
      title: 'Musik',
      description: 'Lorem ipsum is a dummy or placeholder text commonly',
      imagePath: 'assets/images/gallery.png',
      onTap: (context) {
        // TODO: Navigate to Music page
      },
    ),
    FeatureMenuItem(
      title: 'Alzheimer Scan',
      description: 'Lorem ipsum is a dummy or placeholder text commonly',
      imagePath: 'assets/images/gallery.png',
      onTap: (context) {
        // TODO: Navigate to Alzheimer Scan page
      },
    ),
    FeatureMenuItem(
      title: 'Artikel Kesehatan',
      description: 'Lorem ipsum is a dummy or placeholder text commonly',
      imagePath: 'assets/images/gallery.png',
      onTap: (context) {
        // TODO: Navigate to Health Article page
      },
    ),
    FeatureMenuItem(
      title: 'Chatbot',
      description: 'Lorem ipsum is a dummy or placeholder text commonly',
      imagePath: 'assets/images/gallery.png',
      onTap: (context) {
        // TODO: Navigate to Chatbot page
      },
    ),
    FeatureMenuItem(
      title: 'Waktu Sholat',
      description: 'Lorem ipsum is a dummy or placeholder text commonly',
      imagePath: 'images/fiturAplikasi/sholat_image.jpg',
      onTap: (context) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const SholatPage()));
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                    return _buildFeatureCard(context, feature);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, FeatureMenuItem feature) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => feature.onTap(context),
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
                    child: FutureBuilder<String>(
                      future: getImageUrl(feature.imagePath),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Image.asset('assets/images/gallery.png'),
                          );
                        } else if (snapshot.hasError) {
                          return Image.asset('assets/images/gallery.png');
                        } else {
                          return CachedNetworkImage(
                            imageUrl: snapshot.data!,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            errorWidget:
                                (context, url, error) =>
                                    Image.asset('assets/images/gallery.png'),
                          );
                        }
                      },
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
