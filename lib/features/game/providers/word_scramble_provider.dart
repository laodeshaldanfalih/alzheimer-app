import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/features/game/domain/models/ws_game_settings.dart';
import 'package:project/features/game/domain/models/ws_word_data.dart';
// Sesuaikan path jika berbeda:
// Model yang baru dibuat

class WordScrambleProvider extends StatefulWidget {
  final WordScrambleGameSettings settings; // Terima settings

  const WordScrambleProvider({super.key, required this.settings});

  @override
  State<WordScrambleProvider> createState() => _MenyusunKataState();
}

class _MenyusunKataState extends State<WordScrambleProvider> {
  List<WordScrambleWordData> _allWordsFromFirestore = [];
  List<WordScrambleWordData> _filteredWordsForGame =
      []; // Kata yang sudah difilter sesuai settings
  List<WordScrambleWordData> _currentLevelWords =
      []; // Kata untuk level saat ini

  WordScrambleWordData? _currentWordData;
  String _currentWord = '';
  List<String> _scrambledLetters = [];
  List<String> _userInputLetters = [];
  List<bool> _letterUsed = [];

  int _currentWordInLevelIndex =
      0; // Indeks kata saat ini dalam _currentLevelWords
  int _lives = 3;
  int _score = 0;

  bool _isLoadingWords = true;
  String? _loadingError;

