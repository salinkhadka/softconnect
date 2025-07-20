import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/features/friends/domain/entity/follow_entity.dart';
import 'package:softconnect/features/friends/domain/use_case/get_following_usecase.dart';
import 'package:softconnect/features/friends/domain/use_case/follow_user_usecase.dart';
import 'package:softconnect/features/friends/domain/use_case/unfollow_user_usecase.dart';
import 'package:softconnect/features/profile/presentation/view/user_profile.dart';

class FollowingPage extends StatefulWidget {
  final String userId;
  final String userName;

  const FollowingPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  List<FollowEntity> following = [];
  Set<String> currentUserFollowing = {}; // Track who current user is following
  bool isLoading = true;
  String? error;
  late String currentUserId;
  late bool isOwnProfile;
  
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
    _getFollowingUseCase = serviceLocator<GetFollowingUseCase>();
    _followUserUseCase = serviceLocator<FollowUserUseCase>();
    _unfollowUserUseCase = serviceLocator<UnfollowUserUseCase>();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString('userId') ?? '';
    isOwnProfile = widget.userId == currentUserId;
    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Load following list for the profile being viewed
      final followingResult = await _getFollowingUseCase.call(
        GetFollowingParams(widget.userId),
      );

      followingResult.fold(
        (failure) {
          setState(() {
            error = failure.toString();
            isLoading = false;
          });
        },
        (followingList) async {
          following = followingList;
          
          // If not viewing own profile, load current user's following to show correct buttons
          if (!isOwnProfile) {
            await _loadCurrentUserFollowing();
          }
          
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

  Future<void> _loadCurrentUserFollowing() async {
    try {
      final result = await _getFollowingUseCase.call(
        GetFollowingParams(currentUserId),
      );

      result.fold(
        (_) {}, // Ignore error for this optional data
        (currentUserFollowingList) {
          currentUserFollowing = currentUserFollowingList
              .map((follow) => follow.id!)
              .toSet();
        },
      );
    } catch (e) {
      print('Error loading current user following: $e');
    }
  }

  Future<void> _toggleFollow(String targetUserId) async {
    final isFollowing = currentUserFollowing.contains(targetUserId);

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
              currentUserFollowing.remove(targetUserId);
              
              // If viewing own profile, also remove from the following list
              if (isOwnProfile) {
                following.removeWhere((follow) => follow.id == targetUserId);
              }
            });
            _showSnackBar('Unfollowed successfully', Colors.green);
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
              currentUserFollowing.add(targetUserId);
            });
            _showSnackBar('Followed successfully', Colors.green);
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
    const baseUrl = 'http://10.0.2.2:2000';
    return imagePath.startsWith('http')
        ? imagePath
        : '$baseUrl/${imagePath.replaceAll("\\", "/")}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.userName}\'s Following'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return _buildErrorWidget();
    }

    if (following.isEmpty) {
      return _buildEmptyWidget();
    }

    return ListView.builder(
      itemCount: following.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final followingUser = following[index];
        return _buildFollowingCard(followingUser);
      },
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_add_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Not following anyone yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowingCard(FollowEntity followingUser) {
    final isCurrentUser = followingUser.id == currentUserId;
    final profileImageUrl = getFullImageUrl(followingUser.profilePhoto);
    final isFollowing = currentUserFollowing.contains(followingUser.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: profileImageUrl.isNotEmpty
              ? NetworkImage(profileImageUrl)
              : null,
          child: profileImageUrl.isEmpty
              ? Text(
                  followingUser.username![0].toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )
              : null,
        ),
        title: Text(
          followingUser.username!,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('@${followingUser.username}'),
        trailing: _buildTrailingWidget(isCurrentUser, isFollowing, followingUser.id!),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfilePage(
                userId: followingUser.id,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget? _buildTrailingWidget(bool isCurrentUser, bool isFollowing, String userId) {
    if (isCurrentUser) {
      return const Chip(
        label: Text('You', style: TextStyle(fontSize: 12)),
        backgroundColor: Colors.blue,
        labelStyle: TextStyle(color: Colors.white),
      );
    }

    // Show follow/unfollow button for other users (except when viewing own profile)
    if (!isOwnProfile) {
      return SizedBox(
        width: 80,
        child: ElevatedButton(
          onPressed: () => _toggleFollow(userId),
          style: ElevatedButton.styleFrom(
            backgroundColor: isFollowing ? Colors.grey[300] : Colors.blue,
            foregroundColor: isFollowing ? Colors.black87 : Colors.white,
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

    // When viewing own profile, show unfollow button
    if (isOwnProfile) {
      return SizedBox(
        width: 80,
        child: ElevatedButton(
          onPressed: () => _toggleFollow(userId),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(60, 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Unfollow',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return null;
  }
}