import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/core/utils/network_image_util.dart'; // Import reusable image widget
import 'package:softconnect/features/home/presentation/view/CommentModal.dart';
import 'package:softconnect/features/home/presentation/view/post_component.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_event.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_state.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view_model/Comment_view_model/comment_view_model.dart';

class FeedPage extends StatefulWidget {
  final String currentUserId;

  const FeedPage({
    Key? key,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  // Pull-to-refresh handler
  Future<void> _refreshPosts() async {
    // Reload posts by dispatching event
    context.read<FeedViewModel>().add(LoadPostsEvent(widget.currentUserId));
    // Wait until loading completes
    await context.read<FeedViewModel>().stream.firstWhere(
      (state) => !state.isLoading,
      orElse: () => context.read<FeedViewModel>().state,
    );
  }

  @override
  void initState() {
    super.initState();
    // Load posts once widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedViewModel>().add(LoadPostsEvent(widget.currentUserId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedViewModel, FeedState>(
      listener: (context, state) {
        if (state.error != null) {
          // Show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.error}')),
          );
        }
      },
      builder: (context, state) {
        // Show loading indicator while posts are loading
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show error UI with retry button if there's an error
        if (state.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<FeedViewModel>()
                        .add(LoadPostsEvent(widget.currentUserId));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Show message if no posts are available
        if (state.posts.isEmpty) {
          return const Center(child: Text('No posts available'));
        }

        // Main list of posts with pull-to-refresh support
        return RefreshIndicator(
          onRefresh: _refreshPosts,
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: state.posts.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Text(
                    'Welcome!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                );
              }

              final post = state.posts[index - 1];

              return PostComponent(
                post: post,
                currentUserId: widget.currentUserId,
                likeCount: state.likeCounts[post.id] ?? 0,
                isLiked: state.isLikedMap[post.id] ?? false,
                commentCount: state.commentCounts[post.id] ?? 0,
                onLikePressed: () {
                  final isLiked = state.isLikedMap[post.id] ?? false;
                  final feedViewModel = context.read<FeedViewModel>();
                  
                  if (isLiked) {
                    feedViewModel.add(UnlikePostEvent(
                      postId: post.id,
                      userId: widget.currentUserId,
                    ));
                  } else {
                    feedViewModel.add(LikePostEvent(
                      postId: post.id,
                      userId: widget.currentUserId,
                    ));
                  }
                },
                onCommentPressed: () {
                  final commentViewModel = serviceLocator<CommentViewModel>();

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => BlocProvider.value(
                      value: commentViewModel,
                      child: CommentModal(
                        postId: post.id,
                        userId: widget.currentUserId,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
