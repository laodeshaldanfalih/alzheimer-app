import 'package:flutter/material.dart';
import 'package:project/features/article/data/article_data.dart';
import 'package:project/features/article/presentation/pages/article_detail_page.dart';

class ArticleBuletinPage extends StatefulWidget {
  const ArticleBuletinPage({super.key});

  @override
  State<ArticleBuletinPage> createState() => _BuletinPageState();
}

class _BuletinPageState extends State<ArticleBuletinPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List get _filteredArticles {
    if (_searchQuery.isEmpty) return articles;
    return articles
        .where(
          (article) =>
              article.title.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Artikel Panduan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: Icon(
                        Icons.search,
                        color: Color(0xFF2D3142),
                        size: 28,
                      ),
                    ),
                    hintText: 'Cari Judul Artikel',
                    hintStyle: TextStyle(
                      color: Color(0xFF6D6D6D),
                      fontSize: 16,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                    border: InputBorder.none,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFB5BED4),
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFB5BED4),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ..._filteredArticles
                  .map((article) => _buildArticleItem(context, article))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleItem(BuildContext context, article) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ArticleDetailPage(
                  article: article,
                  recommendedArticles:
                      articles.where((a) => a != article).toList(),
                ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(article.imagePath, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}