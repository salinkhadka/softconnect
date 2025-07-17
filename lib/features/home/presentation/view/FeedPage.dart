import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/features/home/presentation/view/CommentModal.dart';
import 'package:softconnect/features/home/presentation/view/post_component.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_event.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_state.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view_model/comment_view_model/comment_view_model.dart';

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
  @override
  void initState() {
    super.initState();
    // Pass currentUserId when loading posts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedViewModel>().add(LoadPostsEvent(widget.currentUserId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedViewModel, FeedState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.error}')),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Pass currentUserId when retrying
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

        if (state.posts.isEmpty) {
          return const Center(child: Text('No posts available'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: state.posts.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                child: const Text(
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider<CommentViewModel>(
                      create: (context) => serviceLocator<CommentViewModel>(),
                      child: CommentModal(
                        postId: post.id,
                        userId: widget.currentUserId,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
