import 'package:flutter/material.dart';

class ClassTask extends StatefulWidget {
  const ClassTask({super.key});

  @override
  State<ClassTask> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ClassTask> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Center(
            child: Container(
              color: Colors.blueAccent,
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      Icon(Icons.message, color: Colors.white),
                      SizedBox(
                        width: 10,
                      ),
                      Text("call")
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: [
                      Icon(Icons.message, color: Colors.white),
                      SizedBox(
                        width: 10,
                      ),
                      Text("message")
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: [
                      Icon(Icons.share, color: Colors.white),
                      SizedBox(
                        width: 10,
                      ),
                      Text("share")
                    ],
                  )
                ],
              ),
            ),
        ),

        
      ]),
    );
  }
}
