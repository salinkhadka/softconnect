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

  @override
  void initState() {
    super.initState();
    // Load followers by default
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
                    child: Text(showFollowers ? 'No followers yet.' : 'Not following anyone.'),
                  );
                }

                return ListView.separated(
  itemCount: list.length,
  separatorBuilder: (_, __) => const Divider(),
  itemBuilder: (context, index) {
    final follow = list[index];
    final displayUserId = showFollowers ? follow.followerId : follow.followeeId;

    return ListTile(
      title: Text('User ID: $displayUserId'),
      subtitle: Text('Followed at: ${follow.createdAt.toLocal()}'),
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
