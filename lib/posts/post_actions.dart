import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/posts/post_model.dart';

class PostActions extends StatefulWidget {
  final PostModel post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;

  const PostActions({
    Key? key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onBookmark,
  }) : super(key: key);

  @override
  State<PostActions> createState() => _PostActionsState();
}

class _PostActionsState extends State<PostActions> {
  bool isLiked = false;
  bool isBookmarked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    likeCount = widget.post.upvotes;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildActionButton(
            icon: isLiked ? Icons.lightbulb : Icons.lightbulb_outline,
            count: likeCount,
            isActive: isLiked,
            onTap: _handleLike,
          ),
          const SizedBox(width: 24),
          _buildActionButton(
            icon: Icons.chat_bubble_outline,
            count: widget.post.comments,
            isActive: false,
            onTap: widget.onComment,
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onShare,
            icon: const Icon(
              Icons.share_outlined,
              size: 20,
              color: Colors.grey,
            ),
          ),
          IconButton(
            onPressed: _handleBookmark,
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              size: 20,
              color: isBookmarked ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isActive ? Colors.amber : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            _formatCount(count),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  void _handleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
    
    if (widget.onLike != null) {
      widget.onLike!();
    }
  }

  void _handleBookmark() {
    setState(() {
      isBookmarked = !isBookmarked;
    });
    
    if (widget.onBookmark != null) {
      widget.onBookmark!();
    }
  }
}