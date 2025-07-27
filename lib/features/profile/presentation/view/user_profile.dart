import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/constants/api_endpoints.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/core/utils/network_image_util.dart';
import 'package:softconnect/features/friends/domain/use_case/follow_user_usecase.dart';
import 'package:softconnect/features/friends/domain/use_case/get_followers_usecase.dart';
import 'package:softconnect/features/friends/domain/use_case/get_following_usecase.dart';
import 'package:softconnect/features/friends/domain/use_case/unfollow_user_usecase.dart';
import 'package:softconnect/features/home/presentation/view/CommentModal.dart';
import 'package:softconnect/features/home/presentation/view/post_component.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_event.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_viewmodel.dart';
import 'package:softconnect/features/message/presentation/view/message_page.dart';
import 'package:softconnect/features/message/presentation/view_model/message_view_model/message_view_model.dart';
import 'package:softconnect/features/profile/presentation/view_model/user_profile_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view_model/Comment_view_model/comment_view_model.dart';
import 'package:softconnect/features/home/domain/entity/post_entity.dart';
import 'package:softconnect/features/profile/presentation/view/followers_page.dart';
import 'package:softconnect/features/profile/presentation/view/following_page.dart';
import 'package:softconnect/features/auth/presentation/view/View/change_password.dart';
import 'package:softconnect/features/friends/domain/entity/follow_entity.dart';
import 'package:softconnect/features/profile/presentation/view/profile_header_component.dart';

class UserProfilePage extends StatefulWidget {
  final String? userId;

