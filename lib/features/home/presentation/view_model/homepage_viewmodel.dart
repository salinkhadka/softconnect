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
    
    // STEP 1: Backup biometric data before clearing
    final biometricEmail = prefs.getString('biometric_email');
    final biometricPassword = prefs.getString('biometric_password');
    final biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    
    print('Backing up biometric data before logout:');
    print('Biometric email: $biometricEmail');
    print('Biometric password exists: ${biometricPassword != null}');
    print('Biometric enabled: $biometricEnabled');
    
    // STEP 2: Clear all preferences
    await prefs.clear();
    print('All preferences cleared');
    
    // STEP 3: Restore biometric data if it existed
    if (biometricEmail != null && biometricPassword != null && biometricEnabled) {
      await prefs.setString('biometric_email', biometricEmail);
      await prefs.setString('biometric_password', biometricPassword);
      await prefs.setBool('biometric_enabled', true);
      
      print('Biometric data restored after logout:');
      print('Restored email: ${prefs.getString('biometric_email')}');
      print('Restored password exists: ${prefs.getString('biometric_password') != null}');
      print('Restored enabled: ${prefs.getBool('biometric_enabled')}');
    } else {
      print('No biometric data to restore');
    }

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
    
    print("Logout completed successfully with biometric data preserved");
    
  } catch (e) {
    print('Error during logout: $e');
    
    // Even if there's an error, still navigate to login
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
}
