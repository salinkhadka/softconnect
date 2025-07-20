import 'package:flutter/material.dart';

class ProfileHeaderComponent extends StatelessWidget {
  final dynamic user;
  final String Function(String?) getFullImageUrl;

  const ProfileHeaderComponent({
    super.key,
    required this.user,
    required this.getFullImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final profileImageUrl = getFullImageUrl(user.profilePhoto);

    return Center(
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
    );
  }
}