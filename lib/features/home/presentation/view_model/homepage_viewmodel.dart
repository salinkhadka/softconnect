import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softconnect/features/home/presentation/view_model/home_state.dart';

class HomeViewModel extends Cubit<HomeState> {
  HomeViewModel() : super(HomeState.initialSync()) {
    _init();
  }

  Future<void> _init() async {
    final initialState = await HomeState.initial();
    emit(initialState);
  }

  void onTabTapped(int index) {
    emit(state.copyWith(selectedIndex: index));
  }

  void logout(BuildContext context) {
    // Implement logout logic (clear prefs, navigate to login)
    // Example:
    // await SharedPreferences.getInstance().then((prefs) => prefs.clear());
    // Navigator.of(context).pushReplacementNamed('/login');
  }
}