  const UserProfilePage({super.key, this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late String viewingUserId;
  late String currentUserId;
  late bool isOwnProfile;
  
  // Follow/Unfollow state
  bool isFollowing = false;
  bool isLoadingFollow = false;
  List<FollowEntity> followers = [];
  List<FollowEntity> following = [];
  bool isLoadingFollowData = true;

  // Inject use cases
  late final FollowUserUseCase _followUserUseCase;
  late final UnfollowUserUseCase _unfollowUserUseCase;
  late final GetFollowersUseCase _getFollowersUseCase;
  late final GetFollowingUseCase _getFollowingUseCase;

  @override
  void initState() {
    super.initState();
    _initializeUseCases();
    _loadUserData();
  }

  void _initializeUseCases() {
    _followUserUseCase = serviceLocator<FollowUserUseCase>();
    _unfollowUserUseCase = serviceLocator<UnfollowUserUseCase>();
    _getFollowersUseCase = serviceLocator<GetFollowersUseCase>();
    _getFollowingUseCase = serviceLocator<GetFollowingUseCase>();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedInUserId = prefs.getString('userId');

    setState(() {
      currentUserId = loggedInUserId!;
      viewingUserId = widget.userId ?? currentUserId;
      isOwnProfile = widget.userId == null || widget.userId == currentUserId;
    });

    // Load user profile
    context.read<UserProfileViewModel>().loadUserProfile(viewingUserId);

    if (!isOwnProfile) {
      // Load follow data for other users
      await _loadFollowData();
    }

    // Load posts based on follow status
    if (isOwnProfile || isFollowing) {
      context.read<FeedViewModel>().add(LoadPostsEvent(viewingUserId));
    }
  }

  Future<void> _loadFollowData() async {
    setState(() {
      isLoadingFollowData = true;
    });

    try {
      // Get followers of the user being visited
      final followersResult = await _getFollowersUseCase.call(
        GetFollowersParams(viewingUserId),
      );

      // Get following of the user being visited
      final followingResult = await _getFollowingUseCase.call(
        GetFollowingParams(viewingUserId),
      );

      followersResult.fold(
        (failure) {
          print('Error loading followers: $failure');
        },
        (followersList) {
          followers = followersList;
          // Check if current user is in the followers list of the visited user
          isFollowing = followersList.any((follow) => follow.followerId == currentUserId);
        },
      );

      followingResult.fold(
        (failure) {
          print('Error loading following: $failure');
        },
        (followingList) {
          following = followingList;
        },
      );
    } catch (e) {
      print('Error in _loadFollowData: $e');
    } finally {
      setState(() {
        isLoadingFollowData = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    if (isLoadingFollow) return;

    setState(() {
      isLoadingFollow = true;
    });

    try {
      if (isFollowing) {
        // Unfollow
        final result = await _unfollowUserUseCase.call(
          UnfollowUserParams(viewingUserId),
        );
        
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to unfollow: ${failure.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          },
          (_) {
            setState(() {
              isFollowing = false;
              // Remove current user from followers list
              followers.removeWhere((follow) => follow.followerId == currentUserId);
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unfollowed successfully'),
                backgroundColor: Color(0xFF37225C),
              ),
            );

            // Reload user profile to update follower count
            context.read<UserProfileViewModel>().loadUserProfile(viewingUserId);
          },
        );
      } else {
        // Follow
        final result = await _followUserUseCase.call(
          FollowUserParams(viewingUserId),
        );
        
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to follow: ${failure.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          },
          (followEntity) {
            setState(() {
              isFollowing = true;
              // Add the new follow relationship to followers list
              followers.add(followEntity);
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Followed successfully'),
                backgroundColor:Color(0xFF37225C),
              ),
            );

            // Reload user profile to update follower count and load posts
            context.read<UserProfileViewModel>().loadUserProfile(viewingUserId);
            context.read<FeedViewModel>().add(LoadPostsEvent(viewingUserId));
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoadingFollow = false;
      });
    }
  }

  String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    const baseUrl = ApiEndpoints.serverAddress;
    return imagePath.startsWith('http')
        ? imagePath
        : '$baseUrl/${imagePath.replaceAll("\\", "/")}';
  }

  // Delete post with confirmation dialog
  Future<void> _deletePost(BuildContext context, PostEntity post) async {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Post',
            style: TextStyle(
              color: const Color(0xFF37225C),
              fontSize: isTablet ? 22 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this post? This action cannot be undone.',
            style: TextStyle(
              color: const Color(0xFF37225C).withOpacity(0.8),
              fontSize: isTablet ? 16 : 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFB8A6E6),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16,
                  vertical: isTablet ? 12 : 8,
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16,
                  vertical: isTablet ? 12 : 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await context.read<UserProfileViewModel>().deletePost(post.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Post deleted successfully'),
              backgroundColor: const Color(0xFF37225C),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          context.read<FeedViewModel>().add(LoadPostsEvent(viewingUserId));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete post: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    }
  }

  // Update post dialog
  Future<void> _updatePost(BuildContext context, PostEntity post) async {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    final TextEditingController contentController =
        TextEditingController(text: post.content);
    String selectedPrivacy = post.privacy;
    String? selectedImagePath;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _pickImage() async {
              final picker = ImagePicker();
              final pickedFile =
                  await picker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                setState(() {
                  selectedImagePath = pickedFile.path;
                });
              }
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Update Post',
                style: TextStyle(
                  color: const Color(0xFF37225C),
                  fontSize: isTablet ? 22 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: contentController,
                      maxLines: 5,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: const Color(0xFF37225C),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Content',
                        labelStyle: TextStyle(
                          color: const Color(0xFFB8A6E6),
                          fontSize: isTablet ? 16 : 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFB8A6E6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF37225C), width: 2),
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 20 : 16),
                    DropdownButtonFormField<String>(
                      value: selectedPrivacy,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: const Color(0xFF37225C),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Privacy',
                        labelStyle: TextStyle(
                          color: const Color(0xFFB8A6E6),
                          fontSize: isTablet ? 16 : 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFB8A6E6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF37225C), width: 2),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Public', child: Text('Public')),
                        DropdownMenuItem(value: 'Private', child: Text('Private')),
                        DropdownMenuItem(value: 'Friends', child: Text('Friends Only')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedPrivacy = value!;
                        });
                      },
                    ),
                    SizedBox(height: isTablet ? 20 : 16),
                    Row(
                      children: [
                        if (selectedImagePath != null) ...[
                          Container(
                            width: isTablet ? 60 : 50,
                            height: isTablet ? 60 : 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(File(selectedImagePath!)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: isTablet ? 12 : 10),
                        ] else if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
                          Container(
                            width: isTablet ? 60 : 50,
                            height: isTablet ? 60 : 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(getFullImageUrl(post.imageUrl)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: isTablet ? 12 : 10),
                        ],
                        Expanded(
                          child: TextButton.icon(
                            onPressed: _pickImage,
                            icon: Icon(
                              Icons.image,
                              color: const Color(0xFF37225C),
                              size: isTablet ? 20 : 18,
                            ),
                            label: Text(
                              selectedImagePath != null ||
                                      (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                                  ? 'Change Image'
                                  : 'Add Image',
                              style: TextStyle(
                                color: const Color(0xFF37225C),
                                fontSize: isTablet ? 16 : 14,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFB8A6E6).withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFB8A6E6),
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 16,
                      vertical: isTablet ? 12 : 8,
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: isTablet ? 16 : 14),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop({
                      'content': contentController.text.trim(),
                      'privacy': selectedPrivacy,
                      'imagePath': selectedImagePath,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF37225C),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 16,
                      vertical: isTablet ? 12 : 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Update',
                    style: TextStyle(fontSize: isTablet ? 16 : 14),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      try {
        final updatedPost = PostEntity(
          id: post.id,
          content: result['content'] as String,
          privacy: result['privacy'] as String,
          imageUrl: result['imagePath'] as String? ?? post.imageUrl,
          user: post.user,
          createdAt: post.createdAt,
          updatedAt: DateTime.now(),
        );

        await context.read<UserProfileViewModel>().updatePost(updatedPost);
        context.read<FeedViewModel>().add(LoadPostsEvent(viewingUserId));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Post updated successfully'),
              backgroundColor: const Color(0xFF37225C),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update post: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedViewModel = context.watch<FeedViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return BlocBuilder<UserProfileViewModel, UserProfileState>(
      builder: (context, profileState) {
        final user = profileState.user;

        if (user == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF37225C)),
              ),
            ),
          );
        }

        // Show error message if there's an error
        if (profileState.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(profileState.error!),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          });
        }

        final posts = feedViewModel.state.posts
            .where((p) => p.user.userId == viewingUserId)
            .toList();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: const Color(0xFF37225C),
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              isOwnProfile ? 'My Profile' : user.username,
              style: TextStyle(
                fontSize: isTablet ? 22 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: RefreshIndicator(
            color: const Color(0xFF37225C),
            onRefresh: () async {
              await context
                  .read<UserProfileViewModel>()
                  .loadUserProfile(viewingUserId);
              
              if (!isOwnProfile) {
                await _loadFollowData();
              }
              
              if (isOwnProfile || isFollowing) {
                context.read<FeedViewModel>().add(LoadPostsEvent(viewingUserId));
              }
            },
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Use the new ProfileHeaderComponent
                ProfileHeaderComponent(
                  user: user,
                  getFullImageUrl: getFullImageUrl,
                ),

                // Info Card with responsive design
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32.0 : 16.0,
                    vertical: isTablet ? 16.0 : 12.0,
                  ),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFB8A6E6).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                      child: Column(
                        children: [
                          if (user.studentId != null) ...[
                            _infoRow("Student ID", user.studentId.toString(), isTablet),
                            SizedBox(height: isTablet ? 16 : 12),
                          ],
                          _infoRow("Role", user.role, isTablet),
                          SizedBox(height: isTablet ? 16 : 12),
                          _infoRow("Followers", '${followers.length}', isTablet),
                          SizedBox(height: isTablet ? 16 : 12),
                          _infoRow("Following", '${following.length}', isTablet),
                        ],
                      ),
                    ),
                  ),
                ),

