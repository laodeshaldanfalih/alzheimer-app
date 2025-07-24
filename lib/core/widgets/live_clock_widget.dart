// live_clock_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LiveClockWidget extends StatefulWidget {
  const LiveClockWidget({super.key});

  @override
  State<LiveClockWidget> createState() => _LiveClockWidgetState();
}

class _LiveClockWidgetState extends State<LiveClockWidget> {
  late DateTime _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    // Timer akan memperbarui _currentTime setiap detik, memicu setState
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (mounted) { // Pastikan widget masih ada di tree
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Batalkan timer saat widget di-dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Format waktu menggunakan paket intl dengan locale 'id_ID' (Indonesia)
    // HH:mm -> Jam:Menit (misal, 21:46)
    final String formattedTime = DateFormat.Hm('id_ID').format(_currentTime);

    // Format tanggal, hari, bulan, tahun
    // EEEE, d MMMM yyyy -> Kamis, 29 Mei 2025
    final String formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_currentTime);

    return Column(
      mainAxisSize: MainAxisSize.min, // Agar Column tidak mengambil ruang lebih dari yang dibutuhkan
      children: [
        Text(
          formattedTime,
          style: const TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          formattedDate,
          style: const TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}