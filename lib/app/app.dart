import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/app/theme/my_theme.dart';
import 'package:softconnect/app/theme/theme_provider.dart';
import 'package:softconnect/features/splash/presentation/view/SplashScreenView.dart';
import 'package:softconnect/features/splash/presentation/view_model/splash_viewmodel.dart';
import 'package:softconnect/main.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ThemeProvider?>(
      future: _getThemeProvider(),
      builder: (context, snapshot) {
        // Always provide a ThemeProvider, even if it's a default one
        final themeProvider = snapshot.data ?? _createDefaultThemeProvider();
        
        return ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: getApplicationTheme(isDarkMode: false),
                darkTheme: getApplicationTheme(isDarkMode: true),
                themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                home: BlocProvider<SplashViewModel>(
                  create: (_) => snapshot.hasData && AppInitializer.isInitialized
                      ? serviceLocator<SplashViewModel>()
                      : SplashViewModel(),
                  child: SplashScreenView(),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<ThemeProvider?> _getThemeProvider() async {
    try {
      // Wait for initialization if not complete
      if (!AppInitializer.isInitialized) {
        await AppInitializer.initialize();
      }
      
      // Return theme provider from service locator
      return serviceLocator<ThemeProvider>();
    } catch (e) {
      debugPrint('Failed to get ThemeProvider from service locator: $e');
      return null;
    }
  }

  ThemeProvider _createDefaultThemeProvider() {
    // Create a basic theme provider if service locator isn't ready
    return ThemeProvider();
  }
}