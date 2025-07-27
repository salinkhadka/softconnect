import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/app/theme/my_theme.dart';
import 'package:softconnect/app/theme/theme_provider.dart';
import 'package:softconnect/features/splash/presentation/view/SplashScreenView.dart';
import 'package:softconnect/features/splash/presentation/view_model/splash_viewmodel.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeProvider>(
      // Get ThemeProvider from service locator
      create: (_) => serviceLocator<ThemeProvider>(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            // Apply theme based on ThemeProvider state
            theme: getApplicationTheme(isDarkMode: false), // Light theme
            darkTheme: getApplicationTheme(isDarkMode: true), // Dark theme
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: BlocProvider<SplashViewModel>(
              create: (_) => serviceLocator<SplashViewModel>(),
              child: SplashScreenView(),
            ),
          );
        },
      ),
    );
  }
}