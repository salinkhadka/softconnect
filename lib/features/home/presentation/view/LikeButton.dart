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
        color: isLiked 
            ? Theme.of(context).primaryColor 
            : Theme.of(context).primaryColor.withOpacity(0.7),
      ),
      label: isLoading
          ? SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).primaryColor,
              ),
            )
          : Text(
              likeCount.toString(),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        backgroundColor: isLiked 
            ? Theme.of(context).primaryColor.withOpacity(0.1) 
            : Colors.transparent,
      ),
    );
  }
}