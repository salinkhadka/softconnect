import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HomeState {
  initial,
  loggedOut,
}

class HomeViewModel extends Cubit<HomeState> {
  HomeViewModel() : super(HomeState.initial);

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(HomeState.loggedOut);
  }
}
