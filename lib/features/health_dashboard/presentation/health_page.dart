import 'package:flutter/material.dart';
import 'package:project/features/health_dashboard/presentation/health_graphic_chart_page.dart';
import 'package:project/features/health_dashboard/presentation/health_history_list_page.dart';
import 'package:project/features/health_dashboard/presentation/health_input_page.dart';

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
          title: const Text(
            'Dasbor Kesehatan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          elevation: 0,
          bottom: const TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
            isScrollable: false,
            tabAlignment: TabAlignment.fill,
            tabs: [
              Tab(
                icon: Icon(Icons.edit_note),
                child: Text(
                  "Input Data",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Tab(
                icon: Icon(Icons.show_chart),
                child: Text(
                  "Grafik",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ), // DIUBAH
              Tab(
                icon: Icon(Icons.history),
                child: Text(
                  "Riwayat &\nAksi",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
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
