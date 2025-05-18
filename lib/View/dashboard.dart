import 'package:flutter/material.dart';
import 'first_view.dart';
import 'AreaofCircle.dart';
import 'SimpleInterest.dart';
import 'palindromeNumber.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Dashboard"),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 202, 86, 86)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FirstView()),
                  );
                },
                child: Text("Add Two Numbers"),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AreaOfCircleView()),
                  );
                },
                child: Text("Area of Circle"),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SimpleInterestView()),
                  );
                },
                child: Text("Simple Interest"),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PalindromeNumberView()),
                  );
                },
                child: Text("Palindrome Number"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
