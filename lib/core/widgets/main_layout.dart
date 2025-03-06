import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/core/widgets/custom_bottom_navbar.dart';
import 'package:project/features/home/presentation/pages/home_page.dart';
import 'package:project/features/menu/presentation/pages/feature_menu_page.dart';

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    // List of all pages
    final List<Widget> pages = [
      HomePage(),
      FeatureMenuPage(),
      Center(child: Text('Buletin Page')), // Replace with your actual pages
      Center(child: Text('Profile Page')), // Replace with your actual pages
    ];

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        onTap: (index) {
          // Handle any additional logic when switching pages if needed
        },
      ),
    );
  }
}
