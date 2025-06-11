import 'package:project/features/article/models/article_item.dart';

final List<ArticleItem> articlesAG = [
// Add these to your article_data.dart file

const ArticleItem(
  title: "Panduan Asesmen MMSE untuk Deteksi Gangguan Kognitif",
  description: 
      "Mini-Mental State Examination (MMSE) merupakan alat skrining standar untuk menilai fungsi kognitif pada lansia. Pelajari cara administrasi dan interpretasi hasilnya.",
  content: """
Apa itu MMSE?
Mini-Mental State Examination (MMSE) adalah alat skrining kognitif yang terdiri dari 11 item dengan skor maksimal 30 poin. MMSE menilai berbagai domain kognitif termasuk:

1. Orientasi (10 poin):
   - Waktu: tahun, musim, tanggal, hari, bulan
   - Tempat: negara, provinsi, kota, rumah sakit, lantai

2. Registrasi (3 poin):
   - Mengingat 3 benda (apel, meja, koin)

3. Perhatian dan Kalkulasi (5 poin):
   - Berhitung mundur 7 dari 100 (alternatif: mengeja "DUNIA" terbalik)

4. Recall (3 poin):
   - Mengingat kembali 3 benda yang disebutkan sebelumnya

5. Bahasa dan Praksis (9 poin):
   - Penamaan benda (2 poin)
   - Mengulang kalimat (1 poin)
   - Perintah 3 tahap (3 poin)
   - Membaca dan mengikuti perintah (1 poin)
   - Menulis kalimat spontan (1 poin)
   - Menyalin gambar pentagon (1 poin)

Interpretasi Hasil:
- 24-30: Normal
- 18-23: Gangguan kognitif ringan
- 0-17: Gangguan kognitif berat

Keterbatasan:
- Dipengaruhi tingkat pendidikan
- Kurang sensitif untuk deteksi dini
- Tidak membedakan jenis demensia

Sumber: Folstein et al. (1975), Crum et al. (1993)
""",
  imagePath: "https://images.unsplash.com/photo-1579684385127-1ef15d508118?q=80&w=1000",
),

const ArticleItem(
  title: "Panduan Asesmen GDS untuk Deteksi Depresi Lansia",
  description: 
      "Geriatric Depression Scale (GDS) adalah instrumen spesifik untuk mendeteksi gejala depresi pada populasi lanjut usia. Ketahui versi singkat 15 item dan interpretasinya.",
  content: """
Apa itu GDS?
Geriatric Depression Scale (GDS) dikembangkan khusus untuk lansia dengan format pertanyaan ya/tidak yang sederhana. Terdapat dua versi:
- GDS-30 item (versi lengkap)
- GDS-15 item (versi singkat)

Karakteristik GDS-15:
- Waktu administrasi: 5-7 menit
- Format: 15 pertanyaan ya/tidak
- Skor maksimal: 15
- Titik potong:
  - ≥6: Depresi (sensitivitas 80.5%, spesifisitas 75%)
  - ≥5 pada rawat jalan geriatri (sensitivitas 92%, spesifisitas 87%)

Pertanyaan Kunci:
1. Apakah Anda puas dengan kehidupan Anda?
2. Apakah Anda merasa hidup Anda kosong?
3. Apakah Anda takut sesuatu yang buruk akan terjadi?
4. Apakah Anda merasa tidak berdaya?
5. Apakah Anda merasa tidak berharga?

Keunggulan:
- Mudah digunakan oleh tenaga non-profesional
- Tidak memerlukan pelatihan khusus
- Valid untuk lansia dengan fungsi kognitif intak

Keterbatasan:
- Kurang valid untuk lansia dengan demensia berat
- Hasil bisa dipengaruhi oleh kondisi medis akut

Sumber: Yesavage et al. (1983), Wongpakaran et al. (2013)
""",
  imagePath: "https://images.unsplash.com/photo-1530026186672-2cd00ffc50fe?q=80&w=1000",
),

const ArticleItem(
  title: "Panduan Asesmen SKILAS untuk Skrining Lansia",
  description: 
      "SKrining Lansia Sederhana (SKILAS) adalah instrumen praktis untuk deteksi dini masalah kesehatan lansia di komunitas. Pelajari 10 domain penilaiannya.",
  content: """
Apa itu SKILAS?
SKILAS adalah checklist 10 item yang dikembangkan oleh Kemenkes RI untuk skrining cepat masalah kesehatan lansia oleh kader/keluarga.

Domain Penilaian:
1. Fungsi Kognitif:
   - Daya ingat jangka pendek
   - Orientasi waktu/tempat

2. Mobilitas:
   - Kemampuan berjalan/berdiri
   - Risiko jatuh

3. Status Nutrisi:
   - Penurunan berat badan tidak disengaja
   - Nafsu makan

4. Penglihatan dan Pendengaran:
   - Kesulitan melihat/mendengar
   - Penggunaan alat bantu

5. Gejala Depresi:
   - Perasaan sedih/tidak berharga
   - Minat terhadap aktivitas

Skoring:
- Setiap item dinilai 0 (tidak ada masalah) atau 1 (ada masalah)
- Skor ≥1 menunjukkan perlunya rujukan ke fasilitas kesehatan

Keunggulan:
- Waktu administrasi <10 menit
- Dapat digunakan oleh kader terlatih
- Mencakup aspek multidimensi
- Sensitif untuk deteksi dini penurunan fungsi

Implementasi:
- Dilakukan setiap 3-6 bulan
- Hasil menjadi dasar untuk:
  - Edukasi keluarga
  - Modifikasi lingkungan rumah
  - Rujukan ke puskesmas

Sumber: Kemenkes RI (2019), WHO (2019)
""",
  imagePath: "https://images.unsplash.com/photo-1505751172876-fa1923c5c528?q=80&w=1000",
),
];