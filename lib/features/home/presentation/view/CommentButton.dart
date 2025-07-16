import 'package:flutter/material.dart';

class CommentButton extends StatelessWidget {
  final int commentCount;
  final VoidCallback onPressed;

  const CommentButton({
    Key? key,
    required this.commentCount,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.comment_outlined, color: Colors.grey),
      label: Text('$commentCount', style: const TextStyle(color: Colors.grey)),
    );
  }
}
