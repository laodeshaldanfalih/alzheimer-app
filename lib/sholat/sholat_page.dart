import 'dart:async';
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project/sholat/Sholat_service.dart';
import 'package:project/sholat/sholat_time_tile.dart';
import 'package:project/sholat/sholat_utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sholat_notification_service.dart';

class SholatPage extends StatefulWidget {
  const SholatPage({super.key});

  @override
  State<SholatPage> createState() => _SholatPageState();
}

class _SholatPageState extends State<SholatPage> with WidgetsBindingObserver {
  Map<String, String>? prayerTimes;
  String? locationName;
  late String todayDate;
  DateTime now = DateTime.now();
  bool isLoading = true;
  String? errorMessage;
  String? nextPrayerName;
  DateTime? nextPrayerTime;
  final SholatService _service = SholatService();
  final ScrollController _scrollController = ScrollController();
  bool isScrolledPastHeader = false;
  Timer? _debounce;
  // late String currentTime;
  Timer? _timer;
  ValueNotifier<bool> showCollapsedAppBar = ValueNotifier(false);
  Map<String, bool> notificationEnabled = {};
  bool allNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initializeDateFormatting();

    Future.microtask(() async {
      await _handlePermissions(); // ⬅ ini yang baru
      await _loadNotificationPreferences();
      await loadAllData();
    });

