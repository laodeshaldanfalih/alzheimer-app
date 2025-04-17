import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class PrayerTimeService {
  /// Ambil koordinat dari lokasi saat ini
  Future<Position> getCurrentPosition() async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      return Future.error('Location services are disabled.');
    }
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Ambil nama lokasi dari koordinat
  Future<String> getLocationName(double lat, double long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      return "${place.subAdministrativeArea ?? '-'}, ${place.locality ?? '-'}, ${place.administrativeArea ?? '-'}";
    } else {
      return "Lokasi tidak ditemukan";
    }
  }

  /// Ambil waktu salat dari API myQuran berdasarkan koordinat
 Future<Map<String, dynamic>> fetchPrayerTimes(double lat, double long) async {
  try {
    // 1. Ambil nama kota dari koordinat
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    if (placemarks.isEmpty) throw Exception("Tidak bisa menemukan lokasi.");

    final city = placemarks.first.locality ?? placemarks.first.subAdministrativeArea;
    if (city == null || city.isEmpty) throw Exception("Nama kota tidak ditemukan.");

    // 2. Ambil ID kota dari API myQuran
    final cityResponse = await http.get(Uri.parse(
        'https://api.myquran.com/v1/sholat/kota/cari/${Uri.encodeComponent(city)}'));

    if (cityResponse.statusCode != 200) {
      throw Exception("Gagal mendapatkan kode kota.");
    }

    final cityData = jsonDecode(cityResponse.body);
    if (cityData['data'] == null || cityData['data'].isEmpty) {
      throw Exception("Kode kota tidak ditemukan.");
    }

    final cityId = cityData['data'][0]['id'];

    // 3. Ambil waktu sholat berdasarkan ID kota
    final now = DateTime.now();
    final url = 'https://api.myquran.com/v1/sholat/jadwal/$cityId/${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final jadwal = json['data']['jadwal'];
      return {
        'Subuh': jadwal['subuh'],
        'Dzuhur': jadwal['dzuhur'],
        'Ashar': jadwal['ashar'],
        'Maghrib': jadwal['maghrib'],
        'Isya': jadwal['isya'],
      };
    } else {
      throw Exception("Gagal memuat jadwal salat.");
    }
  } catch (e) {
    throw Exception("Error: $e");
  }
}

  calculatePrayerTimes(double latitude, double longitude) {}
}
