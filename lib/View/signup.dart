import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  final RegExp emailRegExp = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _submitForm() {
    String fullName = fullNameController.text.trim();
    String email = emailController.text.trim();
    String studentId = studentIdController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (fullName.isEmpty ||
        email.isEmpty ||
        studentId.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showError('All fields are required');
      return;
    }

    if (!emailRegExp.hasMatch(email)) {
      _showError('Please enter a valid email address');
      return;
    }

    if (password.length < 6) {
      _showError('Password must be at least 6 characters long');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    // If all validations pass
    print('--- Signup Form Submitted ---');
    print('Full Name: $fullName');
    print('Email: $email');
    print('Student ID: $studentId');
    print('Course: $selectedCourse');
    print('Password: $password');
    print('Confirm Password: $confirmPassword');
    print('Transport Service Provider: $isTransportProvider');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Signup successful!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

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

              // Student ID (only numbers)
              TextField(
                controller: studentIdController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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

              // Checkbox
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
                onPressed: _submitForm,
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