    SholatNotificationService().initialize();
    _scrollController.addListener(() {
      final triggerOffset = 180;
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

    // currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    // _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    //   setState(() {
    //     currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    //   });
    // });

    // _loadNotificationPreferences().then((_) {
    //   loadAllData();
    // });
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
      notificationEnabled.addEntries(
        timings.keys.map(
          (key) => MapEntry(key, notificationEnabled[key] ?? true),
        ),
      );
      await SholatNotificationService().schedulePrayerNotifications(
        timings.map((key, value) {
          if (notificationEnabled[key] == true) {
            return MapEntry(key, value);
          } else {
            return MapEntry(key, ''); // Kosongkan jika nonaktif
          }
        })..removeWhere((key, value) => value == ''),
      );
    } catch (e) {
      // Jika error (misal: lokasi tidak diizinkan), ambil data dari cache
      final cachedLocation = prefs.getString('locationName');
      final cachedPrayerTimes = prefs.getString('prayerTimes');

      if (cachedLocation != null && cachedPrayerTimes != null) {
        final decodedTimes = Map<String, String>.from(
          jsonDecode(cachedPrayerTimes),
        );

        final nextPrayer = _getNextPrayerTime(decodedTimes);

        setState(() {
          locationName = cachedLocation;
          prayerTimes = decodedTimes;
          nextPrayerName = nextPrayer['name'];
          nextPrayerTime = nextPrayer['time'];
          isLoading = false;
          errorMessage = null;
        });
        notificationEnabled.addEntries(
          decodedTimes.keys.map(
            (key) => MapEntry(key, notificationEnabled[key] ?? true),
          ),
        );
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              'Gagal mendapatkan data lokasi atau cache tidak ditemukan.';
        });
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      }
      return;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    _scrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && prayerTimes != null) {
      SholatNotificationService().schedulePrayerNotifications(
        prayerTimes!.map((key, value) {
          if (notificationEnabled[key] == true) {
            return MapEntry(key, value);
          } else {
            return MapEntry(key, '');
          }
        })..removeWhere((key, value) => value == ''),
      );
    }
  }

  Future<void> _loadNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationEnabled = {
        'Fajr': prefs.getBool('notification_Fajr') ?? true,
        'Terbit': prefs.getBool('notification_Terbit') ?? true,
        'Dhuhr': prefs.getBool('notification_Dhuhr') ?? true,
        'Ashr': prefs.getBool('notification_Ashr') ?? true,
        'Maghrib': prefs.getBool('notification_Maghrib') ?? true,
        'Isya': prefs.getBool('notification_Isya') ?? true,
      };
      allNotificationsEnabled = !notificationEnabled.values.contains(false);
    });
  }

  Future<void> _saveNotificationPreference(
    String prayerName,
    bool isEnabled,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_$prayerName', isEnabled);
  }

  Future<void> _saveAllNotificationPreferences(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    for (var key in notificationEnabled.keys) {
      await prefs.setBool('notification_$key', isEnabled);
    }
  }

  Future<void> _handlePermissions() async {
    // 1. Notifikasi dulu
    final notifAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!notifAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
      await Future.delayed(Duration(milliseconds: 500));
    }

    // 2. Lalu lokasi
    final locStatus = await Permission.location.status;
    if (!locStatus.isGranted) {
      await Permission.location.request();
    }
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
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                          ),
                        ),
              ),
              elevation: 0,
              backgroundColor:
                  collapsed ? Colors.transparent : Colors.transparent,
              foregroundColor: collapsed ? Colors.white : Colors.white,
              actions: [
                AppBarMoreOptions(
                  onRefresh: () => loadAllData(),
                  onTestNotification: () {
                    SholatNotificationService().testScheduleNotification();
                  },
                ),
              ],
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
                    ? Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 400),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.orangeAccent,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Waktu sholat tidak tersedia,\ncoba aktifkan koneksi internet dan lokasi Anda.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF212427),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Tombol Aktifkan Izin Lokasi
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF20B2AA),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      openAppSettings(); // from permission_handler
                                    },
                                    icon: const Icon(
                                      Icons.app_settings_alt,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Aktifkan Izin Lokasi',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Tombol Aktifkan GPS
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      side: const BorderSide(
                                        color: Color(0xFF20B2AA),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      Geolocator.openLocationSettings(); // Buka pengaturan GPS perangkat
                                    },
                                    icon: const Icon(
                                      Icons.gps_fixed,
                                      color: Color(0xFF20B2AA),
                                    ),
                                    label: const Text(
                                      'Aktifkan Lokasi (GPS)',
                                      style: TextStyle(
                                        color: Color(0xFF20B2AA),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Tombol Notifikasi
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      side: const BorderSide(
                                        color: Color(0xFF20B2AA),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      AwesomeNotifications()
                                          .requestPermissionToSendNotifications();
                                    },
                                    icon: const Icon(
                                      Icons.notifications_active,
                                      color: Color(0xFF20B2AA),
                                    ),
                                    label: const Text(
                                      'Aktifkan Notifikasi',
                                      style: TextStyle(
                                        color: Color(0xFF20B2AA),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF325374),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      loadAllData(); // memanggil ulang fungsi utama
                                    },
                                    icon: const Icon(
                                      Icons.refresh,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Coba Lagi',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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
                                    // Container(
                                    //   padding: const EdgeInsets.symmetric(
                                    //     horizontal: 12,
                                    //     vertical: 2,
                                    //   ),
                                    //   decoration: BoxDecoration(
                                    //     color: Colors.white.withOpacity(0.3),
                                    //     borderRadius: BorderRadius.circular(8),
                                    //   ),
                                    //   child: Text(
                                    //     currentTime,
                                    //     style: TextStyle(
                                    //       fontSize: 36,
                                    //       fontWeight: FontWeight.w500,
                                    //       color: Colors.white,
                                    //     ),
                                    //   ),
                                    // ),

                                    // SizedBox(height: 24),
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
                                                    Text(
                                                      DateFormat(
                                                        'HH:mm',
                                                      ).format(DateTime.now()),
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
                                          child: PrayerTimeTile(
                                            name: entry.key,
                                            time: entry.value,
                                            isCurrent: isCurrent,
                                            isNext: isNext,
                                            isNotificationOn:
                                                notificationEnabled[entry
                                                    .key] ??
                                                true,
                                            onNotificationToggle: () async {
                                              final newValue =
                                                  !(notificationEnabled[entry
                                                          .key] ??
                                                      true);
                                              setState(() {
                                                notificationEnabled[entry.key] =
                                                    newValue;
                                                allNotificationsEnabled =
                                                    !notificationEnabled.values
                                                        .contains(false);
                                              });

                                              await _saveNotificationPreference(
                                                entry.key,
                                                newValue,
                                              ); // ⬅ SIMPAN PERUBAHAN

                                              if (prayerTimes != null) {
                                                await SholatNotificationService()
                                                    .schedulePrayerNotifications(
                                                      prayerTimes!.map((
                                                        key,
                                                        value,
                                                      ) {
                                                        if (notificationEnabled[key] ==
                                                            true) {
                                                          return MapEntry(
                                                            key,
                                                            value,
                                                          );
                                                        } else {
                                                          return MapEntry(
                                                            key,
                                                            '',
                                                          );
                                                        }
                                                      })..removeWhere(
                                                        (key, value) =>
                                                            value == '',
                                                      ),
                                                    );
                                              }
                                            },
                                          ),
                                          // child: ListTile(
                                          //   contentPadding: EdgeInsets.zero,
                                          //   title: Text(
                                          //     entry.key,
                                          //     style: TextStyle(
                                          //       fontWeight:
                                          //           isCurrent || isNext
                                          //               ? FontWeight.bold
                                          //               : FontWeight.normal,
                                          //       fontSize: 16,
                                          //       color:
                                          //           isCurrent
                                          //               ? Colors.blue[700]
                                          //               : isNext
                                          //               ? Colors.green[700]
                                          //               : Colors.black,
                                          //     ),
                                          //   ),
                                          //   trailing: Row(
                                          //     mainAxisSize: MainAxisSize.min,
                                          //     children: [
                                          //       Text(
                                          //         entry.value,
                                          //         style: TextStyle(
                                          //           fontSize: 16,
                                          //           fontWeight:
                                          //               isCurrent || isNext
                                          //                   ? FontWeight.bold
                                          //                   : FontWeight.normal,
                                          //           color:
                                          //               isCurrent
                                          //                   ? Colors.blue[700]
                                          //                   : isNext
                                          //                   ? Colors.green[700]
                                          //                   : Colors.grey[600],
                                          //         ),
                                          //       ),
                                          //       IconButton(
                                          //         icon: Icon(
                                          //           notificationEnabled[entry
                                          //                       .key] ==
                                          //                   true
                                          //               ? Icons
                                          //                   .notifications_active
                                          //               : Icons
                                          //                   .notifications_off,
                                          //           color:
                                          //               notificationEnabled[entry
                                          //                           .key] ==
                                          //                       true
                                          //                   ? Colors.green
                                          //                   : Colors.grey,
                                          //           size: 20,
                                          //         ),
                                          //         onPressed: () {
                                          //           setState(() {
                                          //             notificationEnabled[entry
                                          //                     .key] =
                                          //                 !(notificationEnabled[entry
                                          //                         .key] ??
                                          //                     true);
                                          //             allNotificationsEnabled =
                                          //                 !notificationEnabled
                                          //                     .values
                                          //                     .contains(false);
                                          //           });

                                          //           if (prayerTimes != null) {
                                          //             SholatNotificationService()
                                          //                 .schedulePrayerNotifications(
                                          //                   prayerTimes!.map((
                                          //                     key,
                                          //                     value,
                                          //                   ) {
                                          //                     if (notificationEnabled[key] ==
                                          //                         true) {
                                          //                       return MapEntry(
                                          //                         key,
                                          //                         value,
                                          //                       );
                                          //                     } else {
                                          //                       return MapEntry(
                                          //                         key,
                                          //                         '',
                                          //                       );
                                          //                     }
                                          //                   })..removeWhere(
                                          //                     (key, value) =>
                                          //                         value == '',
                                          //                   ),
                                          //                 );
                                          //           }
                                          //         },
                                          //       ),
                                          //     ],
                                          //   ),
                                          // ),
                                        );
                                      }),

                                      const SizedBox(height: 16),

                                      NotificationToggleCheckbox(
                                        allEnabled: allNotificationsEnabled,
                                        onChanged: (value) async {
                                          setState(() {
                                            allNotificationsEnabled =
                                                value ?? false;
                                            notificationEnabled.updateAll(
                                              (key, _) =>
                                                  allNotificationsEnabled,
                                            );
                                          });

                                          await _saveAllNotificationPreferences(
                                            allNotificationsEnabled,
                                          );
                                          if (prayerTimes != null) {
                                            SholatNotificationService()
                                                .schedulePrayerNotifications(
                                                  prayerTimes!.map((
                                                    key,
                                                    value,
                                                  ) {
                                                    if (allNotificationsEnabled) {
                                                      return MapEntry(
                                                        key,
                                                        value,
                                                      );
                                                    } else {
                                                      return MapEntry(key, '');
                                                    }
                                                  })..removeWhere(
                                                    (key, value) => value == '',
                                                  ),
                                                );
                                          }
                                        },
                                      ),

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
