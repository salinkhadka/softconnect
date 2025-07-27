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

  @override
  void initState() {
    super.initState();
    context.read<CommentViewModel>().add(LoadComments(widget.postId));
  }

  @override
  Widget build(BuildContext context) {
    final backendBaseUrl = getBackendBaseUrl();
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

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
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 16 : 12,
                      horizontal: isTablet ? 20 : 16,
                    ),
                    decoration: BoxDecoration(
                      color: Themecolor.purple,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: isTablet ? 24 : 20,
                          decoration: BoxDecoration(
                            color: Themecolor.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: isTablet ? 16 : 12),
                        Text(
                          "Comments",
                          style: TextStyle(
                            fontSize: isTablet ? 20 : 18,
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
                        ? Center(
                            child: CircularProgressIndicator(
                                color: Themecolor.purple),
                          )
                        : state.comments.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.comment_outlined,
                                      size: isTablet ? 64 : 48,
                                      color: Themecolor.lavender,
                                    ),
                                    SizedBox(height: isTablet ? 16 : 12),
                                    Text(
                                      'No comments yet',
                                      style: TextStyle(
                                        color: Themecolor.purple,
                                        fontSize: isTablet ? 18 : 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 20 : 16,
                                  vertical: isTablet ? 12 : 8,
                                ),
                                itemCount: state.comments
                                    .where((c) => c.parentCommentId == null)
                                    .length,
                                itemBuilder: (context, index) {
                                  final topLevelComments = state.comments
                                      .where((c) => c.parentCommentId == null)
                                      .toList();
                                  final comment = topLevelComments[index];

                                  return buildComment(
                                      comment, state, backendBaseUrl, isTablet);
                                },
                              ),
                  ),

                  // Input Section
                  SafeArea(
                    child: Container(
                      padding: EdgeInsets.only(
                        left: isTablet ? 20 : 12,
                        right: isTablet ? 20 : 12,
                        bottom: MediaQuery.of(context).viewInsets.bottom +
                            (isTablet ? 12 : 8),
                        top: isTablet ? 12 : 8,
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
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                color: Themecolor.purple,
                              ),
                              decoration: InputDecoration(
                                hintText: "Add a comment...",
                                hintStyle: TextStyle(
                                  color: Themecolor.lavender,
                                  fontSize: isTablet ? 16 : 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(isTablet ? 25 : 20),
                                  borderSide:
                                      BorderSide(color: Themecolor.lavender),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(isTablet ? 25 : 20),
                                  borderSide: BorderSide(
                                      color: Themecolor.purple, width: 2),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 20 : 16,
                                  vertical: isTablet ? 12 : 8,
                                ),
                              ),
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: isTablet ? 12 : 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Themecolor.purple,
                              borderRadius:
                                  BorderRadius.circular(isTablet ? 25 : 20),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Themecolor.purple,
                                foregroundColor: Themecolor.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(isTablet ? 25 : 20),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 20 : 16,
                                  vertical: isTablet ? 14 : 12,
                                ),
                              ),
                              onPressed: () {
                                final content = _commentController.text.trim();
                                if (content.isNotEmpty) {
                                  context
                                      .read<CommentViewModel>()
                                      .add(AddComment(
                                        userId: widget.userId,
                                        postId: widget.postId,
                                        content: content,
                                      ));
                                  _commentController.clear();
                                  FocusScope.of(context).unfocus();
                                }
                              },
                              child: Text(
                                "Post",
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
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

  Widget buildComment(
      dynamic comment, CommentState state, String backendBaseUrl, bool isTablet,
      {bool isReply = false}) {
    final replies =
        state.comments.where((c) => c.parentCommentId == comment.id).toList();
    final isExpanded = expandedReplies.contains(comment.id);

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 16 : 12),
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
            margin: EdgeInsets.only(left: isReply ? (isTablet ? 40 : 32) : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Comment Header
                Row(
                  children: [
                    comment.profilePhoto != null &&
                            comment.profilePhoto!.isNotEmpty
                        ? CircleAvatar(
                            radius: isTablet
                                ? (isReply ? 18 : 22)
                                : (isReply ? 16 : 20),
                            backgroundColor: Themecolor.lavender,
                            child: ClipOval(
                              child: NetworkImageWidget(
                                imageUrl:
                                    '$backendBaseUrl/${comment.profilePhoto!.replaceAll('\\', '/')}',
                                height: isTablet
                                    ? (isReply ? 36 : 44)
                                    : (isReply ? 32 : 40),
                                width: isTablet
                                    ? (isReply ? 36 : 44)
                                    : (isReply ? 32 : 40),
                                fit: BoxFit.cover,
                                placeholder: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Themecolor.purple,
                                  ),
                                ),
                                errorWidget: Icon(
                                  Icons.account_circle,
                                  size: isTablet
                                      ? (isReply ? 36 : 44)
                                      : (isReply ? 32 : 40),
                                  color: Themecolor.purple,
                                ),
                              ),
                            ),
                          )
                        : CircleAvatar(
                            radius: isTablet
                                ? (isReply ? 18 : 22)
                                : (isReply ? 16 : 20),
                            backgroundColor: Themecolor.lavender,
                            child: Text(
                              comment.username != null &&
                                      comment.username!.isNotEmpty
                                  ? comment.username![0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: isTablet
                                    ? (isReply ? 16 : 20)
                                    : (isReply ? 14 : 18),
                                color: Themecolor.purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                    SizedBox(width: isTablet ? 12 : 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '@${comment.username ?? 'anonymous'}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 16 : 14,
                              color: Themecolor.purple,
                            ),
                          ),
                          Text(
                            DateFormat('yyyy-MM-dd hh:mm a')
                                .format(comment.createdAt),
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action Buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          child: Text(
                            'Reply',
                            style: TextStyle(
                              color: Themecolor.purple,
                              fontSize: isTablet ? 14 : 12,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              replyingToCommentId =
                                  replyingToCommentId == comment.id
                                      ? null
                                      : comment.id;
                            });
                          },
                        ),
                        if (comment.userId == widget.userId ||
                            widget.postOwnerUserId == widget.userId)
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: isTablet ? 20 : 18,
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

                SizedBox(height: isTablet ? 12 : 8),

                // Comment Content
                Text(
                  comment.content,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
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
              margin: EdgeInsets.only(
                left: isTablet ? (isReply ? 56 : 40) : (isReply ? 48 : 32),
                top: isTablet ? 12 : 8,
              ),
              child: ReplyTextField(
                isTablet: isTablet,
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
              margin: EdgeInsets.only(
                left: isTablet ? (isReply ? 56 : 40) : (isReply ? 48 : 32),
                top: isTablet ? 8 : 4,
              ),
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
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: Themecolor.purple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // Replies
          if (isExpanded)
            ...replies.map(
              (reply) => buildComment(reply, state, backendBaseUrl, isTablet,
                  isReply: true),
            ),
        ],
      ),
    );
  }
}

class ReplyTextField extends StatefulWidget {
  final Function(String) onReply;
  final bool isTablet;

  const ReplyTextField({
    Key? key,
    required this.onReply,
    required this.isTablet,
  }) : super(key: key);

  @override
  State<ReplyTextField> createState() => _ReplyTextFieldState();
}

class _ReplyTextFieldState extends State<ReplyTextField> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 16 : 12),
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
              style: TextStyle(
                fontSize: widget.isTablet ? 16 : 14,
                color: Themecolor.purple,
              ),
              decoration: InputDecoration(
                hintText: 'Write a reply...',
                hintStyle: TextStyle(
                  color: Themecolor.lavender,
                  fontSize: widget.isTablet ? 16 : 14,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(widget.isTablet ? 25 : 20),
                  borderSide: BorderSide(color: Themecolor.lavender),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(widget.isTablet ? 25 : 20),
                  borderSide: BorderSide(color: Themecolor.purple, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: widget.isTablet ? 20 : 16,
                  vertical: widget.isTablet ? 12 : 8,
                ),
              ),
              maxLines: 1,
            ),
          ),
          SizedBox(width: widget.isTablet ? 12 : 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Themecolor.purple,
              foregroundColor: Themecolor.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.isTablet ? 25 : 20),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: widget.isTablet ? 20 : 16,
                vertical: widget.isTablet ? 14 : 12,
              ),
            ),
            onPressed: () {
              final text = _controller.text.trim();
              if (text.isNotEmpty) {
                widget.onReply(text);
                _controller.clear();
                FocusScope.of(context).unfocus();
              }
            },
            child: Text(
              'Reply',
              style: TextStyle(
                fontSize: widget.isTablet ? 14 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
