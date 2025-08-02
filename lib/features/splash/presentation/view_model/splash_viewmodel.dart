import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/main.dart';

enum SplashState {
  initializing,
  initializationError,
  navigateToHome,
  navigateToLogin,
}

class SplashViewModel extends Cubit<SplashState> {
  SplashViewModel() : super(SplashState.initializing);
  
  static SharedPreferences? _cachedPrefs;
  static Future<SharedPreferences>? _prefsInitFuture;

  Future<void> initializeAndDecideNavigation() async {
    try {
      // Start authentication check immediately, don't wait for full initialization
      final authCheckFuture = _checkAuthenticationFast();
      
      // Ensure minimum splash time for UX (reduced from 2s to 1s)
      final minSplashFuture = Future.delayed(const Duration(milliseconds: 1000));
      
      // Wait for initialization only if not already done
      if (!AppInitializer.isInitialized) {
        await AppInitializer.initialize();
      }
      
      // Wait for both auth check and minimum splash time
      final results = await Future.wait([
        authCheckFuture,
        minSplashFuture,
      ]);
      
      final isAuthenticated = results[0] as bool;
      
      if (isAuthenticated) {
        emit(SplashState.navigateToHome);
      } else {
        emit(SplashState.navigateToLogin);
      }
      
    } catch (e) {
      debugPrint('Splash initialization error: $e');
      emit(SplashState.initializationError);
    }
  }
  
  Future<bool> _checkAuthenticationFast() async {
    try {
      // Use cached SharedPreferences if available
      final prefs = await _getSharedPreferences();
      
      // Quick auth check - just check token existence
      final token = prefs.getString('token');
      final userId = prefs.getString('userId');
      
      // Fast validation - just check if essential data exists
      return token != null && 
             token.isNotEmpty && 
             userId != null && 
             userId.isNotEmpty;
             
    } catch (e) {
      debugPrint('Auth check error: $e');
      return false;
    }
  }
  
  static Future<SharedPreferences> _getSharedPreferences() {
    // Cache SharedPreferences instance for faster subsequent access
    if (_cachedPrefs != null) {
      return Future.value(_cachedPrefs!);
    }
    
    // Avoid multiple simultaneous calls to SharedPreferences.getInstance()
    _prefsInitFuture ??= SharedPreferences.getInstance().then((prefs) {
      _cachedPrefs = prefs;
      return prefs;
    });
    
    return _prefsInitFuture!;
  }
  
  void retryInitialization() {
    emit(SplashState.initializing);
    initializeAndDecideNavigation();
  }
}