import 'package:flutter/material.dart';
import 'package:softconnect/View/login.dart';

class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final studentIdController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String selectedCourse = 'Bsc hons computing';
  bool isTransportProvider = false;

  final List<String> courses = [
    'Bsc hons computing',
    'Bsc hons ethical hacking & cybersecurity',
    'Bsc hons business computing',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Signup'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Create Your SoftConnect Account',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Join the Softwarica student community',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Full Name
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(
                  hintText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Email
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'Email Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Student ID
              TextField(
                controller: studentIdController,
                decoration: const InputDecoration(
                  hintText: 'Student Id',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Dropdown
              DropdownButtonFormField<String>(
                value: selectedCourse,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: courses
                    .map((course) => DropdownMenuItem<String>(
                          value: course,
                          child: Text(course),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCourse = value!;
                  });
                },
              ),
              const SizedBox(height: 12),

              // Password
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Confirm Password
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Transport Provider Checkbox Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: isTransportProvider,
                    onChanged: (value) {
                      setState(() {
                        isTransportProvider = value!;
                      });
                    },
                    activeColor: Colors.deepPurple,
                  ),
                  const Expanded(
                    child: Text(
                      'I agree to terms and conditions of softconnect',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Signup Button
              ElevatedButton(
                onPressed: () {
                   print('--- Signup Form Submitted ---');
  print('Full Name: ${fullNameController.text}');
  print('Email: ${emailController.text}');
  print('Student ID: ${studentIdController.text}');
  print('Course: $selectedCourse');
  print('Password: ${passwordController.text}');
  print('Confirm Password: ${confirmPasswordController.text}');
  print('Transport Service Provider: $isTransportProvider');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Signup', style: TextStyle(color: Colors.white)),
              ),

              const SizedBox(height: 10),

              // Already have an account
              OutlinedButton(
                onPressed: () {
                   Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Already have an account?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
