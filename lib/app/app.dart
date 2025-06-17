import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:softconnect/View/homepage.dart';

import 'package:softconnect/features/auth/presentation/view/View/friends.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: FriendsScreen());
  }
}
