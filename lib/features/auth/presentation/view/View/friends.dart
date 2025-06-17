import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      title: const Text('Friends Screen'),
      centerTitle: true,
    ));
  }
}
