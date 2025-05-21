import 'package:flutter/material.dart';
import 'package:project/features/game/domain/models/ws_game_settings.dart';
import 'package:project/features/game/providers/word_scramble_provider.dart';

class WordScramblePage extends StatefulWidget {
  const WordScramblePage({super.key});

  @override
  State<WordScramblePage> createState() => _WordScramblePageState();
}

class _WordScramblePageState extends State<WordScramblePage> {
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
  );

  String _selectedCategory = "Semua";
  String _selectedDifficulty = "Semua";
  int _selectedWordsPerLevel = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue.shade700, elevation: 0),
      body: Container(
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    color: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/menyusunKata.png', // PASTIKAN PATH INI BENAR
                          height: 120,
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
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                            backgroundColor:
                                Colors.blue.shade700, // Warna tombol konsisten
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text(
                            'Mulai Bermain',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            final settings = WordScrambleGameSettings(
                              category: _selectedCategory,
                              difficulty: _selectedDifficulty,
                              wordsPerLevel: _selectedWordsPerLevel,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => WordScrambleProvider(
                                      settings: settings,
                                    ),
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