                // Action Buttons Section
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32.0 : 16.0,
                    vertical: isTablet ? 16.0 : 12.0,
                  ),
                  child: Column(
                    children: [
                      // EDIT PROFILE BUTTONS (only on own profile)
                      if (isOwnProfile)
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showEditProfileSheet(context),
                                icon: Icon(
                                  Icons.edit,
                                  size: isTablet ? 20 : 18,
                                ),
                                label: Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF37225C),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isTablet ? 16 : 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                            ),
                            SizedBox(width: isTablet ? 16 : 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChangePassword(
                                        userId: viewingUserId,
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.lock,
                                  size: isTablet ? 20 : 18,
                                ),
                                label: Text(
                                  'Change Password',
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB8A6E6),
                                  foregroundColor: const Color(0xFF37225C),
                                  padding: EdgeInsets.symmetric(
                                    vertical: isTablet ? 16 : 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                            ),
                          ],
                        ),

                      // FOLLOW/UNFOLLOW AND MESSAGE BUTTONS (only for other users)
                      if (!isOwnProfile)
                        isLoadingFollowData
                            ? Center(
                                child: Padding(
                                  padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                                  child: CircularProgressIndicator(
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF37225C)),
                                  ),
                                ),
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: isLoadingFollow ? null : _toggleFollow,
                                      icon: isLoadingFollow
                                          ? SizedBox(
                                              width: isTablet ? 20 : 16,
                                              height: isTablet ? 20 : 16,
                                              child: const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : Icon(
                                              isFollowing ? Icons.person_remove : Icons.person_add,
                                              size: isTablet ? 20 : 18,
                                            ),
                                      label: Text(
                                        isFollowing ? 'Unfollow' : 'Follow',
                                        style: TextStyle(
                                          fontSize: isTablet ? 16 : 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isFollowing 
                                            ? const Color(0xFFB8A6E6) 
                                            : const Color(0xFF37225C),
                                        foregroundColor: isFollowing 
                                            ? const Color(0xFF37225C) 
                                            : Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          vertical: isTablet ? 16 : 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: isTablet ? 16 : 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        final messageViewModel =
                                            serviceLocator<MessageViewModel>();

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BlocProvider.value(
                                              value: messageViewModel,
                                              child: MessagePage(
                                                otherUserId: user.userId!,
                                                otherUserName: user.username,
                                                otherUserPhoto:
                                                    getFullImageUrl(user.profilePhoto),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.message,
                                        size: isTablet ? 20 : 18,
                                      ),
                                      label: Text(
                                        'Message',
                                        style: TextStyle(
                                          fontSize: isTablet ? 16 : 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF37225C),
                                        side: const BorderSide(
                                          color: Color(0xFF37225C),
                                          width: 2,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: isTablet ? 16 : 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                    ],
                  ),
                ),

                // Posts Section
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32.0 : 16.0,
                    vertical: isTablet ? 24.0 : 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Posts Header
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 20.0 : 16.0,
                          vertical: isTablet ? 16.0 : 12.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF37225C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.article,
                              color: Colors.white,
                              size: isTablet ? 24 : 20,
                            ),
                            SizedBox(width: isTablet ? 12 : 8),
                            Text(
                              'Posts',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 20 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 12 : 8,
                                vertical: isTablet ? 6 : 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${posts.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isTablet ? 20 : 16),

                      // Posts Content
                      if (!isOwnProfile && !isFollowing)
                        Container(
                          padding: EdgeInsets.all(isTablet ? 40.0 : 32.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB8A6E6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFB8A6E6).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.lock,
                                size: isTablet ? 64 : 48,
                                color: const Color(0xFFB8A6E6),
                              ),
                              SizedBox(height: isTablet ? 20 : 16),
                              Text(
                                'Follow this user to see their posts',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  color: const Color(0xFF37225C).withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else if (posts.isEmpty)
                        Container(
                          padding: EdgeInsets.all(isTablet ? 40.0 : 32.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB8A6E6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFB8A6E6).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.article_outlined,
                                size: isTablet ? 64 : 48,
                                color: const Color(0xFFB8A6E6),
                              ),
                              SizedBox(height: isTablet ? 20 : 16),
                              Text(
                                'No posts available',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  color: const Color(0xFF37225C).withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        ...posts.map((post) {
                          final isLiked =
                              feedViewModel.state.isLikedMap[post.id] ?? false;
                          final likeCount =
                              feedViewModel.state.likeCounts[post.id] ?? 0;
                          final commentCount =
                              feedViewModel.state.commentCounts[post.id] ?? 0;

                          return Container(
                            margin: EdgeInsets.only(
                              bottom: isTablet ? 16.0 : 12.0,
                            ),
                            child: PostComponent(
                              post: post,
                              currentUserId: currentUserId,
                              isLiked: isLiked,
                              likeCount: likeCount,
                              commentCount: commentCount,
                              onLikePressed: () {
                                final feedBloc = context.read<FeedViewModel>();
                                if (isLiked) {
                                  feedBloc.add(UnlikePostEvent(
                                    postId: post.id,
                                    userId: currentUserId,
                                  ));
                                } else {
                                  feedBloc.add(LikePostEvent(
                                    postId: post.id,
                                    userId: currentUserId,
                                  ));
                                }
                              },
                              onCommentPressed: () {
                                final commentVM = serviceLocator<CommentViewModel>();
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => BlocProvider.value(
                                    value: commentVM,
                                    child: CommentModal(
                                      postOwnerUserId: post.user.userId,
                                      postId: post.id,
                                      userId: currentUserId,
                                    ),
                                  ),
                                );
                              },
                              // Only show delete/update for own posts
                              onDeletePressed: isOwnProfile ? () => _deletePost(context, post) : null,
                              onUpdatePressed: isOwnProfile ? () => _updatePost(context, post) : null,
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value, bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 16 : 14,
            color: const Color(0xFF37225C),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            color: const Color(0xFF37225C).withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showEditProfileSheet(BuildContext context) {
    final userProfileVM = context.read<UserProfileViewModel>();
    final user = userProfileVM.state.user;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final TextEditingController usernameController =
        TextEditingController(text: user?.username ?? '');
    final TextEditingController emailController =
        TextEditingController(text: user?.email ?? '');
    final TextEditingController bioController =
        TextEditingController(text: user?.bio ?? '');

    String? selectedImagePath;
    bool isUpdating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final fullProfileImageUrl = getFullImageUrl(user?.profilePhoto);

            Future<void> _pickImage(ImageSource source) async {
              final picker = ImagePicker();

              Permission permission;

              if (source == ImageSource.camera) {
                permission = Permission.camera;
              } else {
                if (Theme.of(context).platform == TargetPlatform.android) {
                  permission = Permission.storage;
                } else {
                  permission = Permission.photos;
                }
              }

              final status = await permission.request();

              if (status.isGranted) {
                final pickedFile = await picker.pickImage(source: source);
                if (pickedFile != null) {
                  setState(() {
                    selectedImagePath = pickedFile.path;
                  });
                }
              } else if (status.isDenied) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Permission denied. Please allow it to continue.'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              } else if (status.isPermanentlyDenied) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                        'Permission permanently denied. Open app settings to enable it.'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    action: SnackBarAction(
                      label: 'Settings',
                      onPressed: () => openAppSettings(),
                    ),
                  ),
                );
              }
            }

            Future<void> _showImageSourcePicker() async {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => SafeArea(
                  child: Wrap(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.photo_library,
                          color: Color(0xFF37225C),
                        ),
                        title: Text(
                          'Choose from Gallery',
                          style: TextStyle(
                            color: const Color(0xFF37225C),
                            fontSize: isTablet ? 16 : 14,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.camera_alt,
                          color: Color(0xFF37225C),
                        ),
                        title: Text(
                          'Take a Photo',
                          style: TextStyle(
                            color: const Color(0xFF37225C),
                            fontSize: isTablet ? 16 : 14,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                left: isTablet ? 24 : 16,
                right: isTablet ? 24 : 16,
                top: isTablet ? 32 : 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + (isTablet ? 32 : 24),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB8A6E6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: isTablet ? 24 : 20),

                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF37225C),
                      ),
                    ),
                    SizedBox(height: isTablet ? 32 : 24),

                    // Profile Image Picker
                    GestureDetector(
                      onTap: isUpdating ? null : _showImageSourcePicker,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: isTablet ? 120 : 100,
                            height: isTablet ? 120 : 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFB8A6E6),
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: isTablet ? 57 : 47,
                              backgroundColor: const Color(0xFFB8A6E6).withOpacity(0.3),
                              backgroundImage: selectedImagePath != null
                                  ? FileImage(File(selectedImagePath!))
                                  : (fullProfileImageUrl.isNotEmpty
                                      ? NetworkImage(fullProfileImageUrl)
                                      : null),
                              child: (selectedImagePath == null &&
                                      fullProfileImageUrl.isEmpty)
                                  ? Icon(
                                      Icons.camera_alt,
                                      size: isTablet ? 32 : 28,
                                      color: const Color(0xFF37225C),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(isTablet ? 8 : 6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF37225C),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: isTablet ? 20 : 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isTablet ? 32 : 24),

                    // Form Fields
                    TextField(
                      controller: usernameController,
                      enabled: !isUpdating,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: const Color(0xFF37225C),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(
                          color: const Color(0xFFB8A6E6),
                          fontSize: isTablet ? 16 : 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFB8A6E6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF37225C), width: 2),
                        ),
                        prefixIcon: Icon(
                          Icons.person,
                          color: const Color(0xFFB8A6E6),
                          size: isTablet ? 24 : 20,
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 20 : 16),

                    TextField(
                      controller: emailController,
                      enabled: !isUpdating,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: const Color(0xFF37225C),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: const Color(0xFFB8A6E6),
                          fontSize: isTablet ? 16 : 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFB8A6E6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF37225C), width: 2),
                        ),
                        prefixIcon: Icon(
                          Icons.email,
                          color: const Color(0xFFB8A6E6),
                          size: isTablet ? 24 : 20,
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 20 : 16),

                    TextField(
                      controller: bioController,
                      enabled: !isUpdating,
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: const Color(0xFF37225C),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Bio',
                        labelStyle: TextStyle(
                          color: const Color(0xFFB8A6E6),
                          fontSize: isTablet ? 16 : 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFB8A6E6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF37225C), width: 2),
                        ),
                        prefixIcon: Icon(
                          Icons.info,
                          color: const Color(0xFFB8A6E6),
                          size: isTablet ? 24 : 20,
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 32 : 24),

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isUpdating ? null : () async {
                          final newUsername = usernameController.text.trim();
                          final newEmail = emailController.text.trim();
                          final newBio = bioController.text.trim();

                          if (newUsername.isEmpty || newEmail.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Username and Email cannot be empty'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isUpdating = true;
                          });

                          try {
                            await userProfileVM.updateUserProfile(
                              userId: viewingUserId,
                              username: newUsername,
                              email: newEmail,
                              bio: newBio,
                              profilePhotoPath: selectedImagePath,
                            );

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Profile updated successfully'),
                                backgroundColor: const Color(0xFF37225C),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to update profile: ${e.toString()}'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          } finally {
                            setState(() {
                              isUpdating = false;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isUpdating 
                              ? const Color(0xFFB8A6E6).withOpacity(0.5)
                              : const Color(0xFF37225C),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 16 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: isUpdating 
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: isTablet ? 20 : 16,
                                    height: isTablet ? 20 : 16,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: isTablet ? 12 : 8),
                                  Text(
                                    'Updating...',
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Update Profile',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}