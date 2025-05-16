import 'package:flutter/material.dart';
import 'package:project/features/alzheimer_scan/presentation/pages/alzheimer_scan_page.dart';
import 'package:project/features/home/presentation/pages/home_page.dart';
import 'package:project/features/profile/presentation/pages/profile_page.dart';
import 'package:project/core/widgets/custom_bottom_navbar.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;
  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedIndex;

  final List<Widget> _pages = [HomePage(), AlzheimerScanPage(), ProfilePage()];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
