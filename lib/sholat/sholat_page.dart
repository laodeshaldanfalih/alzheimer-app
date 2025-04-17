import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:project/sholat/Sholat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SholatPage extends StatefulWidget {
  const SholatPage({super.key});

  @override
  State<SholatPage> createState() => _SholatPageState();
}

class _SholatPageState extends State<SholatPage> {
  Map<String, String>? prayerTimes;
  String? locationName;
  late String todayDate;
  bool isLoading = true;
  String? errorMessage;
  String? nextPrayerName;
  DateTime? nextPrayerTime;
  final SholatService _service = SholatService();
  final ScrollController _scrollController = ScrollController();
  bool isScrolledPastHeader = false;
  Timer? _debounce;
  late String currentTime;
  Timer? _timer;
  ValueNotifier<bool> showCollapsedAppBar = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
    loadAllData();

    _scrollController.addListener(() {
      final triggerOffset = 180; // Adjust as needed
      if (_scrollController.offset > triggerOffset && !isScrolledPastHeader) {
        setState(() {
          isScrolledPastHeader = true;
        });
      } else if (_scrollController.offset <= triggerOffset &&
          isScrolledPastHeader) {
        setState(() {
          isScrolledPastHeader = false;
        });
      }
    });

    currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      });
    });
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('id_ID', null);
    setState(() {
      todayDate = DateFormat(
        'EEEE, d MMMM yyyy',
        'id_ID',
      ).format(DateTime.now());
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '$hours jam ${minutes.toString().padLeft(2, '0')} menit';
    } else {
      return '$minutes menit';
    }
  }

  Map<String, dynamic> _getNextPrayerTime(Map<String, String> prayerTimes) {
    final now = DateTime.now();

    for (var entry in prayerTimes.entries) {
      final timeParts = entry.value.split(':');
      final time = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
      if (time.isAfter(now)) {
        return {'name': entry.key, 'time': time};
      }
    }
    final first = prayerTimes.entries.first;
    final timeParts = first.value.split(':');
    final time = DateTime(
      now.year,
      now.month,
      now.day + 1,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
    return {'name': first.key, 'time': time};
  }

  //LoadData tanpa Cache
  // Future<void> loadAllData() async {
  //   setState(() {
  //     isLoading = true;
  //   });

  //   try {
  //     // Ambil lokasi
  //     final pos = await _service.getCurrentPosition();
  //     final loc = await _service.getLocationName(pos.latitude, pos.longitude);

  //     // Hitung waktu sholat lokal
  //     final timings = _service.calculatePrayerTimes(
  //       pos.latitude,
  //       pos.longitude,
  //     );

  //     final nextPrayer = _getNextPrayerTime(timings);
  //     setState(() {
  //       nextPrayerName = nextPrayer['name'];
  //       nextPrayerTime = nextPrayer['time'];
  //     });

  //     setState(() {
  //       locationName = loc;
  //       prayerTimes = timings;
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       errorMessage = e.toString();
  //       isLoading = false;
  //     });
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
  //   }
  // }

  //LoadData dengan Cache
  Future<void> loadAllData() async {
  setState(() {
    isLoading = true;
  });

  final prefs = await SharedPreferences.getInstance();

  try {
    // Ambil lokasi
    final pos = await _service.getCurrentPosition();
    final loc = await _service.getLocationName(pos.latitude, pos.longitude);

    // Hitung waktu sholat lokal
    final timings = _service.calculatePrayerTimes(
      pos.latitude,
      pos.longitude,
    );

    final nextPrayer = _getNextPrayerTime(timings);

    // Simpan ke cache
    await prefs.setString('locationName', loc);
    await prefs.setString('prayerTimes', jsonEncode(timings));

    setState(() {
      locationName = loc;
      prayerTimes = timings;
      nextPrayerName = nextPrayer['name'];
      nextPrayerTime = nextPrayer['time'];
      isLoading = false;
      errorMessage = null;
    });
  } catch (e) {
    // Jika error (misal: lokasi tidak diizinkan), ambil data dari cache
    final cachedLocation = prefs.getString('locationName');
    final cachedPrayerTimes = prefs.getString('prayerTimes');

    if (cachedLocation != null && cachedPrayerTimes != null) {
      final decodedTimes =
          Map<String, String>.from(jsonDecode(cachedPrayerTimes));

      final nextPrayer = _getNextPrayerTime(decodedTimes);

      setState(() {
        locationName = cachedLocation;
        prayerTimes = decodedTimes;
        nextPrayerName = nextPrayer['name'];
        nextPrayerTime = nextPrayer['time'];
        isLoading = false;
        errorMessage = null;
      });
    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'Gagal mendapatkan data lokasi atau cache tidak ditemukan.';
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }
}

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ValueListenableBuilder<bool>(
          valueListenable: showCollapsedAppBar,
          builder: (context, collapsed, _) {
            return AppBar(
              title: AnimatedSwitcher(
                duration: const Duration(milliseconds: 100),
                child:
                    collapsed &&
                            nextPrayerName != null &&
                            nextPrayerTime != null
                        ? Text(
                          "$nextPrayerName ${DateFormat('HH:mm').format(nextPrayerTime!)}",
                          key: const ValueKey('collapsed'),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        )
                        : const Text(
                          "Waktu Sholat",
                          key: ValueKey('expanded'),
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
              ),
              elevation: 0,
              backgroundColor:
                  collapsed ? Colors.transparent : Colors.transparent,
              foregroundColor: collapsed ? Colors.white : Colors.white,
            );
          },
        ),
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 65, 117, 196),
                  Color.fromARGB(255, 108, 142, 170),
                  Color.fromARGB(255, 108, 142, 170),
                  Color(0xFFE3F2FD),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Scrollable content
          SafeArea(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                    ? const Center(
                      child: Text(
                        'Waktu sholat tidak tersedia, coba aktifkan koneksi internet dan lokasi Anda..',
                        textAlign: TextAlign.center,
                      ),
                    )
                    : NotificationListener<ScrollNotification>(
                      onNotification: (scroll) {
                        if (_debounce?.isActive ?? false) _debounce?.cancel();
                        _debounce = Timer(
                          const Duration(milliseconds: 100),
                          () {
                            showCollapsedAppBar.value =
                                scroll.metrics.pixels > 80;
                          },
                        );
                        return false;
                      },
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (nextPrayerName != null &&
                                nextPrayerTime != null)
                              Container(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        currentTime,
                                        style: TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 48),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Waktu $nextPrayerName',
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              // const SizedBox(height: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  DateFormat(
                                                    'HH:mm',
                                                  ).format(nextPrayerTime!),
                                                  style: const TextStyle(
                                                    fontSize: 36,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 6),

                                              Text(
                                                '${_formatDuration(nextPrayerTime!.difference(DateTime.now()))} lagi',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        CircleAvatar(
                                          backgroundImage: AssetImage(
                                            'assets/images/mosque.png',
                                          ),
                                          radius: 48,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                            // Card jadwal sholat
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Card(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4,
                                                ),
                                                child: const Icon(
                                                  Icons.calendar_today_rounded,
                                                  color: Colors.grey,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Jadwal Sholat',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Hari ini $todayDate',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ), // Jarak antar baris
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                color: Colors.grey,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  'Lokasi: ${locationName ?? "Lokasi tidak diketahui"}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 16),
                                      ...prayerTimes!.entries.map((entry) {
                                        final now = DateTime.now();
                                        final index = prayerTimes!.keys
                                            .toList()
                                            .indexOf(entry.key);
                                        final timeParts = entry.value.split(
                                          ':',
                                        );
                                        var time = DateTime(
                                          now.year,
                                          now.month,
                                          now.day,
                                          int.parse(timeParts[0]),
                                          int.parse(timeParts[1]),
                                        );

                                        if (entry.key.toLowerCase() == "isya" &&
                                            now.hour < 5 &&
                                            time.hour > 17) {
                                          time = time.subtract(
                                            const Duration(days: 1),
                                          );
                                        }

                                        DateTime? nextTime;
                                        if (index + 1 < prayerTimes!.length) {
                                          final nextEntry = prayerTimes!.entries
                                              .elementAt(index + 1);
                                          final nextParts = nextEntry.value
                                              .split(':');
                                          nextTime = DateTime(
                                            now.year,
                                            now.month,
                                            now.day,
                                            int.parse(nextParts[0]),
                                            int.parse(nextParts[1]),
                                          );
                                          if (nextEntry.key.toLowerCase() ==
                                                  "shubuh" &&
                                              nextTime.hour < 5 &&
                                              now.hour < 5) {
                                            nextTime = nextTime.add(
                                              const Duration(days: 1),
                                            );
                                          }
                                        } else {
                                          final firstEntry =
                                              prayerTimes!.entries.first;
                                          final firstParts = firstEntry.value
                                              .split(':');
                                          nextTime = DateTime(
                                            now.year,
                                            now.month,
                                            now.day + 1,
                                            int.parse(firstParts[0]),
                                            int.parse(firstParts[1]),
                                          );
                                        }

                                        final isCurrent =
                                            now.isAfter(time) &&
                                            now.isBefore(nextTime);
                                        final isNext =
                                            entry.key.toLowerCase() ==
                                            nextPrayerName?.toLowerCase();

                                        return Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey.shade200,
                                                width: 1.0,
                                              ),
                                            ),
                                          ),
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            title: Text(
                                              entry.key,
                                              style: TextStyle(
                                                fontWeight:
                                                    isCurrent || isNext
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                fontSize: 16,
                                                color:
                                                    isCurrent
                                                        ? Colors.blue[700]
                                                        : isNext
                                                        ? Colors.green[700]
                                                        : Colors.black,
                                              ),
                                            ),
                                            trailing: Text(
                                              entry.value,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                    isCurrent || isNext
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                color:
                                                    isCurrent
                                                        ? Colors.blue[700]
                                                        : isNext
                                                        ? Colors.green[700]
                                                        : Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Jadwal di atas berdasarkan lokasi Anda saat ini.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
