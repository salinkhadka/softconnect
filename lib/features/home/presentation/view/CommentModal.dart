import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softconnect/features/home/domain/entity/comment_entity.dart';
import 'package:softconnect/features/home/presentation/view_model/comment_view_model/comment_event.dart';
import 'package:softconnect/features/home/presentation/view_model/comment_view_model/comment_view_model.dart';
import 'package:softconnect/features/home/presentation/view_model/comment_view_model/comment_state.dart';

class CommentModal extends StatefulWidget {
  final String postId;
  final String userId;

  const CommentModal({super.key, required this.postId, required this.userId});

  @override
  State<CommentModal> createState() => _CommentModalState();
}

class _CommentModalState extends State<CommentModal> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CommentViewModel>().add(LoadComments(widget.postId));
  }

  void _sendComment() {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    context.read<CommentViewModel>().add(AddComment(
          userId: widget.userId,
          postId: widget.postId,
          content: content,
        ));

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommentViewModel, CommentState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Comments')),
          body: Column(
            children: [
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: state.comments.length,
                        itemBuilder: (context, index) {
                          final comment = state.comments[index];
                          return ListTile(
                            leading: comment.profilePhoto != null &&
                                    comment.profilePhoto!.isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(comment.profilePhoto!),
                                  )
                                : CircleAvatar(
                                    child: Text(
                                      comment.username != null &&
                                              comment.username!.isNotEmpty
                                          ? comment.username![0].toUpperCase()
                                          : '?',
                                    ),
                                  ),
                            title: Text(comment.content),
                            subtitle: Text('@${comment.username ?? 'anonymous'}'),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Write a comment...',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendComment,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
