import 'package:softconnect/features/friends/data/model/follow_model.dart';

abstract interface class IFriendsDataSource {
  Future<FollowModel> followUser(String followeeId);
  Future<void> unfollowUser(String followeeId);
  Future<List<FollowModel>> getFollowers(String userId);
  Future<List<FollowModel>> getFollowing(String userId);
}
