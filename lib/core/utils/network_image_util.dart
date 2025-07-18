// lib/core/utils/network_image_util.dart

import 'package:flutter/material.dart';

class NetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const NetworkImageWidget({
    Key? key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return placeholder ??
              Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          (progress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              const Center(
                child: Icon(Icons.broken_image, color: Colors.grey),
              );
        },
      ),
    );
  }
}
