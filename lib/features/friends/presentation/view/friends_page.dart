import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softconnect/features/friends/presentation/view_model/follow_event.dart';
import 'package:softconnect/features/friends/presentation/view_model/follow_state.dart';
import 'package:softconnect/features/friends/presentation/view_model/follow_viewmodel.dart';

class FriendsPage extends StatelessWidget {
  final String userId;

  const FriendsPage({super.key, required this.userId});

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

    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: BlocBuilder<FollowViewModel, FollowState>(
        builder: (context, state) {
          if (!state.isLoading &&
              state.followers.isEmpty &&
              state.following.isEmpty) {
            context.read<FollowViewModel>().add(ShowFollowersViewEvent());
          }

          return Column(
            children: [
              ToggleButtons(
                isSelected: [state.showFollowers, !state.showFollowers],
                onPressed: (index) {
                  if (index == 0) {
                    context.read<FollowViewModel>().add(ShowFollowersViewEvent());
                  } else {
                    context.read<FollowViewModel>().add(ShowFollowingViewEvent());
                  }
                },
                children: const [
                  Padding(
                      padding: EdgeInsets.all(10), child: Text('Followers')),
                  Padding(
                      padding: EdgeInsets.all(10), child: Text('Following')),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Builder(
                        builder: (_) {
                          final list =
                              state.showFollowers ? state.followers : state.following;

                          if (list.isEmpty) {
                            return Center(
                              child: Text(state.showFollowers
                                  ? 'No followers yet.'
                                  : 'Not following anyone.'),
                            );
                          }

                          return ListView.separated(
                            itemCount: list.length,
                            separatorBuilder: (_, __) => const Divider(),
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

                              // DEBUG PRINTS:
                              print('username: $username');
                              print('photo field: $photo');
                              print('Generated imageUrl: $imageUrl');

                              return ListTile(
                                leading: (imageUrl != null)
                                    ? CircleAvatar(
                                        radius: 22,
                                        backgroundColor: Colors.transparent,
                                        child: ClipOval(
                                          child: Image.network(
                                            imageUrl,
                                            height: 44,
                                            width: 44,
                                            fit: BoxFit.cover,
                                            loadingBuilder:
                                                (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return const Center(
                                                child: CircularProgressIndicator(
                                                    strokeWidth: 2),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              print('Image load error: $error');
                                              return const Icon(Icons.person, size: 32);
                                            },
                                          ),
                                        ),
                                      )
                                    : const CircleAvatar(
                                        radius: 22,
                                        child: Icon(Icons.person),
                                      ),
                                title: Text(username),
                                subtitle: Text(
                                  'Followed at: ${createdAt.toString().substring(0, 16)}',
                                ),
                                trailing: !state.showFollowers
                                    ? ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          textStyle: const TextStyle(fontSize: 14),
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
  }
}
