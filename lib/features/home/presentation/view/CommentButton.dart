import 'package:flutter/material.dart';
import 'package:softconnect/app/theme/colors/themecolor.dart';

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
      icon: Icon(Icons.comment_outlined, color: Themecolor.lavender),
      label: isLoading
          ? SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Themecolor.purple,
              ),
            )
          : Text(
              '$commentCount',
              style: TextStyle(color: Themecolor.purple),
            ),
    );
  }
}
