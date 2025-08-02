import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:softconnect/app/app.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/core/network/hive_service.dart';
import 'fcm_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await firebaseMessagingBackgroundHandler(message); 
}

// Global initialization state
class AppInitializer {
  static bool _isInitialized = false;
  static bool _isInitializing = false;
  static Future<void>? _initializationFuture;
  static Exception? _initializationError;
  
  static bool get isInitialized => _isInitialized;
  static bool get isInitializing => _isInitializing;
  static Exception? get initializationError => _initializationError;
  
  static Future<void> initialize() {
    if (_isInitialized) return Future.value();
    if (_initializationFuture != null) return _initializationFuture!;
    
    _initializationFuture = _performInitialization();
    return _initializationFuture!;
  }
  
  static Future<void> _performInitialization() async {
    if (_isInitialized || _isInitializing) return;
    
    _isInitializing = true;
    _initializationError = null;
    
    try {
      // Run initializations in parallel where possible
      await Future.wait([
        Firebase.initializeApp(),
        HiveService().init(),
      ]);
      
      // These depend on Firebase being initialized
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Run these in parallel
      await Future.wait([
        FCMService().initialize(),
        setupServiceLocator(),
      ]);
      
      _isInitialized = true;
    } catch (e) {
      _initializationError = e is Exception ? e : Exception(e.toString());
      debugPrint('Initialization error: $e');
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }
  
  static void reset() {
    _isInitialized = false;
    _isInitializing = false;
    _initializationFuture = null;
    _initializationError = null;
  }
}

void main() {
  // Only absolute minimum here for fastest startup
  WidgetsFlutterBinding.ensureInitialized();
  
  // Start initialization immediately but don't wait
  AppInitializer.initialize().catchError((e) {
    debugPrint('Background initialization failed: $e');
  });
  
  runApp(const App());
}