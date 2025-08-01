import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softconnect/core/utils/network_image_util.dart';
import 'package:softconnect/core/utils/getFullImageUrl.dart';
import 'package:softconnect/features/home/domain/entity/post_entity.dart';
import 'package:softconnect/features/home/presentation/view/CommentButton.dart';
import 'package:softconnect/features/home/presentation/view/LikeButton.dart';
import 'package:softconnect/features/profile/presentation/view/user_profile.dart';
import 'package:softconnect/features/profile/presentation/view_model/user_profile_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view_model/Comment_view_model/comment_view_model.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_viewmodel.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';

class PostComponent extends StatelessWidget {
  final PostEntity post;
  final String currentUserId;
  final int likeCount;
  final bool isLiked;
  final int commentCount;
  final VoidCallback onCommentPressed;
  final VoidCallback onLikePressed;
  final VoidCallback? onUpdatePressed;
  final VoidCallback? onDeletePressed;

  const PostComponent({
    Key? key,
    required this.post,
    required this.currentUserId,
    required this.likeCount,
    required this.isLiked,
    required this.commentCount,
    required this.onCommentPressed,
    required this.onLikePressed,
    this.onUpdatePressed,
    this.onDeletePressed,
  }) : super(key: key);

  void navigateToUserProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider<UserProfileViewModel>(
              create: (_) => serviceLocator<UserProfileViewModel>(),
            ),
            BlocProvider<FeedViewModel>(
              create: (_) => serviceLocator<FeedViewModel>(),
            ),
            BlocProvider<CommentViewModel>(
              create: (_) => serviceLocator<CommentViewModel>(),
            ),
          ],
          child: UserProfilePage(userId: post.user.userId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = getFullImageUrl(post.imageUrl);
    final profileImageUrl = getFullImageUrl(post.user.profilePhoto);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => navigateToUserProfile(context),
                  child: profileImageUrl != null
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
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => navigateToUserProfile(context),
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
                ),
                if (currentUserId == post.user.userId)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz),
                    onSelected: (value) {
                      if (value == 'update') {
                        onUpdatePressed?.call();
                      } else if (value == 'delete') {
                        onDeletePressed?.call();
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'update',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Update Post'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete Post', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox(width: 24),
              ],
            ),

            const SizedBox(height: 10),

            if (post.content.isNotEmpty)
              Text(
                post.content,
                style: const TextStyle(fontSize: 15),
              ),

            const SizedBox(height: 10),

            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: NetworkImageWidget(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: const Center(child: CircularProgressIndicator()),
                    errorWidget: const Center(child: Text('Failed to load image')),
                  ),
                ),
              ),

            const SizedBox(height: 12),

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
