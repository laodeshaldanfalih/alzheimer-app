// lib/features/game/domain/models/ws_word_data.dart

//   WS = WORD SCRAMBLE = MENYUSUN KATA

class WordScrambleWordData {
  final String id; // ID Dokumen dari indeks list lokal
  final String kataAsli;
  final String petunjuk;
  final String levelKesulitan;
  final String kategori;
  final int panjangKata;

  WordScrambleWordData({
    required this.id,
    required this.kataAsli,
    required this.petunjuk,
    required this.levelKesulitan,
    required this.kategori,
    required this.panjangKata,
  });

  // Mengubah factory dari Firestore menjadi fromMap
  factory WordScrambleWordData.fromMap(Map<String, dynamic> data, String id) {
    return WordScrambleWordData(
      id: id,
      kataAsli: data['kataAsli'] ?? '',
      petunjuk: data['petunjuk'] ?? 'Tidak ada petunjuk.',
      levelKesulitan: data['levelKesulitan'] ?? 'sedang',
      kategori: data['kategori'] ?? 'umum',
      panjangKata:
          data['panjangKata'] is int
              ? data['panjangKata']
              : (data['kataAsli'] as String? ?? '').length,
    );
  }
}