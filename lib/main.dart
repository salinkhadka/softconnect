import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:softconnect/app/app.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/core/network/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
   await HiveService().init();
  runApp(const App());
}
