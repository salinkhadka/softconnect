import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softconnect/features/profile/presentation/view_model/user_profile_viewmodel.dart';

class ProfileActionButtonsComponent extends StatelessWidget {
  final bool isOwnProfile;
  final dynamic profileState;
  final String viewingUserId;
  final VoidCallback onEditProfile;

  const ProfileActionButtonsComponent({
    super.key,
    required this.isOwnProfile,
    required this.profileState,
    required this.viewingUserId,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    if (isOwnProfile) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: ElevatedButton(
            onPressed: onEditProfile,
            child: const Text('Edit Profile'),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => context
              .read<UserProfileViewModel>()
              .toggleFollow(viewingUserId),
          child: Text(
              profileState.isFollowing ? 'Unfollow' : 'Follow'),
        ),
        OutlinedButton(
          onPressed: () {
            // TODO: Navigate to message screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Messages feature coming soon!')),
            );
          },
          child: const Text('Message'),
        ),
      ],
    );
  }
}
