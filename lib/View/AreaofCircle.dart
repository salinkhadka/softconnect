import 'package:flutter/material.dart';
import 'dart:math';

class AreaOfCircleView extends StatefulWidget {
  const AreaOfCircleView({super.key});

  @override
  State<AreaOfCircleView> createState() => _AreaOfCircleViewState();
}

class _AreaOfCircleViewState extends State<AreaOfCircleView> {
  double radius = 0;
  double area = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Area of Circle"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                radius = double.tryParse(value) ?? 0;
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter Radius",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    area = pi * radius * radius;
                  });
                },
                child: Text("Calculate"),
              ),
            ),
            SizedBox(height: 8),
            Text("Area : $area", style: TextStyle(fontSize: 30)),
          ],
        ),
      ),
    );
  }
}
