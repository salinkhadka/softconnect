import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SplashState {
  initial,
  navigateToHome,
  navigateToLogin,
}

class SplashViewModel extends Cubit<SplashState> {
  SplashViewModel() : super(SplashState.initial);

  Future<void> decideNavigation() async {
    // Add a 2-second delay to simulate splash screen wait time
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    
    // Check for token and other user data
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');
    final role = prefs.getString('role');
    final username = prefs.getString('username');

    // If token exists and other essential data is present, navigate to home
    // You can adjust this logic based on which fields are mandatory
    if (token != null && 
        token.isNotEmpty && 
        userId != null && 
        userId.isNotEmpty &&
        role != null && 
        role.isNotEmpty) {
      emit(SplashState.navigateToHome);
    } else {
      emit(SplashState.navigateToLogin);
    }
  }
}
