import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/core/utils/network_image_util.dart';
import 'package:softconnect/features/home/presentation/view/CommentModal.dart';
import 'package:softconnect/features/home/presentation/view/post_component.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_event.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_viewmodel.dart';
import 'package:softconnect/features/profile/presentation/view_model/user_profile_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view_model/Comment_view_model/comment_view_model.dart';

class UserProfilePage extends StatefulWidget {
  final String? userId;

  const UserProfilePage({super.key, this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late String viewingUserId;
  late bool isOwnProfile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('userId');

    setState(() {
      viewingUserId = widget.userId ?? currentUserId!;
      isOwnProfile = widget.userId == null || widget.userId == currentUserId;
    });

    context.read<UserProfileViewModel>().loadUserProfile(viewingUserId);
    context.read<FeedViewModel>().add(LoadPostsEvent(viewingUserId));
  }

  String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    const baseUrl = 'http://10.0.2.2:2000';
    return imagePath.startsWith('http')
        ? imagePath
        : '$baseUrl/${imagePath.replaceAll("\\", "/")}';
  }

  @override
  Widget build(BuildContext context) {
    final feedViewModel = context.watch<FeedViewModel>();

    return BlocBuilder<UserProfileViewModel, UserProfileState>(
      builder: (context, profileState) {
        final user = profileState.user;

        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final posts = feedViewModel.state.posts
            .where((p) => p.user.userId == viewingUserId)
            .toList();

        final profileImageUrl = getFullImageUrl(user.profilePhoto);

        return Scaffold(
          appBar: AppBar(
            title: Text(isOwnProfile ? 'My Profile' : user.username),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await context.read<UserProfileViewModel>().loadUserProfile(viewingUserId);
              context.read<FeedViewModel>().add(LoadPostsEvent(viewingUserId));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                /// Profile Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: profileImageUrl.isNotEmpty
                            ? NetworkImage(profileImageUrl)
                            : null,
                        child: profileImageUrl.isEmpty
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.username,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text('@${user.username}',
                          style: const TextStyle(color: Colors.grey)),
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          user.bio!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.black87),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// Info Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        if (user.studentId != null) ...[
                          _infoRow("Student ID", user.studentId.toString()),
                          const SizedBox(height: 8),
                        ],
                        _infoRow("Role", user.role),
                        const SizedBox(height: 8),
                        _infoRow("Followers", '${user.followersCount ?? 0}'),
                        const SizedBox(height: 8),
                        _infoRow("Following", '${user.followingCount ?? 0}'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                if (!isOwnProfile)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => context
                            .read<UserProfileViewModel>()
                            .toggleFollow(viewingUserId),
                        child: Text(profileState.isFollowing ? 'Unfollow' : 'Follow'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          // TODO: Navigate to message screen
                        },
                        child: const Text('Message'),
                      ),
                    ],
                  ),

                const Divider(height: 32),

                Text('Posts', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),

                if (posts.isEmpty)
                  const Center(child: Text('No posts available'))
                else
                  ...posts.map((post) {
                    final isLiked = feedViewModel.state.isLikedMap[post.id] ?? false;
                    final likeCount = feedViewModel.state.likeCounts[post.id] ?? 0;
                    final commentCount =
                        feedViewModel.state.commentCounts[post.id] ?? 0;

                    return PostComponent(
                      post: post,
                      currentUserId: viewingUserId,
                      isLiked: isLiked,
                      likeCount: likeCount,
                      commentCount: commentCount,
                      onLikePressed: () {
                        final feedBloc = context.read<FeedViewModel>();
                        if (isLiked) {
                          feedBloc.add(UnlikePostEvent(
                            postId: post.id,
                            userId: viewingUserId,
                          ));
                        } else {
                          feedBloc.add(LikePostEvent(
                            postId: post.id,
                            userId: viewingUserId,
                          ));
                        }
                      },
                      onCommentPressed: () {
                        final commentVM = serviceLocator<CommentViewModel>();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => BlocProvider.value(
                            value: commentVM,
                            child: CommentModal(
                              postId: post.id,
                              userId: viewingUserId,
                            ),
                          ),
                        );
                      },
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }
}
