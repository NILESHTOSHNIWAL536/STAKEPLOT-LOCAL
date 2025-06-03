import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/posts/post_model.dart';

class ExploreContent extends StatelessWidget {
  final PostModel post;

  const ExploreContent({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (post.description.message is! Map) {
      return const SizedBox.shrink();
    }

    final exploreData = post.description.message as Map<String, dynamic>;
    final pictures = exploreData['pictures'] as List<dynamic>? ?? [];
    final place = exploreData['place'] as Map<String, dynamic>?;
    final budget = exploreData['budget'] as List<dynamic>? ?? [];
    final rating = exploreData['rating'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pictures.isNotEmpty) _buildImageGallery(pictures),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (place != null) _buildPlaceInfo(place),
              const SizedBox(height: 12),
              _buildRating(rating),
              const SizedBox(height: 12),
              if (budget.isNotEmpty) _buildBudgetInfo(budget),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallery(List<dynamic> pictures) {
    if (pictures.length == 1) {
      return Container(
        width: double.infinity,
        height: 250,
        child: ClipRRect(
          child: Image.network(
            pictures[0],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              );
            },
          ),
        ),
      );
    } else if (pictures.length > 1) {
      return Container(
        height: 250,
        child: PageView.builder(
          itemCount: pictures.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  pictures[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildPlaceInfo(Map<String, dynamic> place) {
    return Row(
      children: [
        const Icon(
          Icons.location_on,
          size: 16,
          color: Colors.red,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${place['name']} • ${place['location']}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRating(int rating) {
    return Row(
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < rating ? Icons.star : Icons.star_border,
            size: 16,
            color: Colors.amber,
          );
        }),
        const SizedBox(width: 8),
        Text(
          '$rating/5',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetInfo(List<dynamic> budget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget Breakdown:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ...budget.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['category'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '₹${item['amount']}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}