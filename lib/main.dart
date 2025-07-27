import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:softconnect/app/app.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/core/network/hive_service.dart';
import 'fcm_service.dart'; // your FCMService class path

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await firebaseMessagingBackgroundHandler(message); 
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Hive before setting up service locator
  await HiveService().init();
  
  // Initialize FCM
  await FCMService().initialize();
  
  // Setup service locator (this will register ThemeProvider)
  await setupServiceLocator();

  runApp(const App());
}