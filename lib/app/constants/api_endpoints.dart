class ApiEndpoints {
  ApiEndpoints._();

  static const connectionTimeout = Duration(seconds: 1000);
  static const receiveTimeout = Duration(seconds: 1000);

  // static const String serverAddress = "http://ApiEndpoints.serverAddress";
    static const String serverAddress = "http://192.168.1.9:2000";
  static const String baseUrl = "$serverAddress/";
  static const String imageUrl = "${serverAddress}/uploads/";

  // ------------------- USER -------------------
  static const String registerUser = "user/register";
  static const String loginUser = "user/login";
  static const String getAllUsers = "user/getAll";
  static const String uploadImg = "user/uploadImg";
  static const String verifyPassword = "user/verify-password";
  static const String requestReset = "user/request-reset";
  static String resetPassword(String token) => "user/reset-password/$token";
  static String getUserById(String id) => "user/$id";
  static String updateUserById(String id) => "user/$id";
  static String deleteUserById(String id) => "user/$id";

  // ------------------- POST -------------------
  static const String getAllPosts = "post/";
  static String getPostById(String id) => "post/$id";
  static String getUserPosts(String userId) => "post/user/$userId";
  static const String createPost = "post/createPost";
  static String updatePost(String id) => "post/$id";
  static String deletePost(String id) => "post/$id";

  // ------------------- LIKE -------------------
  static const String likePost = "like/like";
  static const String unlikePost = "like/unlike";
  static String getPostLikes(String postId) => "like/like/$postId";

  // ------------------- COMMENT -------------------
  static const String createComment = "comment/createComment";
  static String getCommentsByPost(String postId) => "comment/comments/$postId";
  static String deleteComment(String commentId) => "comment/delete/$commentId";

  // ------------------- NOTIFICATION -------------------
  static const String createNotification = "notifications/";
  static String getUserNotifications(String userId) => "notifications/$userId";
  static String markNotificationAsRead(String id) => "notifications/read/$id";
  static String deleteNotification(String id) => "notifications/$id";

  // ------------------- FRIENDS (Follow System) -------------------
  static const String followUser = "friends/follow";
  static const String unfollowUser = "friends/unfollow";
  static String getFollowers(String userId) => "friends/followers/$userId";
  static String getFollowing(String userId) => "friends/following/$userId";

  // ------------------- MESSAGE -------------------
  static String getConversationUsers(String userId) => "message/msg/conversations/$userId";
  static const String sendMessage = "message/send";
  static String getMessages(String user1, String user2) => "message/$user1/$user2";
  static const String markMessagesAsRead = "message/read";
  static String deleteMessage(String messageId) => "message/delete/$messageId";
  static String debugMessagesCount(String userId) => "message/debug/count/$userId";
}
