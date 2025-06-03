import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/posts/post_actions.dart';
import 'package:flutter_application_code_stakeplot/posts/post_content.dart';
import 'package:flutter_application_code_stakeplot/posts/post_model.dart';
import 'package:flutter_application_code_stakeplot/posts/user_avatar.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;
  final Function(String)? onPollVote;

  const PostCard({
    Key? key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onBookmark,
    this.onPollVote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          PostContent(
            post: post,
            onPollVote: onPollVote,
          ),
          PostActions(
            post: post,
            onLike: onLike,
            onComment: onComment,
            onShare: onShare,
            onBookmark: onBookmark,
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          UserAvatar(
            avatar: post.author.avatar,
            backgroundColor: post.author.avatarBackGround,
            size: 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.author.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                if (post.postType == 'explore')
                  Text(
                    _getExploreSubtitle(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showMoreOptions(context),
            icon: const Icon(
              Icons.more_vert,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.title.isNotEmpty)
            Text(
              post.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          const SizedBox(height: 4),
          if (_getDescriptionText().isNotEmpty)
            Text(
              _getDescriptionText(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            _formatTimestamp(post.createdAt),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _getExploreSubtitle() {
    if (post.description.message is Map) {
      final exploreData = post.description.message as Map<String, dynamic>;
      if (exploreData['place'] != null) {
        return exploreData['place']['name'] ?? '';
      }
    }
    return '';
  }

  String _getDescriptionText() {
    if (post.description.message is String) {
      return post.description.message;
    } else if (post.description.message is Map) {
      final data = post.description.message as Map<String, dynamic>;
      if (post.postType == 'explore') {
        return data['description'] ?? '';
      }
    }
    return '';
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block User'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.visibility_off),
              title: const Text('Hide Post'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}