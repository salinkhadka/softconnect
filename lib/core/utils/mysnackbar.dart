import 'package:flutter/material.dart';

void showMySnackBar({
  required BuildContext context,
  required String message,
  Color color = Colors.black87,
  Duration duration = const Duration(seconds: 2),
}) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: color,
    duration: duration,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
