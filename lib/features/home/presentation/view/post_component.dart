import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:softconnect/features/home/domain/entity/post_entity.dart';
import 'package:softconnect/features/home/presentation/view/CommentButton.dart';
import 'package:softconnect/features/home/presentation/view/LikeButton.dart';

class PostComponent extends StatelessWidget {
  final PostEntity post;
  final String currentUserId;
  final int likeCount;
  final bool isLiked;
  final int commentCount;
  final VoidCallback onCommentPressed;
  final VoidCallback onLikePressed;

  const PostComponent({
    Key? key,
    required this.post,
    required this.currentUserId,
    required this.likeCount,
    required this.isLiked,
    required this.commentCount,
    required this.onCommentPressed,
    required this.onLikePressed,
  }) : super(key: key);

  String getBackendBaseUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:2000';
    } else if (Platform.isIOS) {
      return 'http://localhost:2000';
    } else {
      return 'http://localhost:2000';
    }
  }

  @override
  Widget build(BuildContext context) {
    final backendBaseUrl = getBackendBaseUrl();

    final imageUrl = (post.imageUrl != null && post.imageUrl!.isNotEmpty)
        ? '$backendBaseUrl/${post.imageUrl!.replaceAll('\\', '/')}'
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    post.user.username.isNotEmpty
                        ? post.user.username[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.user.username,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        post.createdAt.toLocal().toString().split(' ')[0],
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz),
              ],
            ),
            const SizedBox(height: 10),
            // Content text
            Text(post.content),
            const SizedBox(height: 10),

            // Image display if available
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    print('Loading image URL from component: $imageUrl');

                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('Failed to load image'));
                  },
                ),
              ),

            const SizedBox(height: 10),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LikeButton(
                  postId: post.id,
                  userId: currentUserId,
                  isLiked: isLiked,
                  likeCount: likeCount,
                  isLoading: false,
                  onPressed: onLikePressed,
                ),
                CommentButton(
                  commentCount: commentCount,
                  onPressed: onCommentPressed,
                  isLoading: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
