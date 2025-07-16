import 'package:flutter/material.dart';

class CommentButton extends StatelessWidget {
  final int commentCount;
  final bool isLoading;
  final VoidCallback onPressed;

  const CommentButton({
    Key? key,
    required this.commentCount,
    required this.isLoading,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: const Icon(Icons.comment_outlined, color: Colors.grey),
      label: isLoading
          ? const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              '$commentCount',
              style: const TextStyle(color: Colors.grey),
            ),
    );
  }
}
