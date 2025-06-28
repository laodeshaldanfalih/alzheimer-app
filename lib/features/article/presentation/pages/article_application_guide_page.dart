import 'package:flutter/material.dart';
import 'package:project/features/article/data/article_ag_data.dart';
import 'package:project/features/article/presentation/pages/article_detail_page.dart';

class ArticleApplicationGuidePage extends StatefulWidget {
  const ArticleApplicationGuidePage({super.key});

  @override
  State<ArticleApplicationGuidePage> createState() =>
      _ArticleApplicationGuidePageState();
}

class _ArticleApplicationGuidePageState
    extends State<ArticleApplicationGuidePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List get _filteredArticles {
    if (_searchQuery.isEmpty) return articlesAG;
    return articlesAG
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: const TextStyle(fontSize: 16),
            decoration: const InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: Color(0xFF2D3142),
                size: 28,
              ),
              hintText: 'Cari Judul Artikel',
              hintStyle: TextStyle(color: Color(0xFF6D6D6D), fontSize: 16),
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFB5BED4), width: 1.2),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFB5BED4), width: 1.2),
              ),
            ),
          ),
        ),

        // Daftar Artikel (Bisa di-scroll)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                ..._filteredArticles.map(
                  (article) => _buildArticleItem(context, article),
                ),
              ],
            ),
          ),
        ),
      ],
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
                      articlesAG.where((a) => a != article).toList(),
                ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                article.imagePath,
                fit: BoxFit.cover,
                height: 80,
                width: 100,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
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
