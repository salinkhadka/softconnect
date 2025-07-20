import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/features/friends/presentation/view/friends_page.dart';
import 'package:softconnect/features/friends/presentation/view_model/follow_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view/FeedPage.dart';
import 'package:softconnect/features/home/presentation/view_model/Comment_view_model/comment_view_model.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_viewmodel.dart';
import 'package:softconnect/features/message/presentation/view/inbox_page.dart';
import 'package:softconnect/features/message/presentation/view_model/inbox_viewmodel.dart';
import 'package:softconnect/features/profile/presentation/view/user_profile.dart';
import 'package:softconnect/features/profile/presentation/view_model/user_profile_viewmodel.dart';

class HomeState {
  final int selectedIndex;
  final List<Widget> views;

  const HomeState({required this.selectedIndex, required this.views});

  factory HomeState.initialSync() {
    return HomeState(selectedIndex: 0, views: const []);
  }

  static Future<HomeState> initial() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? 'unknown';

    return HomeState(
      selectedIndex: 0,
      views: [
        BlocProvider<FeedViewModel>(
          create: (_) => serviceLocator<FeedViewModel>(),
          child: FeedPage(currentUserId: userId),
        ),
        BlocProvider<FollowViewModel>(
          create: (_) => serviceLocator<FollowViewModel>(),
          child: FriendsPage(userId: userId),
        ),
        BlocProvider<InboxViewModel>(
          create: (_) => serviceLocator<InboxViewModel>(),
          child: InboxPage(),
        ),
        MultiBlocProvider(
          providers: [
            BlocProvider<UserProfileViewModel>(
              create: (_) => serviceLocator<UserProfileViewModel>(),
            ),
            BlocProvider<FeedViewModel>(
              create: (_) => serviceLocator<FeedViewModel>(),
            ),
            BlocProvider<CommentViewModel>(
              create: (_) => serviceLocator<CommentViewModel>(),
            ),

          ],
          child: UserProfilePage(userId: userId),
        ),
      ],
    );
  }

  HomeState copyWith({int? selectedIndex, List<Widget>? views}) {
    return HomeState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      views: views ?? this.views,
    );
  }
}
