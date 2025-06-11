import 'package:flutter/material.dart';
import 'package:project/features/article/presentation/pages/article_application_guide_page.dart';
import 'package:project/features/article/presentation/pages/article_health_page.dart';

class ArticleBuletinPage extends StatelessWidget {
  const ArticleBuletinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Artikel Panduan',
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 24),
          ),
          centerTitle: true,

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
                  "Artikel Panduan\nAplikasi",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Tab(
                icon: Icon(Icons.health_and_safety, size: 20),
                child: Text(
                  "Artikel\nKesehatan",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [ArticleApplicationGuidePage(), ArticleHealthPage()],
        ),
      ),
    );
  }
}
