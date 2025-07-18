import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:softconnect/core/utils/network_image_util.dart';
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

    final profileImageUrl = (post.user.profilePhoto != null &&
            post.user.profilePhoto!.isNotEmpty)
        ? '$backendBaseUrl/${post.user.profilePhoto!.replaceAll('\\', '/')}'
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                profileImageUrl != null
                    ? CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[200],
                        child: ClipOval(
                          child: NetworkImageWidget(
                            imageUrl: profileImageUrl,
                            height: 40,
                            width: 40,
                            fit: BoxFit.cover,
                            placeholder: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: const Icon(
                              Icons.account_circle,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 20,
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
            if (post.content.isNotEmpty)
              Text(
                post.content,
                style: const TextStyle(fontSize: 15),
              ),

            const SizedBox(height: 10),

            // Post image (if any)
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: NetworkImageWidget(
                  imageUrl: imageUrl,
                  height: 250, // Increased height
                  width: double.infinity,
                  fit: BoxFit.cover, // Cover the entire box
                  placeholder: const Center(child: CircularProgressIndicator()),
                  errorWidget: const Center(child: Text('Failed to load image')),
                ),
              ),

            const SizedBox(height: 12),

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
