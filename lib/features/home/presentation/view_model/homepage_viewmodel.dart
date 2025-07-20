import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/features/auth/presentation/view/View/login.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_viewmodel.dart';
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

  void logout(BuildContext context) async {
    print("Logout triggered");

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navigate to login screen and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider<LoginViewModel>(
          create: (_) => serviceLocator<LoginViewModel>(),
          child: LoginScreen(),
        ),
      ),
      (route) => false,
    );
  }
}
