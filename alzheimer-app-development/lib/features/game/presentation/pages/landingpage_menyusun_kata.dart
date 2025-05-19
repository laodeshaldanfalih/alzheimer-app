import 'package:flutter/material.dart';
import 'ws_game_settings.dart'; // Model yang baru dibuat
import 'menyusun_kata.dart'; // Halaman game utama
// Asumsi word_data.dart ada di lokasi yang bisa dijangkau
// import 'package:project/features/game/presentation/pages/word_data.dart';
// Untuk mendapatkan daftar kategori dan kesulitan, kita bisa hardcode atau ambil dari data
// Untuk contoh ini, kita hardcode dulu daftarnya

class LandingpageMenyusunKata extends StatefulWidget {
  const LandingpageMenyusunKata({super.key});

  @override
  State<LandingpageMenyusunKata> createState() =>
      _LandingpageMenyusunKataState();
}

class _LandingpageMenyusunKataState extends State<LandingpageMenyusunKata> {
  // Contoh daftar, idealnya diambil dari data unik di Firestore/JSON
  final List<String> _categories = [
    "Semua",
    "Buah",
    "Hewan",
    "Kata Kerja",
    "Benda di Rumah",
    "Transportasi",
    "Tempat",
  ];
  final List<String> _difficulties = ["Semua", "Mudah", "Sedang", "Sulit"];
  final List<int> _wordsPerLevelOptions = List.generate(
    6,
    (index) => (index + 1) * 5,
  ); // 5, 10, ..., 30

  String _selectedCategory = "Semua";
  String _selectedDifficulty = "Semua";
  int _selectedWordsPerLevel = 5;

@override
Widget build(BuildContext context) {
  return Scaffold(
    // AppBar tidak diubah, tetap seperti sebelumnya
    appBar: AppBar(
      title: const Text('Pengaturan Game Susun Kata'),
      backgroundColor: Colors.blue.shade700,
      elevation: 0, // AppBar menyatu dengan body
    ),
    body: Container( // Container untuk gradient background utama
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.blue.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            clipBehavior: Clip.antiAlias, // Penting agar warna Container tidak keluar dari rounded corners Card
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // --- Area Logo dan Judul dengan Warna Latar Belakang ---
                Container( // Widget Container untuk memberi warna latar
                  // Warna biru solid seperti pada gambar referensi Anda
                  // Anda bisa menggunakan Colors.blue.shade700 atau warna spesifik lainnya
                  color: Colors.blue.shade700, // GANTI DENGAN WARNA YANG DIINGINKAN
                  padding: const EdgeInsets.symmetric(vertical: 20.0), // Padding internal untuk area logo
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/menyusunKata.png', // PASTIKAN PATH INI BENAR
                        height: 120, // Tinggi logo bisa disesuaikan
                        // Jika logo Anda sudah termasuk teks "Menyusun Kata!", maka Text di bawah ini tidak perlu
                        // errorBuilder tetap berguna
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: Text(
                                'Logo Gagal Dimuat',
                                style: TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                      // Jika logo Anda TIDAK termasuk teks "Menyusun Kata!", aktifkan Text ini:
                      /*
                      const SizedBox(height: 8),
                      Text(
                        'Menyusun Kata!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Warna teks agar kontras dengan background biru
                        ),
                      ),
                      */
                    ],
                  ),
                ),
                // --- Akhir Area Logo dan Judul ---

                // --- Area Form dengan Padding Internal ---
                Padding(
                  padding: const EdgeInsets.all(24.0), // Padding untuk semua sisi form
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Pilihan Kategori
                      _buildDropdown<String>(
                        label: 'Kategori:',
                        value: _selectedCategory,
                        items: _categories,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Pilihan Tingkat Kesulitan
                      _buildDropdown<String>(
                        label: 'Tingkat Kesulitan:',
                        value: _selectedDifficulty,
                        items: _difficulties,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedDifficulty = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Pilihan Jumlah Kata per Level
                      _buildDropdown<int>(
                        label: 'Jumlah Kata per Level:',
                        value: _selectedWordsPerLevel,
                        items: _wordsPerLevelOptions,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedWordsPerLevel = value;
                            });
                          }
                        },
                        itemLabelBuilder: (item) => '$item kata',
                      ),
                      const SizedBox(height: 40),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700, // Warna tombol konsisten
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Mulai Bermain', style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          final settings = GameSettings(
                            category: _selectedCategory,
                            difficulty: _selectedDifficulty,
                            wordsPerLevel: _selectedWordsPerLevel,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MenyusunKata(settings: settings),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // --- Akhir Area Form ---
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String Function(T)? itemLabelBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.blueGrey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.blue.shade300, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              value: value,
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: Colors.blue.shade700,
              ),
              elevation: 8,
              style: TextStyle(color: Colors.blue.shade900, fontSize: 16),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              items:
                  items.map<DropdownMenuItem<T>>((T item) {
                    return DropdownMenuItem<T>(
                      value: item,
                      child: Text(
                        itemLabelBuilder != null
                            ? itemLabelBuilder(item)
                            : item.toString(),
                      ),
                    );
                  }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
