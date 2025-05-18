import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:softconnect/View/login.dart';
import 'package:softconnect/View/signup.dart';
// import 'package:lottie/lottie.dart';
// import 'package:softCo/model/splash_model.dart';
import 'package:softconnect/model/splash_model.dart';
// import 'package:yatra_app/view/signin_view.dart';
// ignore: depend_on_referenced_packages
import 'package:page_transition/page_transition.dart';


class SplashScreenView extends StatelessWidget {
  final SplashModel _viewmodel = SplashModel();

  SplashScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _viewmodel.initApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AnimatedSplashScreen(
            splash: Lottie.asset('assets/animations/softConnect.json', height: 200),
            splashIconSize: 400,
            backgroundColor: Colors.white,
            splashTransition: SplashTransition.fadeTransition,
            duration: 2500,
            nextScreen: LoginPage(), // Your login screen
            pageTransitionType: PageTransitionType.bottomToTop,
          );
        } else {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF07609b)),
            ),
          );
        }
      },
    );
  }
}