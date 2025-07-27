import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/constants/api_endpoints.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/app/theme/colors/themecolor.dart';
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
  Set<String> currentUserFollowing = {};
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
        (_) {},
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
              
              if (isOwnProfile) {
                following.removeWhere((follow) => follow.id == targetUserId);
              }
            });
            _showSnackBar('Unfollowed successfully',Color(0xFF37225C));
          },
        );
      } else {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Themecolor.white,
      appBar: AppBar(
        title: Text(
          '${widget.userName}\'s Following',
          style: TextStyle(
            fontSize: isTablet ? 22 : 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Themecolor.purple,
        foregroundColor: Themecolor.white,
        elevation: 1,
      ),
      body: RefreshIndicator(
        color: Themecolor.purple,
        onRefresh: _loadData,
        child: _buildBody(isTablet),
      ),
    );
  }

  Widget _buildBody(bool isTablet) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Themecolor.purple),
      );
    }

    if (error != null) {
      return _buildErrorWidget(isTablet);
    }

    if (following.isEmpty) {
      return _buildEmptyWidget(isTablet);
    }

    return ListView.builder(
      itemCount: following.length,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 16 : 8,
      ),
      itemBuilder: (context, index) {
        final followingUser = following[index];
        return _buildFollowingCard(followingUser, isTablet);
      },
    );
  }

  Widget _buildErrorWidget(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: isTablet ? 80 : 64,
            color: Themecolor.lavender,
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            'Error: $error',
            style: TextStyle(
              color: Themecolor.purple,
              fontSize: isTablet ? 18 : 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isTablet ? 24 : 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Themecolor.purple,
              foregroundColor: Themecolor.white,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 24,
                vertical: isTablet ? 16 : 12,
              ),
            ),
            child: Text(
              'Retry',
              style: TextStyle(fontSize: isTablet ? 16 : 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add_outlined,
            size: isTablet ? 80 : 64,
            color: Themecolor.lavender,
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            'Not following anyone yet',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              color: Themecolor.purple,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowingCard(FollowEntity followingUser, bool isTablet) {
    final isCurrentUser = followingUser.id == currentUserId;
    final profileImageUrl = getFullImageUrl(followingUser.profilePhoto);
    final isFollowing = currentUserFollowing.contains(followingUser.id);

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
      child: Card(
        elevation: 2,
        color: Themecolor.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Themecolor.lavender.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 12 : 8,
          ),
          leading: CircleAvatar(
            radius: isTablet ? 28 : 25,
            backgroundColor: Themecolor.lavender,
            backgroundImage: profileImageUrl.isNotEmpty
                ? NetworkImage(profileImageUrl)
                : null,
            child: profileImageUrl.isEmpty
                ? Text(
                    followingUser.username![0].toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 20 : 18,
                      color: Themecolor.purple,
                    ),
                  )
                : null,
          ),
          title: Text(
            followingUser.username!,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: isTablet ? 18 : 16,
              color: Themecolor.purple,
            ),
          ),
          subtitle: Text(
            '@${followingUser.username}',
            style: TextStyle(
              color: Themecolor.lavender,
              fontSize: isTablet ? 16 : 14,
            ),
          ),
          trailing: _buildTrailingWidget(isCurrentUser, isFollowing, followingUser.id!, isTablet),
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
      ),
    );
  }

  Widget? _buildTrailingWidget(bool isCurrentUser, bool isFollowing, String userId, bool isTablet) {
    if (isCurrentUser) {
      return Chip(
        label: Text(
          'You',
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            color: Themecolor.white,
          ),
        ),
        backgroundColor: Themecolor.purple,
      );
    }

    if (!isOwnProfile) {
      return SizedBox(
        width: isTablet ? 90 : 80,
        child: ElevatedButton(
          onPressed: () => _toggleFollow(userId),
          style: ElevatedButton.styleFrom(
            backgroundColor: isFollowing ? Themecolor.lavender : Themecolor.purple,
            foregroundColor: isFollowing ? Themecolor.purple : Themecolor.white,
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 8),
            minimumSize: Size(isTablet ? 70 : 60, isTablet ? 36 : 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            isFollowing ? 'Unfollow' : 'Follow',
            style: TextStyle(
              fontSize: isTablet ? 12 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (isOwnProfile) {
      return SizedBox(
        width: isTablet ? 90 : 80,
        child: ElevatedButton(
          onPressed: () => _toggleFollow(userId),
          style: ElevatedButton.styleFrom(
            backgroundColor: Themecolor.lavender,
            foregroundColor: Themecolor.purple,
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 8),
            minimumSize: Size(isTablet ? 70 : 60, isTablet ? 36 : 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            'Unfollow',
            style: TextStyle(
              fontSize: isTablet ? 12 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return null;
  }
}
