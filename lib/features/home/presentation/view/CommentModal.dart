import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/core/utils/network_image_util.dart'; // Import reusable widget
import 'package:softconnect/features/home/presentation/view_model/Comment_view_model/comment_event.dart';
import 'package:softconnect/features/home/presentation/view_model/Comment_view_model/comment_state.dart';
import 'package:softconnect/features/home/presentation/view_model/Comment_view_model/comment_view_model.dart';

class CommentModal extends StatefulWidget {
  final String postId;
  final String userId;

  const CommentModal({
    super.key,
    required this.postId,
    required this.userId,
  });

  @override
  State<CommentModal> createState() => _CommentModalState();
}

class _CommentModalState extends State<CommentModal> {
  final TextEditingController _commentController = TextEditingController();

  // Helper method to get backend URL based on platform
  String getBackendBaseUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:2000';
    } else if (Platform.isIOS) {
      return 'http://localhost:2000';
    } else {
      return 'http://localhost:2000';
    }
  }

  @override
  void initState() {
    super.initState();
    // Dispatch load comments event when modal opens
    context.read<CommentViewModel>().add(LoadComments(widget.postId));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _postComment() {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    context.read<CommentViewModel>().add(AddComment(
      userId: widget.userId,
      postId: widget.postId,
      content: content,
    ));

    _commentController.clear();
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                                  return ListTile(
                                    leading: comment.profilePhoto != null &&
                                            comment.profilePhoto!.isNotEmpty
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
                                                      CircularProgressIndicator(strokeWidth: 2),
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
                                                      comment.username!.isNotEmpty
                                                  ? comment.username![0].toUpperCase()
                                                  : '?',
                                              style: const TextStyle(fontSize: 18),
                                            ),
                                          ),
                                    title: Text(comment.content),
                                    subtitle: Text('@${comment.username ?? 'anonymous'}'),
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
                            onPressed: _postComment,
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
