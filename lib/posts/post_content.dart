import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/posts/post_model.dart';
import 'poll_widget.dart';
import 'explore_content.dart';

class PostContent extends StatelessWidget {
  final PostModel post;
  final Function(String)? onPollVote;

  const PostContent({
    Key? key,
    required this.post,
    this.onPollVote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (post.isPoll && post.pollData != null) {
      return PollWidget(
        pollData: post.pollData!,
        onVote: onPollVote,
      );
    } else if (post.postType == 'explore') {
      return ExploreContent(post: post);
    } else if (post.image != null && post.image!.isNotEmpty) {
      return _buildImageContent();
    } else {
      return _buildTextContent();
    }
  }

  Widget _buildImageContent() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        maxHeight: 400,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(0),
          bottom: Radius.circular(0),
        ),
        child: Image.network(
          post.image!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextContent() {
    if (post.description.message is String && 
        (post.description.message as String).isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          post.description.message,
          style: const TextStyle(
            fontSize: 14,
            height: 1.4,
            color: Colors.black87,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}