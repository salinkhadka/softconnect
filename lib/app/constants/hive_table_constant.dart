// lib/app/constants/hive_table_constant.dart

class HiveTableConstant {
  HiveTableConstant._();

  // Keep your existing User constants
  static const int userTypeId = 0; // Renamed for clarity
  static const String UserBox = 'UserBox';

  // --- NEW CONSTANTS FOR POSTS ---
  // A unique typeId for the PostHiveModel
  static const int postTypeId = 1;
  // A unique name for the box that will store posts
  static const String PostBox = 'PostBox';

  // --- NEW CONSTANTS FOR THE USER PREVIEW (used inside Post) ---
  // A unique typeId for the UserPreviewHiveModel
  static const int userPreviewTypeId = 2;
  // Note: UserPreviewHiveModel doesn't need its own box, as it will be stored inside PostHiveModel.
}