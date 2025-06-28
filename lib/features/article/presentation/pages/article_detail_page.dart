// lib/features/article/article_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:project/features/article/models/article_item.dart';

class ArticleDetailPage extends StatelessWidget {
  final ArticleItem article;
  final List<ArticleItem> recommendedArticles;

  const ArticleDetailPage({
    super.key,
    required this.article,
    required this.recommendedArticles,
  });

  /// Calculates the estimated reading time based on word count.
  /// Average reading speed is assumed to be 225 words per minute.
  String _calculateReadingTime(String content) {
    final wordCount = content.split(RegExp(r'\s+')).length;
    final readingTime = (wordCount / 225).ceil();
    return '$readingTime min read';
  }

  @override
  Widget build(BuildContext context) {
    // Filter out the current article from the recommendations list
    final filteredRecommendations =
        recommendedArticles.where((rec) => rec.title != article.title).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Hero Image
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
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
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(24),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Article Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Main Article Card
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A1A),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildTagBadge(context),
                          const SizedBox(width: 12),
                          _buildReadingTime(context),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Divider(color: Colors.grey[200]),
                      const SizedBox(height: 20),
                      Text(
                        article.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[700],
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildMarkdownContent(context, article.content),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                if (filteredRecommendations.isNotEmpty)
                  _buildRecommendationsSection(
                    context,
                    filteredRecommendations,
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the content of the article using Markdown.
  /// It now includes an `imageBuilder` to render images from Markdown content.
  Widget _buildMarkdownContent(BuildContext context, String content) {
    final theme = Theme.of(context);
    return MarkdownBody(
      data: content,
      shrinkWrap: true,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        // Text Styles
        p: theme.textTheme.bodyMedium?.copyWith(
          height: 1.5,
          color: theme.colorScheme.onSurface.withOpacity(0.9),
        ),

        // Headings
        h1: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onSurface,
          wordSpacing: 0,
          height: 1.5,
        ),
        h2: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          height: 1.5,
        ),

        // Links
        a: TextStyle(
          color: theme.colorScheme.primary,
          decoration: TextDecoration.underline,
        ),

        // Lists
        listBullet: theme.textTheme.bodyLarge?.copyWith(
          height: 1.8,
          color: theme.colorScheme.onSurface,
        ),
        listIndent: 24.0,

        // Emphasis
        strong: const TextStyle(fontWeight: FontWeight.bold),
        em: const TextStyle(fontStyle: FontStyle.italic),

        // Code
        code: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: 'RobotoMono',
          backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          color: theme.colorScheme.onSurface,
        ),

        // Blockquotes
        blockquote: theme.textTheme.bodyLarge?.copyWith(
          fontStyle: FontStyle.italic,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        blockquoteDecoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
          border: Border(
            left: BorderSide(color: theme.colorScheme.primary, width: 4),
          ),
        ),

        // Tables
        tableHead: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        tableBody: theme.textTheme.bodyLarge,
        tableBorder: TableBorder.all(color: theme.dividerColor, width: 1),

        // Horizontal Rule
        horizontalRuleDecoration: BoxDecoration(
          border: Border(top: BorderSide(color: theme.dividerColor, width: 1)),
        ),
      ),

      imageBuilder:
          (uri, title, alt) => _buildInlineImageWithCaption(
            imageUrl: uri.toString(),
            caption: alt,
          ),
    );
  }

  /// Builds a widget to display an image with an optional caption underneath.
  Widget _buildInlineImageWithCaption({
    required String imageUrl,
    String? caption,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              height: 200,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gambar tidak dapat dimuat',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
          if (caption != null && caption.isNotEmpty) ...[
            const SizedBox(height: 10),
            Center(
              child: Text(
                caption,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the recommended articles section.
  Widget _buildRecommendationsSection(
    BuildContext context,
    List<ArticleItem> recommendations,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Artikel Lainnya',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          ...recommendations
              .take(3)
              .map(
                (recArticle) =>
                    _buildRecommendedArticleCard(context, recArticle),
              ),
        ],
      ),
    );
  }

  /// Builds a card for a single recommended article.
  Widget _buildRecommendedArticleCard(
    BuildContext context,
    ArticleItem recArticle,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.pushReplacement(
            // Use pushReplacement for better UX
            context,
            MaterialPageRoute(
              builder:
                  (context) => ArticleDetailPage(
                    article: recArticle,
                    recommendedArticles: recommendedArticles,
                  ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  recArticle.imagePath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recArticle.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recArticle.tag,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the reading time info widget.
  Widget _buildReadingTime(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          _calculateReadingTime(article.content),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Builds the category tag badge.
  Widget _buildTagBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF4A90E2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        article.tag,
        style: const TextStyle(
          color: Color(0xFF4A90E2),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Catatan: Jangan lupa untuk mengimpor file `article_item.dart` Anda di atas.
// import 'package:project/features/article/models/article_item.dart';
