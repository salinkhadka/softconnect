class ApiEndpoints {
  ApiEndpoints._();

  // Timeouts
  static const connectionTimeout = Duration(seconds: 1000);
  static const receiveTimeout = Duration(seconds: 1000);

  // Base URLs
  static const String serverAddress = "http://10.0.2.2:2000"; // Android emulator
  static const String baseUrl = "$serverAddress/";
  static const String imageUrl = "${serverAddress}/uploads/";


  // User endpoints
  static const String registerUser = "user/register";
  static const String loginUser = "user/login";
  static const String getAllUsers = "user/";
  static const String uploadImg = "user/uploadImg";
  static String getUserById(String id) => "user/$id";
  static String updateUserById(String id) => "user/$id";
  static String deleteUserById(String id) => "user/$id";
}

