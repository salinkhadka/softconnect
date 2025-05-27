import 'package:flutter/material.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'This is the Messages Screen',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
