import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  // Initialize FCM
  Future<void> initialize() async {
    try {
      // Request notification permissions
      await _requestPermission();
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Get FCM token
      String? token = await getToken();
      log('FCM Token: $token');
      
      // Configure message handlers
      _configureMessageHandlers();
      
      // Subscribe to topic (optional)
      await subscribeToTopic('general');
      
    } catch (e) {
      log('Error initializing FCM: $e');
    }
  }

  // Request notification permissions
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    log('Notification permission status: ${settings.authorizationStatus}');
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );
  }

  // Configure message handlers
  void _configureMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Handle initial message if app was opened from notification
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleBackgroundMessage(message);
      }
    });
  }

  // Handle messages when app is in foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    log('Received foreground message: ${message.messageId}');
    
    // Show local notification
    await _showLocalNotification(message);
  }

  // Handle messages when app is opened from background
  void _handleBackgroundMessage(RemoteMessage message) {
    log('Opened from background message: ${message.messageId}');
    
    // Navigate to specific screen based on message data
    _navigateBasedOnMessage(message);
  }

  // Handle notification tap
  void _handleNotificationTap(String? payload) {
    log('Notification tapped with payload: $payload');
    
   
    if (payload != null) {
      
      _handlePayload(payload);
    }
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'softconnect_channel',
      'SoftConnect Notifications',
      channelDescription: 'Notifications from SoftConnect app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Message',
      message.notification?.body ?? 'You have a new message',
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  // Navigate based on message data
  void _navigateBasedOnMessage(RemoteMessage message) {
    // Example navigation logic
    final data = message.data;
    
    if (data.containsKey('screen')) {
      switch (data['screen']) {
        case 'profile':
          // Navigate to profile screen
          log('Navigate to profile');
          break;
        case 'chat':
          // Navigate to chat screen
          log('Navigate to chat with user: ${data['userId'] ?? ''}');
          break;
        case 'notification':
          // Navigate to notifications screen
          log('Navigate to notifications');
          break;
        default:
          // Navigate to home screen
          log('Navigate to home');
      }
    }
  }

  // Handle payload from local notification
  void _handlePayload(String payload) {
    // Parse and handle payload
    log('Handling payload: $payload');
  }

  // Get FCM token
  Future<String?> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      log('Error getting FCM token: $e');
      return null;
    }
  }

  // Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      log('Subscribed to topic: $topic');
    } catch (e) {
      log('Error subscribing to topic $topic: $e');
    }
  }

  // Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      log('Unsubscribed from topic: $topic');
    } catch (e) {
      log('Error unsubscribing from topic $topic: $e');
    }
  }

  // Send token to your backend server
  Future<void> sendTokenToServer(String token, String userId) async {
    try {
      // Make API call to your backend to save the token
      // Example:
      // await ApiService().saveUserToken(userId, token);
      log('Token sent to server for user: $userId');
    } catch (e) {
      log('Error sending token to server: $e');
    }
  }

  // Listen for token refresh
  void listenForTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((String token) {
      log('FCM Token refreshed: $token');
      // Send new token to your server
      // sendTokenToServer(token, currentUserId);
    });
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling background message: ${message.messageId}');
  // Handle the message when app is completely terminated
}
