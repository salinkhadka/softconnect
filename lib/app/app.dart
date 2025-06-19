import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/features/auth/presentation/view/View/login.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_viewmodel.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider<LoginViewModel>(
        create: (_) => serviceLocator<LoginViewModel>(),
        child: LoginScreen(),
      ),
    );
  }
}
