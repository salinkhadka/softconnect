import 'package:flutter/material.dart';

class SimpleInterestView extends StatefulWidget {
  const SimpleInterestView({super.key});

  @override
  State<SimpleInterestView> createState() => _SimpleInterestViewState();
}

class _SimpleInterestViewState extends State<SimpleInterestView> {
  double principal = 0;
  double rate = 0;
  double time = 0;
  double result = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Simple Interest"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                principal = double.tryParse(value) ?? 0;
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter Principal",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              onChanged: (value) {
                rate = double.tryParse(value) ?? 0;
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter Rate",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              onChanged: (value) {
                time = double.tryParse(value) ?? 0;
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter Time",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    result = (principal * rate * time) / 100;
                  });
                },
                child: Text("Calculate"),
              ),
            ),
            SizedBox(height: 8),
            Text("Result : $result", style: TextStyle(fontSize: 30)),
          ],
        ),
      ),
    );
  }
}
