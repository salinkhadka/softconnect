import 'package:flutter/material.dart';
import 'package:softconnect/features/home/domain/entity/post_entity.dart';
import 'package:softconnect/features/home/presentation/view/LikeButton.dart';
import 'package:softconnect/features/home/presentation/view/CommentButton.dart';
import 'package:softconnect/core/utils/network_image_util.dart';

class PostCard extends StatelessWidget {
  final PostEntity post;
  final String? currentUserId;
  final bool isLiked;
  final int likeCount;
  final int commentCount;
  final VoidCallback onLikePressed;
  final VoidCallback onCommentPressed;

  const PostCard({
    super.key,
    required this.post,
    this.currentUserId,
    this.isLiked = false,
    this.likeCount = 0,
    this.commentCount = 0,
    required this.onLikePressed,
    required this.onCommentPressed,
  });

  String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    return imagePath.contains('http')
        ? imagePath
        : 'http://10.0.2.2:2000/${imagePath.replaceAll("\\", "/")}';
  }

  @override
  Widget build(BuildContext context) {
    final fullImageUrl = getFullImageUrl(post.imageUrl);
    final profileImageUrl = getFullImageUrl(post.user.profilePhoto);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER: User Info
            Row(
              children: [
                profileImageUrl.isNotEmpty
                    ? CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(profileImageUrl),
                      )
                    : CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blueGrey,
                        child: Text(
                          post.user.username[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.user.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        post.createdAt.toLocal().toString().split(' ')[0],
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, size: 20),
              ],
            ),

            const SizedBox(height: 10),

            /// POST TEXT
            if (post.content.isNotEmpty)
              Text(
                post.content,
                style: const TextStyle(fontSize: 15),
              ),

            const SizedBox(height: 10),

            /// POST IMAGE
            if (fullImageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: NetworkImageWidget(
                  imageUrl: fullImageUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  placeholder: const Center(child: CircularProgressIndicator()),
                  errorWidget: const Center(child: Text('Image load failed')),
                ),
              ),

            const SizedBox(height: 12),

            /// LIKE + COMMENT ACTIONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LikeButton(
                  postId: post.id,
                  userId: currentUserId ?? '',
                  isLiked: isLiked,
                  likeCount: likeCount,
                  isLoading: false,
                  onPressed: onLikePressed,
                ),
                CommentButton(
                  commentCount: commentCount,
                  isLoading: false,
                  onPressed: onCommentPressed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
