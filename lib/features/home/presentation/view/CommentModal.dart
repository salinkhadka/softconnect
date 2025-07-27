import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:softconnect/app/constants/api_endpoints.dart';
import 'package:softconnect/app/theme/colors/themecolor.dart';
import 'package:softconnect/core/utils/network_image_util.dart';
import 'package:softconnect/features/home/presentation/view_model/Comment_view_model/comment_event.dart';
import 'package:softconnect/features/home/presentation/view_model/Comment_view_model/comment_state.dart';
import 'package:softconnect/features/home/presentation/view_model/Comment_view_model/comment_view_model.dart';
import 'package:softconnect/features/profile/presentation/view/user_profile.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_viewmodel.dart';
import 'package:softconnect/features/profile/presentation/view_model/user_profile_viewmodel.dart';

class CommentModal extends StatefulWidget {
  final String postId;
  final String userId;
  final String postOwnerUserId;

  const CommentModal({
    Key? key,
    required this.postId,
    required this.userId,
    required this.postOwnerUserId,
  }) : super(key: key);

  @override
  State<CommentModal> createState() => _CommentModalState();
}

class _CommentModalState extends State<CommentModal> {
  String? replyingToCommentId;
  Set<String> expandedReplies = {};
  final TextEditingController _commentController = TextEditingController();

  String getBackendBaseUrl() {
    if (Platform.isAndroid) {
      return ApiEndpoints.serverAddress;
    } else {
      return 'http://localhost:2000';
    }
  }

