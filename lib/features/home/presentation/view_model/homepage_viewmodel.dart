import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_state.dart';

class HomeViewModel extends Cubit<HomeState> {
  HomeViewModel() : super(HomeState.initialSync()) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final initialState = await HomeState.initial();
    emit(initialState);
  }

  void onTabTapped(int index) {
    emit(state.copyWith(selectedIndex: index));
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Navigation can be handled outside, e.g., by the UI
  }
}
