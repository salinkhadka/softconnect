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
      icon: Icon(
        Icons.comment_outlined, 
        color: Theme.of(context).primaryColor.withOpacity(0.7),
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
              '$commentCount',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }
}