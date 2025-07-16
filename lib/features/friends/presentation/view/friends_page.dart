import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softconnect/features/friends/presentation/view_model/follow_event.dart';
import 'package:softconnect/features/friends/presentation/view_model/follow_state.dart';
import 'package:softconnect/features/friends/presentation/view_model/follow_viewmodel.dart';

class FriendsPage extends StatefulWidget {
  final String userId; // Pass the user ID whose followers/following you want

  const FriendsPage({super.key, required this.userId});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  bool showFollowers = true;

  String getBackendBaseUrl() {
    if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to reach localhost
      return 'http://10.0.2.2:2000';
    } else if (Platform.isIOS) {
      // For iOS simulator or real devices, adjust accordingly
      return 'http://localhost:2000';
    } else {
      // fallback or other platforms
      return 'http://localhost:2000';
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<FollowViewModel>().add(LoadFollowersEvent(widget.userId));
  }

  void _toggleView(bool followers) {
    setState(() => showFollowers = followers);
    if (followers) {
      context.read<FollowViewModel>().add(LoadFollowersEvent(widget.userId));
    } else {
      context.read<FollowViewModel>().add(LoadFollowingEvent(widget.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final backendBaseUrl = getBackendBaseUrl();

    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: Column(
        children: [
          ToggleButtons(
            isSelected: [showFollowers, !showFollowers],
            onPressed: (index) => _toggleView(index == 0),
            children: const [
              Padding(padding: EdgeInsets.all(10), child: Text('Followers')),
              Padding(padding: EdgeInsets.all(10), child: Text('Following')),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<FollowViewModel, FollowState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = showFollowers ? state.followers : state.following;

                if (list.isEmpty) {
                  return Center(
                    child: Text(showFollowers
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

                    final imageUrl = (photo != null && photo.isNotEmpty)
                        ? '$backendBaseUrl/uploads/${photo.replaceAll('\\', '/')}'
                        : null;

                    return ListTile(
                      leading: photo != null && photo.isNotEmpty
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                'http://10.0.2.2:2000/${photo.replaceAll('\\', '/')}',
                              ),
                            )
                          : const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                      title: Text(username),
                      subtitle: Text(
                          'Followed at: ${createdAt.toString().substring(0, 16)}'),
                      trailing: !showFollowers
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
                                      .add(LoadFollowingEvent(widget.userId));
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
      ),
    );
  }
}