  void navigateToUserProfile(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider<UserProfileViewModel>(
              create: (_) => serviceLocator<UserProfileViewModel>(),
            ),
            BlocProvider<FeedViewModel>(
              create: (_) => serviceLocator<FeedViewModel>(),
            ),
            BlocProvider<CommentViewModel>(
              create: (_) => serviceLocator<CommentViewModel>(),
            ),
          ],
          child: UserProfilePage(userId: userId),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<CommentViewModel>().add(LoadComments(widget.postId));
  }

  @override
  Widget build(BuildContext context) {
    final backendBaseUrl = getBackendBaseUrl();

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Themecolor.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(
              color: Themecolor.lavender.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: BlocBuilder<CommentViewModel, CommentState>(
            builder: (context, state) {
              return Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Themecolor.purple,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Themecolor.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Comments",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Themecolor.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Comments List
                  Expanded(
                    child: state.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: Themecolor.purple),
                          )
                        : state.comments.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.comment_outlined,
                                      size: 48,
                                      color: Themecolor.lavender,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'No comments yet',
                                      style: TextStyle(
                                        color: Themecolor.purple,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: state.comments
                                    .where((c) => c.parentCommentId == null)
                                    .length,
                                itemBuilder: (context, index) {
                                  final topLevelComments = state.comments
                                      .where((c) => c.parentCommentId == null)
                                      .toList();
                                  final comment = topLevelComments[index];

                                  return buildComment(comment, state, backendBaseUrl);
                                },
                              ),
                  ),

                  // Input Section
                  SafeArea(
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 12,
                        right: 12,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                        top: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Themecolor.white,
                        border: Border(
                          top: BorderSide(
                            color: Themecolor.lavender.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Themecolor.purple,
                              ),
                              decoration: InputDecoration(
                                hintText: "Add a comment...",
                                hintStyle: const TextStyle(
                                  color: Themecolor.lavender,
                                  fontSize: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(color: Themecolor.lavender),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Themecolor.purple, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Themecolor.purple,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Themecolor.purple,
                                foregroundColor: Themecolor.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () {
                                final content = _commentController.text.trim();
                                if (content.isNotEmpty) {
                                  context.read<CommentViewModel>().add(AddComment(
                                        userId: widget.userId,
                                        postId: widget.postId,
                                        content: content,
                                      ));
                                  _commentController.clear();
                                  FocusScope.of(context).unfocus();
                                }
                              },
                              child: const Text(
                                "Post",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget buildComment(dynamic comment, CommentState state, String backendBaseUrl,
      {bool isReply = false}) {
    final replies =
        state.comments.where((c) => c.parentCommentId == comment.id).toList();
    final isExpanded = expandedReplies.contains(comment.id);

    return Container(
      margin: EdgeInsets.only(bottom: 8, left: isReply ? 32 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isReply
                  ? Themecolor.lavender.withOpacity(0.05)
                  : Themecolor.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Themecolor.lavender.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Comment Header with clickable avatar and username
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => navigateToUserProfile(context, comment.userId),
                      child: comment.profilePhoto != null &&
                              comment.profilePhoto!.isNotEmpty
                          ? CircleAvatar(
                              radius: 20,
                              backgroundColor: Themecolor.lavender,
                              child: ClipOval(
                                child: NetworkImageWidget(
                                  imageUrl:
                                      '$backendBaseUrl/${comment.profilePhoto!.replaceAll('\\', '/')}',
                                  height: 40,
                                  width: 40,
                                  fit: BoxFit.cover,
                                  placeholder: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Themecolor.purple,
                                    ),
                                  ),
                                  errorWidget: Icon(
                                    Icons.account_circle,
                                    size: 40,
                                    color: Themecolor.purple,
                                  ),
                                ),
                              ),
                            )
                          : CircleAvatar(
                              radius: 20,
                              backgroundColor: Themecolor.lavender,
                              child: Text(
                                comment.username != null && comment.username!.isNotEmpty
                                    ? comment.username![0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Themecolor.purple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => navigateToUserProfile(context, comment.userId),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '@${comment.username ?? 'anonymous'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Themecolor.purple,
                              ),
                            ),
                            Text(
                              DateFormat('yyyy-MM-dd hh:mm a').format(comment.createdAt),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Action Buttons (Reply, Delete)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          child: const Text(
                            'Reply',
                            style: TextStyle(
                              color: Themecolor.purple,
                              fontSize: 12,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              replyingToCommentId =
                                  replyingToCommentId == comment.id ? null : comment.id;
                            });
                          },
                        ),
                        if (comment.userId == widget.userId ||
                            widget.postOwnerUserId == widget.userId)
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 18,
                            ),
                            onPressed: () async {
                              final shouldDelete = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Delete Comment"),
                                  content: const Text(
                                      "Are you sure you want to delete this comment?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (shouldDelete == true) {
                                context.read<CommentViewModel>().add(
                                      DeleteComment(
                                        commentId: comment.id,
                                        postId: widget.postId,
                                      ),
                                    );
                              }
                            },
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Comment Content
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Themecolor.purple,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Reply Input
          if (replyingToCommentId == comment.id)
            Container(
              margin: const EdgeInsets.only(top: 8, left: 40),
              child: ReplyTextField(
                onReply: (replyContent) {
                  context.read<CommentViewModel>().add(
                        AddComment(
                          userId: widget.userId,
                          postId: widget.postId,
                          content: replyContent,
                          parentCommentId: comment.id,
                        ),
                      );
                  setState(() {
                    replyingToCommentId = null;
                  });
                },
              ),
            ),

          // Show/Hide Replies Button
          if (replies.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4, left: 40),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    if (isExpanded) {
                      expandedReplies.remove(comment.id);
                    } else {
                      expandedReplies.add(comment.id);
                    }
                  });
                },
                child: Text(
                  isExpanded
                      ? "Hide replies"
                      : "View ${replies.length} repl${replies.length > 1 ? 'ies' : 'y'}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Themecolor.purple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // Replies
          if (isExpanded)
            ...replies.map(
              (reply) => buildComment(reply, state, backendBaseUrl, isReply: true),
            ),
        ],
      ),
    );
  }
}

class ReplyTextField extends StatefulWidget {
  final Function(String) onReply;

  const ReplyTextField({
    Key? key,
    required this.onReply,
  }) : super(key: key);

  @override
  State<ReplyTextField> createState() => _ReplyTextFieldState();
}

class _ReplyTextFieldState extends State<ReplyTextField> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Themecolor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Themecolor.lavender.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(
                fontSize: 14,
                color: Themecolor.purple,
              ),
              decoration: const InputDecoration(
                hintText: 'Write a reply...',
                hintStyle: TextStyle(
                  color: Themecolor.lavender,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide(color: Themecolor.lavender),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide(color: Themecolor.purple, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Themecolor.purple,
              foregroundColor: Themecolor.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () {
              final text = _controller.text.trim();
              if (text.isNotEmpty) {
                widget.onReply(text);
                _controller.clear();
                FocusScope.of(context).unfocus();
              }
            },
            child: const Text(
              'Reply',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}