import 'package:adhan/adhan.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class SholatService {
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
      Placemark place = placemarks.first;

      // Coba ambil kota dari subAdministrativeArea atau locality
      String city =
          place.subAdministrativeArea ??
          place.locality ??
          'Kota tidak ditemukan';
      String district = place.subLocality ?? 'Kecamatan tidak ditemukan';
      String province = place.administrativeArea ?? 'Provinsi tidak ditemukan';

      return "$district, $city, $province";
    } else {
      return "Lokasi tidak ditemukan";
    }
  }

  /// Hitung waktu salat secara lokal menggunakan Adhan
  Map<String, String> calculatePrayerTimes(double lat, double long) {
    final coordinates = Coordinates(lat, long);
    final params = CalculationMethod.singapore.getParameters();
    params.madhab = Madhab.shafi;

    final prayerTimes = PrayerTimes.today(coordinates, params);

    return {
      'Shubuh': DateFormat.Hm().format(prayerTimes.fajr),
      'Terbit': DateFormat.Hm().format(prayerTimes.sunrise),
      'Dhuhr': DateFormat.Hm().format(prayerTimes.dhuhr),
      'Ashr': DateFormat.Hm().format(prayerTimes.asr),
      'Maghrib': DateFormat.Hm().format(prayerTimes.maghrib),
      'Isya': DateFormat.Hm().format(prayerTimes.isha),
    };
  }
}
