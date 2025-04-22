import 'package:adhan/adhan.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;

class SholatService {
  /// Ambil koordinat dari lokasi saat ini
  Future<Position> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Lokasi tidak aktif. Mohon aktifkan layanan lokasi di pengaturan perangkat Anda.';
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // This will show the iOS permission popup
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Izin lokasi ditolak. Mohon berikan izin lokasi untuk aplikasi ini.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Izin lokasi ditolak secara permanen. Mohon aktifkan izin lokasi di pengaturan perangkat Anda.';
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      throw 'Gagal mendapatkan lokasi: $e';
    }
  }

  /// Ambil nama lokasi dari koordinat
  Future<String> getLocationName(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      if (placemarks.isEmpty) {
        return "Lokasi tidak ditemukan";
      }

      Placemark place = placemarks.first;
      String city =
          place.subAdministrativeArea ??
          place.locality ??
          'Kota tidak ditemukan';
      String district = place.subLocality ?? 'Kecamatan tidak ditemukan';
      String province = place.administrativeArea ?? 'Provinsi tidak ditemukan';

      return "$district, $city, $province";
    } catch (e) {
      return "Gagal mendapatkan nama lokasi: $e";
    }
  }

  /// Hitung waktu salat secara lokal menggunakan Adhan
  Map<String, String> calculatePrayerTimes(double lat, double long) {
    try {
      final coordinates = Coordinates(lat, long);
      final params = CalculationMethod.singapore.getParameters();
      params.madhab = Madhab.shafi;

      final prayerTimes = PrayerTimes.today(coordinates, params);

      return {
        'Fajr': DateFormat.Hm().format(prayerTimes.fajr),
        'Terbit': DateFormat.Hm().format(prayerTimes.sunrise),
        'Dhuhr': DateFormat.Hm().format(prayerTimes.dhuhr),
        'Ashr': DateFormat.Hm().format(prayerTimes.asr),
        'Maghrib': DateFormat.Hm().format(prayerTimes.maghrib),
        'Isya': DateFormat.Hm().format(prayerTimes.isha),
      };
    } catch (e) {
      throw 'Gagal menghitung waktu sholat: $e';
    }
  }
}
