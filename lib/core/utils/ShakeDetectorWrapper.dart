// shake_detector_wrapper.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShakeDetectorWrapper extends StatefulWidget {
  final Widget child;

  const ShakeDetectorWrapper({super.key, required this.child});

  @override
  State<ShakeDetectorWrapper> createState() => _ShakeDetectorWrapperState();
}

class _ShakeDetectorWrapperState extends State<ShakeDetectorWrapper> {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _accelerometerSubscription =
    accelerometerEvents.listen((AccelerometerEvent event) {
  print('Shake detected: x=${event.x}, y=${event.y}, z=${event.z}');

  if (event.x.abs() > 15 || event.y.abs() > 15 || event.z.abs() > 15) {
    if (!_isLoggingOut) {
      _isLoggingOut = true;
      _handleLogout();
    }
  }
});
  }

    

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears stored login info

    if (mounted) {
      // Navigate to login page, replace with your named route or splash
      Navigator.of(context).pushNamedAndRemoveUntil('/splash', (route) => false);
    }

    Future.delayed(const Duration(seconds: 2), () {
      _isLoggingOut = false;
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
