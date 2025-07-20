import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/features/home/domain/use_case/getPostsUseCase.dart';
import 'package:softconnect/features/home/presentation/view/CreatePostModal.dart';
import 'package:softconnect/features/home/presentation/view/user_search_delegate.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_event.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view_model/home_state.dart';
import 'package:softconnect/features/home/presentation/view_model/homepage_viewmodel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  void _showPostModal(BuildContext context) async {
    final userId = await _getCurrentUserId();

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final createPostUsecase = serviceLocator<CreatePostUsecase>();
    final uploadImageUsecase = serviceLocator<UploadImageUsecase>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return CreatePostModal(
          createPostUsecase: createPostUsecase,
          uploadImageUsecase: uploadImageUsecase,
          userId: userId,
        );
      },
    );

    if (result == true && context.mounted) {
      final feedViewModel = BlocProvider.of<FeedViewModel>(context, listen: false);
      feedViewModel.add(LoadPostsEvent(userId));
    }
  }

  void _openUserSearch(BuildContext context) {
    showSearch(context: context, delegate: UserSearchDelegate());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<HomeViewModel>(),
      child: BlocBuilder<HomeViewModel, HomeState>(
        builder: (context, state) {
          if (state.views.isEmpty) {
            return const Scaffold(
              body: SafeArea(child: Center(child: CircularProgressIndicator())),
            );
          }

          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title: const Text('SoftConnect'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _openUserSearch(context),
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    context.read<HomeViewModel>().logout(context);
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: state.views[state.selectedIndex],
            ),
            bottomNavigationBar: SafeArea(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  BottomNavigationBar(
                    currentIndex: state.selectedIndex,
                    onTap: (index) =>
                        context.read<HomeViewModel>().onTabTapped(index),
                    selectedItemColor: Theme.of(context).primaryColor,
                    unselectedItemColor: Colors.grey,
                    items: const [
                      BottomNavigationBarItem(
                          icon: Icon(Icons.home), label: 'Home'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.group), label: 'Friends'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.message), label: 'Messages'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.person), label: 'Profile'),
                    ],
                    type: BottomNavigationBarType.fixed,
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: FloatingActionButton(
                        onPressed: () => _showPostModal(context),
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
