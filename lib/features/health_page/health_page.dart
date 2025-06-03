import 'package:flutter/material.dart';
import 'package:project/features/health_page/health_graphic_chart_page.dart';
import 'package:project/features/health_page/health_history_list_page.dart';
import 'package:project/features/health_page/health_input_page.dart';

// DIUBAH: TabController sekarang memiliki panjang 3
class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // DIUBAH
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Dasbor Kesehatan'),
          centerTitle: true,
          bottom: const TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: Colors.blue,
            labelColor: Colors.blue, // Warna teks tab yang aktif
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.edit_note), text: "Input Data"),
              Tab(icon: Icon(Icons.show_chart), text: "Grafik"), // DIUBAH
              Tab(
                icon: Icon(Icons.history),
                text: "Riwayat & Aksi",
              ), // TAB BARU
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF9FAFB), Colors.white], // Warna lebih lembut
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const TabBarView(
            
            children: [
              HealthInputPage(),
              HealthGraphicChartPage(),
              HealthHistoryListPage(),
            ],
          ),
        ),
      ),
    );
  }
}
