import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/dump/prayer_time_service.dart';

class PrayerTimePage extends StatefulWidget {
  const PrayerTimePage({super.key});

  @override
  State<PrayerTimePage> createState() => _PrayerTimePageState();
}

class _PrayerTimePageState extends State<PrayerTimePage> {
  Map<String, dynamic>? prayerTimes;
  String? locationName;
  String todayDate = DateFormat('d MMMM yyyy').format(DateTime.now());
  bool isLoading = true;
  String? errorMessage;

  final PrayerTimeService _service = PrayerTimeService();

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

Future<void> loadAllData() async {
  setState(() {
    isLoading = true;
  });

  try {
    // Ambil lokasi
    final pos = await _service.getCurrentPosition();
    final loc = await _service.getLocationName(pos.latitude, pos.longitude);

    // Ambil waktu sholat
    final timings = await _service.fetchPrayerTimes(
      pos.latitude,
      pos.longitude,
    );

    if (timings.isEmpty) {
      setState(() {
        isLoading = false;
        prayerTimes = {};
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Prayer times not available, check location permissions and internet connection.',
          ),
        ),
      );
      return;
    }

    // Filter waktu yang tidak perlu
    final filteredTimes = Map<String, dynamic>.from(timings)..removeWhere(
      (key, value) =>
          key == 'Imsak' ||
          key == 'Sunrise' ||
          key == 'Sunset' ||
          key == 'Midnight' ||
          key == 'Firstthird' ||
          key == 'Lastthird',
    );

    setState(() {
      locationName = loc;
      prayerTimes = timings;
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      isLoading = false;
      prayerTimes = {};
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching prayer times: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Waktu Salat")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? const Center(
                child: Text(
                  'Waktu sholat tidak tersedia, coba aktifkan koneksi internet dan lokasi.',
                  textAlign: TextAlign.center,
                ),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locationName ?? "Lokasi tidak diketahui",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          todayDate,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 0),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children:
                          prayerTimes!.entries.map((entry) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: Text(entry.value),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
    );
  }
}
