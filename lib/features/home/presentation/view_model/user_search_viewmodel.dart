import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softconnect/features/auth/domain/use_case/getall_users_usecase.dart'; // Import your use case
import 'user_search_state.dart';

class UserSearchViewModel extends Cubit<UserSearchState> {
  final SearchUsersUsecase _searchUsersUsecase;
  Timer? _debounce;

  UserSearchViewModel({required SearchUsersUsecase searchUsersUsecase})
      : _searchUsersUsecase = searchUsersUsecase,
        super(const UserSearchState());

  void searchUsers(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      emit(state.copyWith(results: [], error: null, isLoading: false));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    // Pass query properly using named parameter
    final failureOrUsers = await _searchUsersUsecase.call(SearchUsersParams(query: query));

    failureOrUsers.fold(
      (failure) {
        emit(state.copyWith(
          error: failure.toString(),
          isLoading: false,
          results: [],
        ));
      },
      (users) {
        final results = users
            .map((user) => UserSearchResult(
                  id: user.userId,
                  username: user.username,
                  email: user.email,
                  profilePhoto: user.profilePhoto,
                ))
            .toList();

        emit(state.copyWith(results: results, isLoading: false));
      },
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
