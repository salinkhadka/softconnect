import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  String getBackendBaseUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:2000';
    } else {
      return 'http://localhost:2000';
    }
  }

  @override
  void initState() {
    super.initState();
    // Load comments when modal opens
    context.read<CommentViewModel>().add(LoadComments(widget.postId));
  }

  @override
  Widget build(BuildContext context) {
    final backendBaseUrl = getBackendBaseUrl();

    // TextEditingController for new top-level comment
    final TextEditingController _commentController = TextEditingController();

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: BlocBuilder<CommentViewModel, CommentState>(
            builder: (context, state) {
              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      "Comments",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: state.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : state.comments.isEmpty
                            ? const Center(child: Text('No comments yet'))
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: state.comments.length,
                                itemBuilder: (context, index) {
                                  final comment = state.comments[index];
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        leading: comment.profilePhoto != null &&
                                                comment.profilePhoto!
                                                    .isNotEmpty
                                            ? CircleAvatar(
                                                radius: 20,
                                                child: ClipOval(
                                                  child: NetworkImageWidget(
                                                    imageUrl:
                                                        '$backendBaseUrl/${comment.profilePhoto!.replaceAll('\\', '/')}',
                                                    height: 40,
                                                    width: 40,
                                                    fit: BoxFit.cover,
                                                    placeholder: const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 2),
                                                    ),
                                                    errorWidget: const Icon(
                                                      Icons.account_circle,
                                                      size: 40,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : CircleAvatar(
                                                radius: 20,
                                                child: Text(
                                                  comment.username != null &&
                                                          comment.username!
                                                              .isNotEmpty
                                                      ? comment.username![0]
                                                          .toUpperCase()
                                                      : '?',
                                                  style:
                                                      const TextStyle(fontSize: 18),
                                                ),
                                              ),
                                        title: Text(comment.content),
                                        subtitle:
                                            Text('@${comment.username ?? 'anonymous'}'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextButton(
                                              child: const Text('Reply'),
                                              onPressed: () {
                                                setState(() {
                                                  if (replyingToCommentId ==
                                                      comment.id) {
                                                    replyingToCommentId = null;
                                                  } else {
                                                    replyingToCommentId = comment.id;
                                                  }
                                                });
                                              },
                                            ),
                                            if (comment.userId == widget.userId ||
                                                widget.postOwnerUserId ==
                                                    widget.userId)
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () {
                                                  context.read<CommentViewModel>().add(
                                                        DeleteComment(
                                                            commentId: comment.id,
                                                            postId: widget.postId),
                                                      );
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (replyingToCommentId == comment.id)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 72, right: 16, bottom: 8),
                                          child: ReplyTextField(
                                            onReply: (replyContent) {
                                              context.read<CommentViewModel>().add(
                                                    AddComment(
                                                      userId: widget.userId,
                                                      postId: widget.postId,
                                                      content: replyContent,
                                                      parentCommentId: comment.id, // key part
                                                    ),
                                                  );
                                              setState(() {
                                                replyingToCommentId = null;
                                              });
                                            },
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 12,
                        right: 12,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                        top: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                hintText: "Add a comment...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
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
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
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
                                      // No parentId means top-level comment
                                    ));
                                _commentController.clear();
                                FocusScope.of(context).unfocus();
                              }
                            },
                            child: const Text("Post"),
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
}

class ReplyTextField extends StatefulWidget {
  final Function(String) onReply;

  const ReplyTextField({Key? key, required this.onReply}) : super(key: key);

  @override
  State<ReplyTextField> createState() => _ReplyTextFieldState();
}

class _ReplyTextFieldState extends State<ReplyTextField> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Write a reply...',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isNotEmpty) {
              widget.onReply(text);
              _controller.clear();
              FocusScope.of(context).unfocus();
            }
          },
          child: const Text('Reply'),
        ),
      ],
    );
  }
}
