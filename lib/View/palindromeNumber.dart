import 'package:flutter/material.dart';

class PalindromeNumberView extends StatefulWidget {
  const PalindromeNumberView({super.key});

  @override
  State<PalindromeNumberView> createState() => _PalindromeNumberViewState();
}

class _PalindromeNumberViewState extends State<PalindromeNumberView> {
  String input = "";
  String result = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Palindrome Checker"),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                input = value;
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter a number",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  String reversed = input.split('').reversed.join('');
                  setState(() {
                    result = (input == reversed)
                        ? "It is a palindrome"
                        : "Not a palindrome";
                  });
                },
                child: Text("Check"),
              ),
            ),
            SizedBox(height: 8),
            Text(result, style: TextStyle(fontSize: 30)),
          ],
        ),
      ),
    );
  }
}
