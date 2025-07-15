import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/features/friends/presentation/view/friends_page.dart';
import 'package:softconnect/features/friends/presentation/view_model/follow_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view/hometab.dart';

class HomeState {
  final int selectedIndex;
  final List<Widget> views;

  const HomeState({required this.selectedIndex, required this.views});

  /// A quick synchronous initial state with empty views.
  factory HomeState.initialSync() {
    return HomeState(selectedIndex: 0, views: const []);
  }

  /// Asynchronously load initial state (load userId from SharedPreferences)
  static Future<HomeState> initial() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? 'unknown';

    return HomeState(
      selectedIndex: 0,
      views: [
        const HomeTab(),
        BlocProvider(
          create: (_) => serviceLocator<FollowViewModel>(),
          child: FriendsPage(userId: userId),
        ),
        const Center(child: Text('Messages')),
        const Center(child: Text('Profile')),
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
