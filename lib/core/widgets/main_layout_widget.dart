import 'package:flutter/material.dart';
import 'package:project/core/widgets/custom_bottom_navbar_widget.dart';
import 'package:project/features/alzheimer_scan/presentation/pages/alzheimer_scan_page.dart';
import 'package:project/features/article/presentation/pages/article_buletin_page.dart';
import 'package:project/features/home/presentation/pages/home_page.dart';
import 'package:project/features/profile/providers/view_profile_page.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;
  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedIndex;
  DateTime? currentBackPressTime; // Untuk double tap to exit

  final List<Widget> _pages = [
    const HomePage(),
    const AlzheimerScanPage(),
    const ArticleBuletinPage(),
    const ViewProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    // Jika pengguna mengetuk tab yang sedang aktif, jangan lakukan apa-apa
    // atau, jika Anda ingin kembali ke root dari tab tersebut, implementasikan di sini.
    // Untuk saat ini, kita hanya akan mengganti halaman.
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      // Jika tidak sedang di HomePage (indeks 0)
      setState(() {
        _selectedIndex = 0; // Kembali ke HomePage
      });
      return false; // Mencegah aplikasi keluar
    } else {
      // Jika sedang di HomePage
      DateTime now = DateTime.now();
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
        currentBackPressTime = now;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tekan sekali lagi untuk keluar'),
            duration: Duration(seconds: 2),
          ),
        );
        return false; // Mencegah aplikasi keluar pada tekanan pertama
      }
      return true; // Izinkan aplikasi keluar pada tekanan kedua
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Terapkan fungsi onWillPop di sini
      child: Scaffold(
        body: IndexedStack(
          // Menggunakan IndexedStack agar state halaman tetap terjaga
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: CustomBottomNavBarWidget(
          selectedIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
