import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softconnect/features/home/presentation/view_model/Comment_view_model/comment_view_model.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view_model/user_search_state.dart';
import 'package:softconnect/features/home/presentation/view_model/user_search_viewmodel.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/features/profile/presentation/view/user_profile.dart';
import 'package:softconnect/features/profile/presentation/view_model/user_profile_viewmodel.dart';

class UserSearchDelegate extends SearchDelegate {
  final UserSearchViewModel _searchViewModel =
      serviceLocator<UserSearchViewModel>();

  UserSearchDelegate() {
    _searchViewModel.searchUsers('');
  }

  String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    const baseUrl = 'http://10.0.2.2:2000';
    return imagePath.startsWith('http')
        ? imagePath
        : '$baseUrl/${imagePath.replaceAll("\\", "/")}';
  }

  @override
  String get searchFieldLabel => 'Search users';

  @override
  void close(BuildContext context, result) {
    _searchViewModel.close();
    super.close(context, result);
  }

  @override
  Widget buildResults(BuildContext context) {
    return BlocBuilder<UserSearchViewModel, UserSearchState>(
      bloc: _searchViewModel,
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null) {
          return Center(child: Text('Error: ${state.error}'));
        }
        if (state.results.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        return ListView.separated(
          itemCount: state.results.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final user = state.results[index];
            return ListTile(
              leading:
                  user.profilePhoto != null && user.profilePhoto!.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage:
                              NetworkImage(getFullImageUrl(user.profilePhoto)),
                        )
                      : const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user.username),
              subtitle: user.email != null ? Text(user.email!) : null,
              onTap: () {
                close(context, null);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
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
                      child: UserProfilePage(userId: user.id),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _searchViewModel.searchUsers(query);
    return BlocBuilder<UserSearchViewModel, UserSearchState>(
      bloc: _searchViewModel,
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null) {
          return Center(child: Text('Error: ${state.error}'));
        }
        if (state.results.isEmpty) {
          return const Center(child: Text('No suggestions'));
        }
        return ListView.separated(
          itemCount: state.results.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final user = state.results[index];
            return ListTile(
              leading:
                  user.profilePhoto != null && user.profilePhoto!.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage:
                              NetworkImage(getFullImageUrl(user.profilePhoto)),
                        )
                      : const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user.username),
              subtitle: user.email != null ? Text(user.email!) : null,
              onTap: () {
                query = user.username;
                showResults(context);
              },
            );
          },
        );
      },
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
            showSuggestions(context);
          }
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }
}
