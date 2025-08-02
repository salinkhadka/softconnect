import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:softconnect/features/home/presentation/view_model/homepage_viewmodel.dart';
import 'package:softconnect/features/splash/presentation/view_model/splash_viewmodel.dart';
import 'package:softconnect/features/auth/presentation/view/View/login.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view/HomePage.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/app/theme/theme_provider.dart';
import 'package:softconnect/main.dart';

class SplashScreenView extends StatefulWidget {
  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  @override
  void initState() {
    super.initState();
    // Start navigation logic immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SplashViewModel>().initializeAndDecideNavigation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashViewModel, SplashState>(
      listener: (context, state) {
        if (state == SplashState.navigateToHome) {
          _navigateToHome();
        } else if (state == SplashState.navigateToLogin) {
          _navigateToLogin();
        }
      },
      child: Scaffold(
        body: BlocBuilder<SplashViewModel, SplashState>(
          builder: (context, state) {
            if (state == SplashState.initializationError) {
              return _buildErrorView(context);
            }
            return _buildSplashView();
          },
        ),
      ),
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            // Ensure ThemeProvider is available in the new route
            ChangeNotifierProvider<ThemeProvider>.value(
              value: Provider.of<ThemeProvider>(context, listen: false),
              child: BlocProvider<HomeViewModel>(
                create: (_) => serviceLocator<HomeViewModel>(),
                child: const HomePage(),
              ),
            ),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            // Ensure ThemeProvider is available in the new route
            ChangeNotifierProvider<ThemeProvider>.value(
              value: Provider.of<ThemeProvider>(context, listen: false),
              child: BlocProvider<LoginViewModel>(
                create: (_) => serviceLocator<LoginViewModel>(),
                child: LoginScreen(),
              ),
            ),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _buildSplashView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie animation with larger size
          Lottie.asset(
            'assets/animations/softConnect.json',
            width: 300,
            height: 300,
            fit: BoxFit.contain,
            // Cache the animation for better performance
            frameRate: FrameRate.max,
          ),
          const SizedBox(height: 20),
          // Only show loading indicator if initialization is taking time
          if (AppInitializer.isInitializing) ...[
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(height: 12),
            const Text(
              'Loading...',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to initialize app',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              AppInitializer.initializationError?.toString() ?? 
              'Please check your internet connection and try again',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<SplashViewModel>().retryInitialization();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}