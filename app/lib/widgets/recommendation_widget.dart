import 'package:flutter/material.dart';

class RecommendationWidget extends StatelessWidget {
  final List<RecommendedBook> recommendedBooks;

  const RecommendationWidget({
    super.key,
    required this.recommendedBooks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recommended Books Section
          Row(
            children: [
              Icon(
                Icons.book_outlined,
                color: Colors.blue.shade600,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Recommended Books',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Books Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: recommendedBooks.take(3).map((book) => 
              _buildBookItem(book)
            ).toList(),
          ),
          
          
        ],
      ),
    );
  }

  Widget _buildBookItem(RecommendedBook book) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            // Book Cover
            Container(
              height: 100,
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: book.coverImageUrl != null
                    ? Image.network(
                        book.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildBookPlaceholder();
                        },
                      )
                    : _buildBookPlaceholder(),
              ),
            ),
            const SizedBox(height: 8),
            
            // Book Title
            Text(
              book.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildBookPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.book,
        size: 32,
        color: Colors.grey.shade400,
      ),
    );
  }
}

// Data models for the recommendations
class RecommendedBook {
  final String title;
  final String? coverImageUrl;

  const RecommendedBook({
    required this.title,
    this.coverImageUrl,
  });
}

