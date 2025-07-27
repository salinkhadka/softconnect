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

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // STEP 1: Backup biometric data before clearing (using correct keys)
      final storedUsername = prefs.getString('stored_username');
      final storedPassword = prefs.getString('stored_password');
      final biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      
      print('Backing up biometric data before logout:');
      print('Stored username: $storedUsername');
      print('Stored password exists: ${storedPassword != null}');
      print('Biometric enabled: $biometricEnabled');
      
      // STEP 2: Clear all session-related preferences but keep biometric data
      // Remove session data
      await prefs.remove('token');
      await prefs.remove('userId');
      await prefs.remove('role');
      await prefs.remove('username');
      
      // Remove any other session-specific data you might have
      // But preserve biometric credentials if they exist
      
      print('Session data cleared, biometric data preserved');
      
      // STEP 3: Verify biometric data is still there (if it was there before)
      if (biometricEnabled && storedUsername != null && storedPassword != null) {
        print('Biometric data verification after logout:');
        print('Username still stored: ${prefs.getString('stored_username')}');
        print('Password still exists: ${prefs.getString('stored_password') != null}');
        print('Biometric still enabled: ${prefs.getBool('biometric_enabled')}');
      } else {
        print('No biometric data was configured');
      }

      // Navigate to login screen and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider<LoginViewModel>(
            create: (_) => serviceLocator<LoginViewModel>(),
            child: const LoginScreen(),
          ),
        ),
        (route) => false,
      );
      
      print("Logout completed successfully with biometric data preserved");
      
    } catch (e) {
      print('Error during logout: $e');
      
      // Even if there's an error, still navigate to login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider<LoginViewModel>(
            create: (_) => serviceLocator<LoginViewModel>(),
            child: const LoginScreen(),
          ),
        ),
        (route) => false,
      );
    }
  }

  // Alternative method if you want to completely clear everything including biometrics
  void logoutAndClearBiometrics(BuildContext context) async {
    print("Logout with biometric clearing triggered");

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear ALL preferences including biometric data
      await prefs.clear();
      print('All preferences cleared including biometric data');

      // Navigate to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider<LoginViewModel>(
            create: (_) => serviceLocator<LoginViewModel>(),
            child: const LoginScreen(),
          ),
        ),
        (route) => false,
      );
      
      print("Complete logout finished");
      
    } catch (e) {
      print('Error during complete logout: $e');
      
      // Still navigate even if there's an error
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider<LoginViewModel>(
            create: (_) => serviceLocator<LoginViewModel>(),
            child: const LoginScreen(),
          ),
        ),
        (route) => false,
      );
    }
  }
}
