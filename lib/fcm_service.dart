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
      await _requestPermission();
      await _initializeLocalNotifications();

      String? token = await getToken();
      log('FCM Token: $token');

      _configureMessageHandlers();
      await subscribeToTopic('general');
    } catch (e) {
      log('Error initializing FCM: $e');
    }
  }

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

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_foreground'); // Custom icon here

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

  void _configureMessageHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleBackgroundMessage(message);
      }
    });
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    log('Received foreground message: ${message.messageId}');
    await _showLocalNotification(message);
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    log('Opened from background message: ${message.messageId}');
    _navigateBasedOnMessage(message);
  }

  void _handleNotificationTap(String? payload) {
    log('Notification tapped with payload: $payload');
    if (payload != null) {
      _handlePayload(payload);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'softconnect_channel',
      'SoftConnect Notifications',
      channelDescription: 'Notifications from SoftConnect app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@drawable/ic_foreground', // Custom icon
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

  void _navigateBasedOnMessage(RemoteMessage message) {
    final data = message.data;

    if (data.containsKey('screen')) {
      switch (data['screen']) {
        case 'profile':
          log('Navigate to profile');
          break;
        case 'chat':
          log('Navigate to chat with user: ${data['userId'] ?? ''}');
          break;
        case 'notification':
          log('Navigate to notifications');
          break;
        default:
          log('Navigate to home');
      }
    }
  }

  void _handlePayload(String payload) {
    log('Handling payload: $payload');
  }

  Future<String?> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      log('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      log('Subscribed to topic: $topic');
    } catch (e) {
      log('Error subscribing to topic $topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      log('Unsubscribed from topic: $topic');
    } catch (e) {
      log('Error unsubscribing from topic $topic: $e');
    }
  }

  Future<void> sendTokenToServer(String token, String userId) async {
    try {
      log('Token sent to server for user: $userId');
    } catch (e) {
      log('Error sending token to server: $e');
    }
  }

  void listenForTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((String token) {
      log('FCM Token refreshed: $token');
    });
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling background message: ${message.messageId}');
}
