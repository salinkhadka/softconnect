import 'package:flutter/material.dart';
import 'package:softconnect/app/constants/api_endpoints.dart';
import 'package:softconnect/app/theme/colors/themecolor.dart';
import 'package:softconnect/features/home/domain/entity/post_entity.dart';
import 'package:softconnect/features/home/presentation/view/LikeButton.dart';
import 'package:softconnect/features/home/presentation/view/CommentButton.dart';
import 'package:softconnect/core/utils/network_image_util.dart';
import 'package:softconnect/core/utils/getFullImageUrl.dart';

class PostCard extends StatelessWidget {
  final PostEntity post;
  final String? currentUserId;
  final bool isLiked;
  final int likeCount;
  final int commentCount;
  final VoidCallback onLikePressed;
  final VoidCallback onCommentPressed;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onUpdatePressed;

  const PostCard({
    super.key,
    required this.post,
    this.currentUserId,
    this.isLiked = false,
    this.likeCount = 0,
    this.commentCount = 0,
    required this.onLikePressed,
    required this.onCommentPressed,
    this.onDeletePressed,
    this.onUpdatePressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final fullImageUrl = getFullImageUrl(post.imageUrl);
    final profileImageUrl = getFullImageUrl(post.user.profilePhoto);

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: isTablet ? 12 : 8,
        horizontal: isTablet ? 16 : 0,
      ),
      child: Card(
        elevation: 3,
        color: Themecolor.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Themecolor.lavender.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                children: [
                  profileImageUrl != null && profileImageUrl.isNotEmpty
                      ? CircleAvatar(
                          radius: isTablet ? 24 : 20,
                          backgroundColor: Themecolor.lavender,
                          backgroundImage: NetworkImage(profileImageUrl),
                        )
                      : CircleAvatar(
                          radius: isTablet ? 24 : 20,
                          backgroundColor: Themecolor.lavender,
                          child: Text(
                            post.user.username[0].toUpperCase(),
                            style: TextStyle(
                              color: Themecolor.purple,
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  SizedBox(width: isTablet ? 12 : 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.user.username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 18 : 16,
                            color: Themecolor.purple,
                          ),
                        ),
                        Text(
                          post.createdAt.toLocal().toString().split(' ')[0],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: isTablet ? 14 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: isTablet ? 24 : 20,
                      color: Themecolor.purple,
                    ),
                    color: Themecolor.white,
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDeletePressed?.call();
                      } else if (value == 'update') {
                        onUpdatePressed?.call();
                      }
                    },
                    itemBuilder: (context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'update',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Themecolor.purple, size: isTablet ? 20 : 18),
                            SizedBox(width: isTablet ? 12 : 8),
                            Text(
                              'Update Post',
                              style: TextStyle(
                                color: Themecolor.purple,
                                fontSize: isTablet ? 16 : 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: isTablet ? 20 : 18),
                            SizedBox(width: isTablet ? 12 : 8),
                            Text(
                              'Delete Post',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: isTablet ? 16 : 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: isTablet ? 12 : 10),

              /// CONTENT
              if (post.content.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: isTablet ? 12 : 10),
                  child: Text(
                    post.content,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 15,
                      color: Themecolor.purple,
                      height: 1.4,
                    ),
                  ),
                ),

              /// IMAGE
              if (fullImageUrl != null && fullImageUrl.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: NetworkImageWidget(
                      imageUrl: fullImageUrl,
                      width: double.infinity,
                      height: isTablet ? 300 : 250,
                      fit: BoxFit.cover,
                      placeholder: Container(
                        height: isTablet ? 300 : 250,
                        color: Themecolor.lavender.withOpacity(0.1),
                        child: Center(
                          child: CircularProgressIndicator(color: Themecolor.purple),
                        ),
                      ),
                      errorWidget: Container(
                        height: isTablet ? 300 : 250,
                        color: Themecolor.lavender.withOpacity(0.1),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                color: Themecolor.lavender,
                                size: isTablet ? 48 : 40,
                              ),
                              SizedBox(height: isTablet ? 12 : 8),
                              Text(
                                'Image load failed',
                                style: TextStyle(
                                  color: Themecolor.lavender,
                                  fontSize: isTablet ? 16 : 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              /// ACTIONS
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 8 : 4,
                  vertical: isTablet ? 8 : 4,
                ),
                decoration: BoxDecoration(
                  color: Themecolor.lavender.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
