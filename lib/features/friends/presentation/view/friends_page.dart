import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:softconnect/app/constants/api_endpoints.dart';
import 'package:softconnect/app/theme/theme_provider.dart';
import 'package:softconnect/features/friends/presentation/view_model/follow_event.dart';
import 'package:softconnect/features/friends/presentation/view_model/follow_state.dart';
import 'package:softconnect/features/friends/presentation/view_model/follow_viewmodel.dart';
import 'package:softconnect/features/profile/presentation/view/user_profile.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_viewmodel.dart';
import 'package:softconnect/features/profile/presentation/view_model/user_profile_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view_model/Comment_view_model/comment_view_model.dart';

class FriendsPage extends StatelessWidget {
  final String userId;

  const FriendsPage({super.key, required this.userId});

  String getBackendBaseUrl() {
    if (Platform.isAndroid) {
      return ApiEndpoints.serverAddress;
    } else if (Platform.isIOS) {
      return 'http://localhost:2000';
    } else {
      return 'http://localhost:2000';
    }
  }

  void navigateToUserProfile(BuildContext context, String userId) {
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
          child: UserProfilePage(userId: userId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backendBaseUrl = getBackendBaseUrl();

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Friends',
              style: TextStyle(
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
            ),
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
            elevation: Theme.of(context).appBarTheme.elevation,
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: BlocBuilder<FollowViewModel, FollowState>(
            builder: (context, state) {
              if (!state.isLoading &&
                  state.followers.isEmpty &&
                  state.following.isEmpty) {
                context.read<FollowViewModel>().add(ShowFollowersViewEvent());
              }

              return Column(
                children: [
                  Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ToggleButtons(
                      isSelected: [state.showFollowers, !state.showFollowers],
                      onPressed: (index) {
                        if (index == 0) {
                          context.read<FollowViewModel>().add(ShowFollowersViewEvent());
                        } else {
                          context.read<FollowViewModel>().add(ShowFollowingViewEvent());
                        }
                      },
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      selectedColor: Theme.of(context).colorScheme.onPrimary,
                      fillColor: Theme.of(context).primaryColor,
                      borderColor: Theme.of(context).dividerColor,
                      selectedBorderColor: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(8),
                      children: const [
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Text('Followers')),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Text('Following')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: state.isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        : Builder(
                            builder: (_) {
                              final list =
                                  state.showFollowers ? state.followers : state.following;

                              if (list.isEmpty) {
                                return Center(
                                  child: Text(
                                    state.showFollowers
                                        ? 'No followers yet.'
                                        : 'Not following anyone.',
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                      fontSize: 16,
                                    ),
                                  ),
                                );
                              }

                              return ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: list.length,
                                separatorBuilder: (_, __) => Divider(
                                  color: Theme.of(context).dividerColor,
                                  height: 1,
                                ),
                                itemBuilder: (context, index) {
                                  final follow = list[index];

                                  final username = follow.username ?? 'Unknown';
                                  final photo = follow.profilePhoto;
                                  final createdAt = follow.createdAt.toLocal();

                                  // Build image URL only if photo is not null/empty
                                  String? imageUrl;
                                  if (photo != null && photo.isNotEmpty) {
                                    imageUrl =
                                        '$backendBaseUrl/${photo.replaceAll('\\', '/')}';
                                  }

                                  // Determine the user ID to navigate to
                                  String targetUserId;
                                  if (state.showFollowers) {
                                    // For followers, navigate to the follower's profile
                                    targetUserId = follow.followerId;
                                  } else {
                                    // For following, navigate to the followee's profile
                                    targetUserId = follow.followeeId;
                                  }

                                  return Card(
                                    color: Theme.of(context).cardColor,
                                    elevation: 1,
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      leading: GestureDetector(
                                        onTap: () => navigateToUserProfile(context, targetUserId),
                                        child: (imageUrl != null)
                                            ? CircleAvatar(
                                                radius: 22,
                                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                                child: ClipOval(
                                                  child: Image.network(
                                                    imageUrl,
                                                    height: 44,
                                                    width: 44,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder:
                                                        (context, child, loadingProgress) {
                                                      if (loadingProgress == null) return child;
                                                      return Center(
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Theme.of(context).primaryColor,
                                                        ),
                                                      );
                                                    },
                                                    errorBuilder:
                                                        (context, error, stackTrace) {
                                                      return Icon(
                                                        Icons.person,
                                                        size: 32,
                                                        color: Theme.of(context).primaryColor,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              )
                                            : CircleAvatar(
                                                radius: 22,
                                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                                child: Icon(
                                                  Icons.person,
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                              ),
                                      ),
                                      title: GestureDetector(
                                        onTap: () => navigateToUserProfile(context, targetUserId),
                                        child: Text(
                                          username,
                                          style: TextStyle(
                                            color: Theme.of(context).textTheme.titleMedium?.color,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Followed at: ${createdAt.toString().substring(0, 16)}',
                                        style: TextStyle(
                                          color: Theme.of(context).textTheme.bodySmall?.color,
                                        ),
                                      ),
                                      trailing: !state.showFollowers
                                          ? ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 12, vertical: 8),
                                                textStyle: const TextStyle(fontSize: 14),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                              ),
                                              onPressed: () {
                                                context.read<FollowViewModel>().add(
                                                      UnfollowUserEvent(
                                                        followeeId: follow.followeeId,
                                                        context: context,
                                                      ),
                                                    );
                                                Future.delayed(
                                                    const Duration(milliseconds: 500), () {
                                                  context
                                                      .read<FollowViewModel>()
                                                      .add(ShowFollowingViewEvent());
                                                });
                                              },
                                              child: const Text('Unfollow'),
                                            )
                                          : null,
                                      onTap: () => navigateToUserProfile(context, targetUserId),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}