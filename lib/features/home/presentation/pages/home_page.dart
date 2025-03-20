import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project/core/providers/auth_provider.dart';
import 'package:project/features/auth/presentation/pages/signin_page.dart';
import 'package:project/features/home/domain/models/quick_feature_item.dart';
import 'package:project/features/home/domain/models/article_item.dart';
import 'package:project/features/home/presentation/pages/article_detail_page.dart';

class HomePage extends ConsumerWidget {
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

  final List<ArticleItem> articles = [
    ArticleItem(
      title: "Tips Menjaga Kesehatan Mental Lansia",
      description:
          "Kesehatan mental sama pentingnya dengan kesehatan fisik bagi lansia. Simak tips-tips praktis untuk menjaga kesehatan mental orang tua dan kakek nenek kita.",
      content: """
Menjaga kesehatan mental lansia merupakan aspek penting dalam merawat orang tua atau kakek nenek kita. Berikut adalah beberapa cara efektif yang dapat dilakukan:

1. Jaga Interaksi Sosial
   - Luangkan waktu untuk mengobrol dan mendengarkan cerita mereka
   - Libatkan dalam aktivitas keluarga
   - Dorong untuk tetap berhubungan dengan teman-teman mereka

2. Aktivitas Fisik Teratur
   - Ajak jalan-jalan pagi atau sore
   - Lakukan senam ringan bersama
   - Berkebun atau aktivitas ringan lainnya

3. Stimulasi Mental
   - Bermain puzzle atau teka-teki silang
   - Membaca buku atau koran
   - Menulis diary atau kenangan

4. Pola Hidup Teratur
   - Jadwal tidur yang konsisten
   - Makan tepat waktu
   - Rutinitas harian yang terstruktur

5. Dukungan Emosional
   - Tunjukkan kasih sayang
   - Berikan pujian dan apresiasi
   - Dengarkan keluhan dengan sabar
""",
      imageUrl:
          "https://images.unsplash.com/photo-1516307365426-bea591f05011?q=80&w=1000",
    ),
    ArticleItem(
      title: "Manfaat Musik untuk Penderita Alzheimer",
      description:
          "Terapi musik terbukti memiliki dampak positif bagi penderita Alzheimer. Penelitian menunjukkan musik dapat membantu meningkatkan mood dan memori.",
      content: """
Musik memiliki kekuatan luar biasa dalam membantu penderita Alzheimer. Berikut adalah beberapa manfaat utama terapi musik:

1. Meningkatkan Mood
   - Musik familiar dapat membangkitkan emosi positif
   - Mengurangi tingkat stress dan kecemasan
   - Menciptakan suasana hati yang lebih baik

2. Membantu Memori
   - Musik dari masa lalu dapat memicu kenangan
   - Membantu mengingat lirik dan melodi
   - Merangsang aktivitas otak

3. Meningkatkan Interaksi Sosial
   - Menciptakan momen berbagi dengan keluarga
   - Mendorong komunikasi non-verbal
   - Memfasilitasi koneksi emosional

4. Manfaat Fisik
   - Merangsang pergerakan dan koordinasi
   - Membantu relaksasi otot
   - Meningkatkan kualitas tidur

5. Aplikasi Praktis
   - Pilih musik yang familiar dari masa muda mereka
   - Gunakan musik sebagai bagian dari rutinitas harian
   - Kombinasikan dengan aktivitas fisik ringan
""",
      imageUrl:
          "https://images.unsplash.com/photo-1415201364774-f6f0bb35f28f?q=80&w=1000",
    ),
    ArticleItem(
      title: "Pentingnya Aktivitas Fisik untuk Lansia",
      description:
          "Aktivitas fisik teratur dapat membantu lansia menjaga kesehatan, kemandirian, dan kualitas hidup. Temukan jenis olahraga yang aman dan bermanfaat.",
      content: """
Aktivitas fisik merupakan kunci untuk menjaga kesehatan dan kemandirian lansia. Berikut panduan lengkap tentang aktivitas fisik untuk lansia:

1. Manfaat Aktivitas Fisik
   - Menjaga kekuatan otot dan keseimbangan
   - Mengurangi risiko jatuh
   - Meningkatkan kesehatan jantung
   - Membantu kontrol berat badan

2. Jenis Aktivitas yang Direkomendasikan
   - Jalan kaki
   - Senam lansia
   - Yoga ringan
   - Tai Chi
   - Berenang

3. Tips Keamanan
   - Mulai dengan intensitas rendah
   - Tingkatkan secara bertahap
   - Perhatikan tanda-tanda kelelahan
   - Konsultasi dengan dokter sebelum memulai

4. Jadwal yang Disarankan
   - 150 menit aktivitas ringan per minggu
   - Dibagi dalam 3-5 sesi
   - Sesuaikan dengan kondisi fisik

5. Cara Memotivasi
   - Lakukan bersama teman atau keluarga
   - Tetapkan target sederhana
   - Catat kemajuan
   - Rayakan pencapaian
""",
      imageUrl:
          "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=1000",
    ),
    ArticleItem(
      title: "Nutrisi Seimbang untuk Kesehatan Lansia",
      description:
          "Pola makan yang tepat sangat penting untuk menjaga kesehatan lansia. Pelajari panduan nutrisi seimbang dan tips memilih makanan yang tepat.",
      content: """
Nutrisi yang tepat adalah fondasi kesehatan yang baik bagi lansia. Berikut panduan lengkap tentang nutrisi seimbang:

1. Kebutuhan Nutrisi Utama
   - Protein untuk menjaga massa otot
   - Kalsium untuk kesehatan tulang
   - Serat untuk pencernaan
   - Vitamin D untuk imunitas
   - Omega-3 untuk kesehatan otak

2. Makanan yang Direkomendasikan
   - Ikan dan daging tanpa lemak
   - Sayuran hijau
   - Buah-buahan segar
   - Produk susu rendah lemak
   - Kacang-kacangan

3. Tips Makan
   - Porsi kecil tapi sering
   - Kunyah makanan dengan baik
   - Minum air putih yang cukup
   - Hindari makanan terlalu asin atau manis

4. Tantangan Umum
   - Nafsu makan berkurang
   - Kesulitan mengunyah
   - Gangguan pencernaan
   - Interaksi dengan obat-obatan

5. Solusi Praktis
   - Sajikan makanan menarik
   - Makan bersama keluarga
   - Sesuaikan tekstur makanan
   - Konsultasi dengan ahli gizi
""",
      imageUrl:
          "https://images.unsplash.com/photo-1498837167922-ddd27525d352?q=80&w=1000",
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate width for each item (4 items per row)
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth =
        (screenWidth - 60 - (3 * 10)) / 4; // Total padding: 60, gaps: 3 * 10

    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          "Halo, Afanda Mirza Lutfirahman",
          style: TextStyle(fontSize: 12, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
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
                          children: const [
                            Text(
                              "14:30",
                              style: TextStyle(
                                color: Color(0xffFFECCC),
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Rabu, 5 Februari 2025",
                              style: TextStyle(
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
                            quickFeatures
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
                      ? Image.network(article.imageUrl!, fit: BoxFit.cover)
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
