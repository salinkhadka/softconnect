import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
// Add these imports for your use cases
import 'package:softconnect/features/friends/domain/entity/follow_entity.dart';

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
                backgroundColor: Colors.green,
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
                backgroundColor: Colors.green,
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
    const baseUrl = 'http://10.0.2.2:2000';
    return imagePath.startsWith('http')
        ? imagePath
        : '$baseUrl/${imagePath.replaceAll("\\", "/")}';
  }

  // Delete post with confirmation dialog
  Future<void> _deletePost(BuildContext context, PostEntity post) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text(
              'Are you sure you want to delete this post? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await context.read<UserProfileViewModel>().deletePost(post.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );
        context.read<FeedViewModel>().add(LoadPostsEvent(viewingUserId));
      }
    }
  }

  // Update post dialog
  Future<void> _updatePost(BuildContext context, PostEntity post) async {
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
              title: const Text('Update Post'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: contentController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedPrivacy,
                      decoration: const InputDecoration(
                        labelText: 'Privacy',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'Public', child: Text('Public')),
                        DropdownMenuItem(
                            value: 'Private', child: Text('Private')),
                        DropdownMenuItem(
                            value: 'Friends', child: Text('Friends Only')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedPrivacy = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (selectedImagePath != null) ...[
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(File(selectedImagePath!)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ] else if (post.imageUrl != null &&
                            post.imageUrl!.isNotEmpty) ...[
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(
                                    getFullImageUrl(post.imageUrl)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: Text(selectedImagePath != null ||
                                  (post.imageUrl != null &&
                                      post.imageUrl!.isNotEmpty)
                              ? 'Change Image'
                              : 'Add Image'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop({
                      'content': contentController.text.trim(),
                      'privacy': selectedPrivacy,
                      'imagePath': selectedImagePath,
                    });
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
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
          const SnackBar(content: Text('Post updated successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedViewModel = context.watch<FeedViewModel>();

    return BlocBuilder<UserProfileViewModel, UserProfileState>(
      builder: (context, profileState) {
        final user = profileState.user;

        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Show error message if there's an error
        if (profileState.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(profileState.error!),
                backgroundColor: Colors.red,
              ),
            );
          });
        }

        final posts = feedViewModel.state.posts
            .where((p) => p.user.userId == viewingUserId)
            .toList();

        final profileImageUrl = getFullImageUrl(user.profilePhoto);

        return Scaffold(
          appBar: AppBar(
            title: Text(isOwnProfile ? 'My Profile' : user.username),
          ),
          body: RefreshIndicator(
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
              padding: const EdgeInsets.all(16),
              children: [
                /// Profile Header
                Center(
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
                ),

                const SizedBox(height: 20),

                /// Info Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        if (user.studentId != null) ...[
                          _infoRow("Student ID", user.studentId.toString()),
                          const SizedBox(height: 8),
                        ],
                        _infoRow("Role", user.role),
                        const SizedBox(height: 8),
                        _infoRow("Followers", '${followers.length}'),
                        const SizedBox(height: 8),
                        _infoRow("Following", '${following.length}'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // EDIT PROFILE BUTTON (only on own profile)
                if (isOwnProfile)
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Center(
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wrap content width
        children: [
          ElevatedButton(
            onPressed: () => _showEditProfileSheet(context),
            child: const Text('Edit Profile'),
          ),
          const SizedBox(width: 16), // spacing between buttons
          ElevatedButton(
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange, // or any color you prefer
            ),
            child: const Text('Change Password'),
          ),
        ],
      ),
    ),
  ),

                  

                // FOLLOW/UNFOLLOW AND MESSAGE BUTTONS (only for other users)
                if (!isOwnProfile)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: isLoadingFollowData
                        ? const Center(child: CircularProgressIndicator())
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: isLoadingFollow ? null : _toggleFollow,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFollowing ? Colors.grey : Colors.blue,
                                ),
                                child: isLoadingFollow
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(isFollowing ? 'Unfollow' : 'Follow'),
                              ),
                              OutlinedButton(
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
                                child: const Text('Message'),
                              ),
                            ],
                          ),
                  ),

                const Divider(height: 32),

                Text('Posts', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),

                // Posts section with conditional visibility
                if (!isOwnProfile && !isFollowing)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(Icons.lock, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Follow this user to see their posts',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else if (posts.isEmpty)
                  const Center(child: Text('No posts available'))
                else
                  ...posts.map((post) {
                    final isLiked =
                        feedViewModel.state.isLikedMap[post.id] ?? false;
                    final likeCount =
                        feedViewModel.state.likeCounts[post.id] ?? 0;
                    final commentCount =
                        feedViewModel.state.commentCounts[post.id] ?? 0;

                    return PostComponent(
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
                    );
                  }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  void _showEditProfileSheet(BuildContext context) {
    final userProfileVM = context.read<UserProfileViewModel>();
    final user = userProfileVM.state.user;

    final TextEditingController usernameController =
        TextEditingController(text: user?.username ?? '');
    final TextEditingController emailController =
        TextEditingController(text: user?.email ?? '');
    final TextEditingController bioController =
        TextEditingController(text: user?.bio ?? '');

    String? selectedImagePath; // local variable to hold picked image path

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Get full image URL using existing method
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
                  permission = Permission.photos; // iOS
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
                  const SnackBar(
                      content: Text(
                          'Permission denied. Please allow it to continue.')),
                );
              } else if (status.isPermanentlyDenied) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                        'Permission permanently denied. Open app settings to enable it.'),
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
                builder: (_) => SafeArea(
                  child: Wrap(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: const Text('Choose from Gallery'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('Take a Photo'),
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

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Edit Profile',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _showImageSourcePicker,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: selectedImagePath != null
                            ? FileImage(File(selectedImagePath!))
                            : (fullProfileImageUrl.isNotEmpty
                                ? NetworkImage(fullProfileImageUrl)
                                : null),
                        child: (selectedImagePath == null &&
                                fullProfileImageUrl.isEmpty)
                            ? const Icon(Icons.camera_alt)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: bioController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final newUsername = usernameController.text.trim();
                          final newEmail = emailController.text.trim();
                          final newBio = bioController.text.trim();

                          if (newUsername.isEmpty || newEmail.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Username and Email cannot be empty'),
                              ),
                            );
                            return;
                          }

                          // ✅ Pass selected image to ViewModel
                          await userProfileVM.updateUserProfile(
                            userId: viewingUserId,
                            username: newUsername,
                            email: newEmail,
                            bio: newBio,
                            profilePhotoPath:
                                selectedImagePath, // ✅ This line is now active
                          );

                          Navigator.pop(context);
                        },
                        child: const Text('Update'),
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