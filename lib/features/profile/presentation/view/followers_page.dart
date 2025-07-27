import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/constants/api_endpoints.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/app/theme/colors/themecolor.dart';
import 'package:softconnect/features/friends/domain/entity/follow_entity.dart';
import 'package:softconnect/features/friends/domain/use_case/get_followers_usecase.dart';
import 'package:softconnect/features/friends/domain/use_case/follow_user_usecase.dart';
import 'package:softconnect/features/friends/domain/use_case/unfollow_user_usecase.dart';
import 'package:softconnect/features/friends/domain/use_case/get_following_usecase.dart';
import 'package:softconnect/features/profile/presentation/view/user_profile.dart';

class FollowersPage extends StatefulWidget {
  final String userId;
  final String userName;

  const FollowersPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  List<FollowEntity> followers = [];
  Set<String> followingUsers = {}; // Track who current user is following
  bool isLoading = true;
  String? error;
  late String currentUserId;
  
  late final GetFollowersUseCase _getFollowersUseCase;
  late final GetFollowingUseCase _getFollowingUseCase;
  late final FollowUserUseCase _followUserUseCase;
  late final UnfollowUserUseCase _unfollowUserUseCase;

  @override
  void initState() {
    super.initState();
    _initializeUseCases();
    _loadCurrentUser();
  }

  void _initializeUseCases() {
    _getFollowersUseCase = serviceLocator<GetFollowersUseCase>();
    _getFollowingUseCase = serviceLocator<GetFollowingUseCase>();
    _followUserUseCase = serviceLocator<FollowUserUseCase>();
    _unfollowUserUseCase = serviceLocator<UnfollowUserUseCase>();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString('userId') ?? '';
    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Load followers
      final followersResult = await _getFollowersUseCase.call(
        GetFollowersParams(widget.userId),
      );

      // Load current user's following list to show correct follow buttons
      final followingResult = await _getFollowingUseCase.call(
        GetFollowingParams(currentUserId),
      );

      followersResult.fold(
        (failure) {
          setState(() {
            error = failure.toString();
            isLoading = false;
          });
        },
        (followersList) {
          followers = followersList;
          
          // Process following result
          followingResult.fold(
            (_) {}, // Ignore failure for following (optional data)
            (followingList) {
              followingUsers = followingList
                  .map((follow) => follow.id!)
                  .toSet();
            },
          );

          setState(() {
            isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _toggleFollow(String targetUserId) async {
    final isFollowing = followingUsers.contains(targetUserId);

    try {
      if (isFollowing) {
        // Unfollow
        final result = await _unfollowUserUseCase.call(
          UnfollowUserParams(targetUserId),
        );

        result.fold(
          (failure) {
            _showSnackBar('Failed to unfollow: ${failure.toString()}', Colors.red);
          },
          (_) {
            setState(() {
              followingUsers.remove(targetUserId);
            });
            _showSnackBar('Unfollowed successfully',Color(0xFF37225C));
          },
        );
      } else {
        // Follow
        final result = await _followUserUseCase.call(
          FollowUserParams(targetUserId),
        );

        result.fold(
          (failure) {
            _showSnackBar('Failed to follow: ${failure.toString()}', Colors.red);
          },
          (_) {
            setState(() {
              followingUsers.add(targetUserId);
            });
            _showSnackBar('Followed successfully',Color(0xFF37225C));
          },
        );
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    const baseUrl = ApiEndpoints.serverAddress;
    return imagePath.startsWith('http')
        ? imagePath
        : '$baseUrl/${imagePath.replaceAll("\\", "/")}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.userName}\'s Followers'),
        backgroundColor: Themecolor.purple,
        foregroundColor: Themecolor.white,
        elevation: 1,
      ),
      backgroundColor: Themecolor.white,
      body: RefreshIndicator(
        color: Themecolor.purple,
        onRefresh: _loadData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: Themecolor.purple));
    }

    if (error != null) {
      return _buildErrorWidget();
    }

    if (followers.isEmpty) {
      return _buildEmptyWidget();
    }

    return ListView.builder(
      itemCount: followers.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final follower = followers[index];
        return _buildFollowerCard(follower);
      },
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Themecolor.lavender),
          const SizedBox(height: 16),
          Text('Error: $error', style: TextStyle(color: Themecolor.purple)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Themecolor.purple,
              foregroundColor: Themecolor.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Themecolor.lavender),
          const SizedBox(height: 16),
          Text(
            'No followers yet',
            style: TextStyle(fontSize: 18, color: Themecolor.purple),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowerCard(FollowEntity follower) {
    final isCurrentUser = follower.followerId == currentUserId;
    final profileImageUrl = getFullImageUrl(follower.profilePhoto);
    final isFollowing = followingUsers.contains(follower.followerId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      color: Themecolor.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Themecolor.lavender,
          backgroundImage: profileImageUrl.isNotEmpty
              ? NetworkImage(profileImageUrl)
              : null,
          child: profileImageUrl.isEmpty
              ? Text(
                  follower.username![0].toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Themecolor.purple,
                  ),
                )
              : null,
        ),
        title: Text(
          follower.username!,
          style: TextStyle(fontWeight: FontWeight.w600, color: Themecolor.purple),
        ),
        subtitle: Text('@${follower.username!}', style: TextStyle(color: Themecolor.lavender)),
        trailing: _buildTrailingWidget(isCurrentUser, isFollowing, follower.followerId),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfilePage(
                userId: follower.followerId,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget? _buildTrailingWidget(bool isCurrentUser, bool isFollowing, String userId) {
    if (isCurrentUser) {
      return Chip(
        label: const Text('You', style: TextStyle(fontSize: 12)),
        backgroundColor: Themecolor.purple,
        labelStyle: const TextStyle(color: Colors.white),
      );
    }

    return SizedBox(
      width: 80,
      child: ElevatedButton(
        onPressed: () => _toggleFollow(userId),
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing ? Themecolor.lavender : Themecolor.purple,
          foregroundColor: isFollowing ? Themecolor.purple : Themecolor.white,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: const Size(60, 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          isFollowing ? 'Unfollow' : 'Follow',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
