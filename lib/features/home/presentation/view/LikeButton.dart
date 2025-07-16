import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  final String postId;
  final String userId;
  final bool isLiked;
  final int likeCount;
  final bool isLoading;
  final VoidCallback onPressed;

  const LikeButton({
    Key? key,
    required this.postId,
    required this.userId,
    required this.isLiked,
    required this.likeCount,
    required this.isLoading,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: Icon(
        isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
        color: isLiked ? Colors.blue : Colors.grey,
      ),
      label: isLoading
          ? const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              likeCount.toString(),
              style: TextStyle(color: Colors.grey[800]),
            ),
    );
  }
}
