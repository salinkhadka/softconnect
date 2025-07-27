import 'package:softconnect/app/constants/api_endpoints.dart';

String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    return imagePath.contains('http')
        ? imagePath
        : ApiEndpoints.serverAddress+'/${imagePath.replaceAll("\\", "/")}';
  }git s