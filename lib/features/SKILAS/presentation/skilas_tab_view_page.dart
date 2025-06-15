import 'package:flutter/material.dart';
import 'package:project/features/SKILAS/presentation/skilas_history_page.dart';
import 'package:project/features/article/presentation/pages/article_application_guide_page.dart';

class SkilasTabViewPage extends StatelessWidget {
  const SkilasTabViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Geriatric Depression Scale (GDS)',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            
          ),

          backgroundColor: Colors.white,
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
                icon: Icon(Icons.article_outlined, size: 20),
                child: Text(
                  "Halaman Hasil \nRiwayat Tes",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Tab(
                icon: Icon(Icons.flag, size: 20),
                child: Text(
                  "Halaman Petunjuk\nTes & Skor",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [SKILASHistoryPage(), ArticleApplicationGuidePage()],
        ),
      ),
    );
  }
}
