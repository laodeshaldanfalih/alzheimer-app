import 'package:cloud_firestore/cloud_firestore.dart';


//   WS = WORD SCRAMBLE = MENYUSUN KATA

class WordData {
  final String id; // ID Dokumen dari Firestore
  final String kataAsli;
  final String petunjuk;
  final String levelKesulitan;
  final String kategori;
  final int panjangKata;

  WordData({
    required this.id,
    required this.kataAsli,
    required this.petunjuk,
    required this.levelKesulitan,
    required this.kategori,
    required this.panjangKata,
  });

  factory WordData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WordData(
      id: doc.id,
      kataAsli: data['kataAsli'] ?? '',
      petunjuk: data['petunjuk'] ?? 'Tidak ada petunjuk.',
      levelKesulitan: data['levelKesulitan'] ?? 'sedang',
      kategori: data['kategori'] ?? 'umum',
      panjangKata: data['panjangKata'] is int ? data['panjangKata'] : (data['kataAsli'] as String? ?? '').length,
    );
  }
}