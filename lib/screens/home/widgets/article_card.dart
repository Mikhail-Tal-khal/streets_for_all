import 'package:flutter/material.dart';

class ArticleCard extends StatelessWidget {
  final String title;
  final String imageAsset;
  final VoidCallback onTap;

  const ArticleCard({
    super.key,
    required this.title,
    required this.imageAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image or placeholder
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: _buildImage(),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    try {
      return Image.asset(
        imageAsset,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } catch (e) {
      // Fallback if image not found
      return Container(
        height: 120,
        color: Colors.blue.shade100,
        child: Center(
          child: Icon(
            Icons.article_rounded,
            color: Colors.blue.shade700,
            size: 32,
          ),
        ),
      );
    }
  }
}