  final Random _random = Random();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchAndPrepareWords();
  }

  Future<void> _fetchAndPrepareWords() async {
    if (!mounted) return;
    setState(() {
      _isLoadingWords = true;
      _loadingError = null;
    });
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('permainan_susun_kata').get();

      if (!mounted) return;
      if (snapshot.docs.isEmpty) {
        setState(() {
          _loadingError = "Tidak ada kata ditemukan di database.";
          _isLoadingWords = false;
        });
        return;
      }

      _allWordsFromFirestore =
          snapshot.docs
              .map((doc) => WordScrambleWordData.fromFirestore(doc))
              .where((wordData) => wordData.kataAsli.trim().isNotEmpty)
              .toList();

      if (!mounted) return;
      if (_allWordsFromFirestore.isEmpty) {
        setState(() {
          _loadingError =
              "Daftar kata valid kosong setelah diambil dari database.";
          _isLoadingWords = false;
        });
        return;
      }

      // Filter kata berdasarkan settings
      _filterWordsBasedOnSettings();

      if (_filteredWordsForGame.isEmpty) {
        setState(() {
          _loadingError =
              "Tidak ada kata yang cocok dengan pengaturan Anda (Kategori: ${widget.settings.category}, Kesulitan: ${widget.settings.difficulty}). Coba ubah pengaturan.";
          _isLoadingWords = false;
        });
        return;
      }

      // Tambah kata jika kurang dari 30 (untuk simulasi, idealnya ini proses ETL data terpisah)
      _ensureEnoughWords();

      _startGame();
    } catch (e) {
      print("Error fetching or preparing words: $e");
      if (mounted) {
        setState(() {
          _loadingError =
              "Gagal memuat atau mempersiapkan kata: ${e.toString()}";
          _isLoadingWords = false;
        });
      }
    }
  }

  void _filterWordsBasedOnSettings() {
    _filteredWordsForGame =
        _allWordsFromFirestore.where((word) {
          bool categoryMatch =
              widget.settings.category == "Semua" ||
              word.kategori.toLowerCase() ==
                  widget.settings.category.toLowerCase();
          bool difficultyMatch =
              widget.settings.difficulty == "Semua" ||
              word.levelKesulitan.toLowerCase() ==
                  widget.settings.difficulty.toLowerCase();
          return categoryMatch && difficultyMatch;
        }).toList();
    _filteredWordsForGame.shuffle(_random); // Acak kata yang sudah difilter
  }

  void _ensureEnoughWords() {
    // Jika kata yang difilter kurang dari jumlah maksimal yang diinginkan (30)
    // dan kurang dari jumlah kata per level yang dipilih, kita bisa duplikasi dan acak.
    // Ini adalah penyederhanaan. Idealnya, Anda punya cukup data unik.
    int targetWordCount = 30; // Target maksimal untuk simulasi
    if (_filteredWordsForGame.isNotEmpty &&
        _filteredWordsForGame.length < targetWordCount) {
      print(
        "Peringatan: Kata yang cocok (${_filteredWordsForGame.length}) kurang dari target ${targetWordCount}. Menduplikasi kata...",
      );
      List<WordScrambleWordData> tempWords = List.from(_filteredWordsForGame);
      while (_filteredWordsForGame.length < targetWordCount) {
        _filteredWordsForGame.addAll(
          tempWords.map((w) => w),
        ); // Buat salinan baru
        if (_filteredWordsForGame.length >= targetWordCount) break;
        if (tempWords.isEmpty)
          break; // Hindari loop tak terbatas jika sumbernya kosong
      }
      _filteredWordsForGame =
          _filteredWordsForGame.take(targetWordCount).toList();
      _filteredWordsForGame.shuffle(_random);
      print(
        "Jumlah kata setelah duplikasi (maks ${targetWordCount}): ${_filteredWordsForGame.length}",
      );
    }
  }

  void _startGame() {
    if (!mounted) return;
    _lives = 3;
    _score = 0;
    // _availableWordsToPickFrom = List.from(_filteredWordsForGame); // Semua kata yang mungkin untuk game ini
    _prepareNextLevelWords();
  }

  void _prepareNextLevelWords() {
    if (!mounted) return;

    // Ambil sejumlah kata untuk level ini dari _filteredWordsForGame
    // Kita perlu melacak kata mana yang sudah digunakan secara keseluruhan jika tidak ingin pengulangan antar level
    // Untuk sekarang, kita anggap _filteredWordsForGame adalah pool yang bisa diambil berulang jika perlu
    // atau kita bisa buat _availableWordsToPickFrom dan menghapusnya.

    if (_filteredWordsForGame.isEmpty) {
      _showGameDialog(
        "Luar Biasa!",
        "Semua kata untuk pengaturan ini telah dimainkan!\nSkor Akhir: $_score",
      );
      setStateIfMounted(() {
        _isLoadingWords = false; // Selesai
      });
      return;
    }

    _currentLevelWords = [];
    List<WordScrambleWordData> tempPool = List.from(
      _filteredWordsForGame,
    ); // Salinan untuk mengambil kata
    tempPool.shuffle(_random);

    for (int i = 0; i < widget.settings.wordsPerLevel; i++) {
      if (tempPool.isNotEmpty) {
        _currentLevelWords.add(
          tempPool.removeAt(0 % tempPool.length),
        ); // Modulo untuk keamanan jika pool < wordsPerLevel
      } else {
        // Jika pool habis, bisa diisi ulang atau game berakhir
        // Untuk sekarang, kita anggap pool cukup atau akan diduplikasi di _ensureEnoughWords
        break;
      }
    }

    if (_currentLevelWords.isEmpty) {
      _showGameDialog(
        "Kesalahan",
        "Tidak ada kata yang bisa disiapkan untuk level ini.",
      );
      setStateIfMounted(() => _isLoadingWords = false);
      return;
    }

    _currentWordInLevelIndex = 0;
    _loadWord();
  }

  void _loadWord() {
    if (!mounted ||
        _currentLevelWords.isEmpty ||
        _currentWordInLevelIndex >= _currentLevelWords.length) {
      // Level selesai, siapkan level berikutnya atau akhiri game
      _showLevelCompleteDialog();
      return;
    }

    _currentWordData = _currentLevelWords[_currentWordInLevelIndex];
    _currentWord = _currentWordData!.kataAsli.trim().toLowerCase();

    if (_currentWord.isEmpty) {
      print(
        "Peringatan: Kata asli kosong saat memuat kata ke-${_currentWordInLevelIndex + 1}. Mencoba kata berikutnya.",
      );
      _currentWordInLevelIndex++; // Coba kata berikutnya di level ini
      _loadWord(); // Rekursif untuk memuat kata valid berikutnya
      return;
    }

    List<String> letters = _currentWord.split('');
    letters.shuffle(_random);
    _scrambledLetters = List.from(letters);

    _userInputLetters = [];
    _letterUsed = List.generate(_scrambledLetters.length, (_) => false);

    setStateIfMounted(() {
      _isLoadingWords = false;
    });
  }

  void setStateIfMounted(VoidCallback f) {
    if (mounted) {
      setState(f);
    }
  }

  void _onLetterTapped(int index) {
    if (_letterUsed[index]) return;
    setStateIfMounted(() {
      _userInputLetters.add(_scrambledLetters[index]);
      _letterUsed[index] = true;
    });
  }

  void _onUndoLetter() {
    if (_userInputLetters.isEmpty) return;
    setStateIfMounted(() {
      String lastLetterRemoved = _userInputLetters.removeLast();
      for (int i = _scrambledLetters.length - 1; i >= 0; i--) {
        if (_scrambledLetters[i] == lastLetterRemoved && _letterUsed[i]) {
          _letterUsed[i] = false;
          break;
        }
      }
    });
  }

  void _checkAnswer() {
    String userAnswer = _userInputLetters.join();
    if (userAnswer == _currentWord) {
      _score += 10;
      _showFeedbackDialog(
        "Benar!",
        "Kata yang benar: ${_currentWordData?.kataAsli.toUpperCase()}",
        true,
      );
    } else {
      _lives--;
      if (_lives > 0) {
        _showFeedbackDialog(
          "Salah!",
          "Coba lagi. Nyawa tersisa: $_lives",
          false,
        );
        setStateIfMounted(() {
          _userInputLetters = [];
          _letterUsed = List.generate(_scrambledLetters.length, (_) => false);
        });
      } else {
        _showGameDialog(
          "Gagal!",
          "Nyawa habis. Skor akhir: $_score.\nPermainan Selesai.",
        );
      }
    }
  }

  void _proceedToNextWordOrLevel() {
    _currentWordInLevelIndex++;
    if (_currentWordInLevelIndex >= _currentLevelWords.length ||
        _currentWordInLevelIndex >= widget.settings.wordsPerLevel) {
      // Selesai semua kata dalam "level" ini (sejumlah wordsPerLevel)
      _showLevelCompleteDialog();
    } else {
      _loadWord(); // Muat kata berikutnya dalam "level" yang sama
    }
  }

  void _showLevelCompleteDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.celebration, size: 60, color: Colors.amber[600]),
                const SizedBox(height: 16),
                Text(
                  "Level Selesai!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "Skor saat ini: $_score",
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Apa yang ingin Anda lakukan?",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Column(
                  children: [
                    // Tombol Ulangi Permainan
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue[600],
                          side: BorderSide(color: Colors.blue[600]!),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          setStateIfMounted(() {
                            _score = 0;
                            _lives = 3;
                            _isLoadingWords = true;
                          });
                          _fetchAndPrepareWords();
                        },
                        child: const Text(
                          'Ulangi Permainan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tombol Kembali ke Halaman Utama
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange[600],
                          side: BorderSide(color: Colors.orange[600]!),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Tutup dialog saat ini
                          // Setelah dialog ditutup, 'context' masih mengacu pada MenyusunKata
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(
                              context,
                            ).pop(); // Kembali ke LandingpageMenyusunKata
                          }
                        },
                        child: const Text(
                          'Kembali ke Halaman Utama',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFeedbackDialog(String title, String content, bool isCorrect) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.error,
                  size: 60,
                  color: isCorrect ? Colors.green[600] : Colors.red[600],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green[800] : Colors.red[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  content,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                if (_currentWordData?.petunjuk != null &&
                    _currentWordData!.petunjuk.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      "Petunjuk: ${_currentWordData!.petunjuk}",
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.blueGrey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isCorrect ? Colors.green[600] : Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (isCorrect) {
                        _proceedToNextWordOrLevel();
                      }
                    },
                    child: Text(
                      'Lanjut',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGameDialog(String title, String content) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  title == "Gagal!" ? Icons.sentiment_dissatisfied : Icons.flag,
                  size: 60,
                  color: title == "Gagal!" ? Colors.red[600] : Colors.blue[600],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color:
                        title == "Gagal!" ? Colors.red[800] : Colors.blue[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  content,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Tutup dialog saat ini
                          // Setelah dialog ditutup, 'context' masih mengacu pada MenyusunKata
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(
                              context,
                            ).pop(); // Kembali ke LandingpageMenyusunKata
                          }
                        },
                        child: const Text(
                          'Kembali ke Pengaturan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (title == "Gagal!") ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange[600],
                            side: BorderSide(color: Colors.orange[600]!),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            setStateIfMounted(() {
                              _lives = 3;
                              _isLoadingWords = true;
                            });
                            _fetchAndPrepareWords();
                          },
                          child: const Text(
                            'Coba Lagi Level Ini',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (bagian loading dan error tetap sama) ...
    if (_isLoadingWords) {
      return Scaffold(
        body: Center(
          child:
              _loadingError != null
                  ? Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _loadingError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_loadingError!.contains(
                              "Tidak ada kata yang cocok",
                            )) {
                              Navigator.of(
                                context,
                              ).pop(); // Kembali ke settings page
                            } else {
                              _fetchAndPrepareWords();
                            }
                          },
                          child: Text(
                            _loadingError!.contains("Tidak ada kata yang cocok")
                                ? "Ubah Pengaturan"
                                : "Coba Lagi",
                          ),
                        ),
                      ],
                    ),
                  )
                  : const CircularProgressIndicator(),
        ),
      );
    }

    if (_currentWord.isEmpty && !_isLoadingWords && _loadingError == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Tidak ada kata valid untuk dimainkan saat ini.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed:
                      () => Navigator.of(
                        context,
                      ).popUntil((route) => route.isFirst),
                  child: const Text("Kembali ke Pengaturan"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final appBarHeight = AppBar().preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final minBodyHeight =
        screenHeight - appBarHeight - statusBarHeight - bottomPadding;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue.shade700, elevation: 0),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minBodyHeight),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade100, Colors.blue.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoChip(
                            "Tebakan",
                            "${_currentWordInLevelIndex + 1}/${widget.settings.wordsPerLevel}",
                            Icons.format_list_numbered,
                            Colors.blue.shade700,
                          ),
                          _buildInfoChip(
                            "Skor",
                            "$_score",
                            Icons.emoji_events_outlined,
                            Colors.green.shade600,
                          ),
                          _buildInfoChip(
                            "Nyawa",
                            "$_lives",
                            Icons.favorite_border,
                            Colors.red.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (_currentWordData != null &&
                      _currentWordData!.petunjuk.isNotEmpty)
                    Card(
                      elevation: 2,
                      color: Colors.white.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 16.0,
                        ),
                        child: Text(
                          "Petunjuk: ${_currentWordData!.petunjuk}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: Colors.blueGrey.shade700,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 10.0,
                    ),
                    margin: const EdgeInsets.only(bottom: 20.0),
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.blue.shade700, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _userInputLetters.join(' ').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),

                  if (_scrambledLetters.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _calculateCrossAxisCount(
                          _scrambledLetters.length,
                        ),
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: _scrambledLetters.length,
                      itemBuilder: (context, index) {
                        return ElevatedButton(
                          onPressed:
                              _letterUsed[index]
                                  ? null
                                  : () => _onLetterTapped(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _letterUsed[index]
                                    ? Colors.grey.shade400
                                    : Colors.blue.shade600,
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: const EdgeInsets.all(8),
                            elevation: _letterUsed[index] ? 0 : 3,
                          ),
                          child: Text(
                            _scrambledLetters[index].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.undo, color: Colors.white),
                        label: const Text(
                          'Undo',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        onPressed:
                            _userInputLetters.isNotEmpty ? _onUndoLetter : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          disabledBackgroundColor: Colors.grey.shade400,
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Periksa',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        onPressed:
                            _userInputLetters.length == _currentWord.length
                                ? _checkAnswer
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          disabledBackgroundColor: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  int _calculateCrossAxisCount(int numberOfLetters) {
    if (numberOfLetters <= 4) return 4;
    if (numberOfLetters <= 6) return 3; // Lebih baik untuk kata 5-6 huruf
    if (numberOfLetters <= 9) return 3;
    if (numberOfLetters <= 12) return 4;
    if (numberOfLetters <= 15) return 5;
    return 5; // Default jika lebih banyak
  }
}
