class ArticleItem {
  final String title;
  final String? imageUrl;
  final String description;
  final String content; // Full article content

  ArticleItem({
    required this.title,
    this.imageUrl,
    required this.description,
    this.content = '', // Default empty string if not provided
  });
}